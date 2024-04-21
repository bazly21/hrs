const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.updateTenancyAndPropertyStatus = functions.pubsub
  .schedule("0 0 * * *") // Runs daily at midnight
  .onRun(async (context) => {
    try {
      const db = admin.firestore();
      const currentDate = new Date();

      // Query tenancies where endDate is before or equal to the current date
      const tenanciesSnapshot = await db
        .collection("tenancies")
        .where("endDate", "<=", currentDate)
        .get();

      // Get the expired tenancy documents and propertyIDs
      const expiredTenancies = tenanciesSnapshot.docs;
      const propertyIds = expiredTenancies.map((doc) => doc.data().propertyID);

      // Create batch writes for updating tenancies and properties
      const tenancyBatch = db.batch();
      const propertyBatch = db.batch();

      // Update the status of the expired tenancies to "Ended"
      expiredTenancies.forEach((doc) => {
        const tenancyRef = db.collection("tenancies").doc(doc.id);
        tenancyBatch.update(tenancyRef, {
          status: "Ended",
          isRated: false,
        });
      });

      // Update the status of the corresponding properties to "Available"
      propertyIds.forEach((propertyID) => {
        const propertyRef = db.collection("properties").doc(propertyID);
        propertyBatch.update(propertyRef, {status: "Available"});
      });

      // Commit the batch writes
      await Promise.all([tenancyBatch.commit(), propertyBatch.commit()]);

      console.log("Tenancy and property status updated successfully");
    } catch (error) {
      console.error("Error updating tenancy and property status:", error);
    }
  });
