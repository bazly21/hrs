const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.updateTenancyAndPropertyStatus = functions.pubsub
  .schedule("0 0 *")
  .timeZone("Asia/Kuala_Lumpur")
  .onRun(async (context) => {
    try {
      const db = admin.firestore();
      const currentDate = new Date();

      // Query tenancies where endDate is before or equal to the current date
      const expiredTenanciesSnapshot = await db
        .collectionGroup("tenancies")
        .where("status", "==", "Active")
        .where("endDate", "<=", currentDate)
        .get();

      // Get the expired tenancy documents
      const expiredTenancies = expiredTenanciesSnapshot.docs;

      if (expiredTenancies.length > 0) {
        // Create batch writes for updating tenancies and properties
        const tenancyBatch = db.batch();
        const propertyBatch = db.batch();

        // Update the status of the expired tenancies to "Ended"
        expiredTenancies.forEach((doc) => {
          const tenancyRef = doc.ref;
          tenancyBatch.update(tenancyRef, {
            status: "Ended",
            isRated: {
              rateLandlord: false,
              rateTenant: false,
            },
          });

          // Get the propertyID from the parent document path
          const propertyID = doc.ref.parent.parent.id;
          const propertyRef = db.collection("properties").doc(propertyID);
          propertyBatch.update(propertyRef, {status: "Available"});
        });

        // Commit the batch writes
        await Promise.all([tenancyBatch.commit(), propertyBatch.commit()]);
        console.log("Tenancy and property status updated successfully");
      } else {
        console.log("No expired tenancies found");
      }
    } catch (error) {
      console.error("Error updating tenancy and property status:", error);
    }
  });

exports.calculateTenantCriteriaScore = functions.firestore
  .document("properties/{propertyId}/applications/{applicationId}")
  .onCreate(async (snapshot, context) => {
    try {
      const db = admin.firestore();
      const applicationData = snapshot.data();
      const propertyID = context.params.propertyId;

      // Fetch the property document
      const propertySnapshot = await db
        .collection("properties")
        .doc(propertyID)
        .get();

      // Check if the property document exists
      if (propertySnapshot.exists) {
        // Extract tenantCriteria field from the property document
        const propertyData = propertySnapshot.data();

        // Check if the property document contains tenantCriteria field
        // If not, skip the calculation
        if (!propertyData.tenantCriteria) {
          return;
        }

        const tenantCriteria = propertyData.tenantCriteria;

        // Perform operations with tenantCriteria field
        const criteriaScore = calculateCriteriaScore(tenantCriteria, applicationData);

        // Update the document with the calculated criteria score
        await snapshot.ref.update({criteriaScore: criteriaScore});
      } else {
        console.log("Property document not found.");
      }
    } catch (error) {
      console.error("Error updating criteria score: ", error);
    }
  });

/**
 * Calculates the criteria score based on tenant criteria and application data.
 *
 * @param {Object} tenantCriteria - The tenant criteria object.
 * @param {string} tenantCriteria.profileType - The desired profile type.
 * @param {string} tenantCriteria.numberOfPax - The desired number of pax.
 * @param {string} tenantCriteria.nationality - The desired nationality.
 * @param {string} tenantCriteria.tenancyDuration - The desired tenancy duration.
 * @param {Object} applicationData - The application data object.
 * @param {string} applicationData.profileType - The profile type of the applicant.
 * @param {number} applicationData.numberOfPax - The number of pax of the applicant.
 * @param {string} applicationData.nationality - The nationality of the applicant.
 * @param {number} applicationData.tenancyDuration - The tenancy duration of the applicant.
 * @return {number} The calculated criteria score.
 */
  function calculateCriteriaScore(tenantCriteria, applicationData) {
    let score = 0;

    // Calculate score based on profile type
    if (applicationData.profileType === tenantCriteria.profileType) {
      score += 10;
    }

    // Calculate score based on number of pax
    const numberOfPax = applicationData.numberOfPax;
    const paxScore = {
      "Single or Couple": numberOfPax <= 2 ? 10 : 0,
      "Small Family (1 to 4 pax)": numberOfPax <= 4 ? (numberOfPax * 10) : 0,
      "Large Family (5+ pax)": numberOfPax >= 5 ? ((numberOfPax - 4) * 10) : 0,
    };
    score += paxScore[tenantCriteria.numberOfPax] || 0;

    // Calculate score based on nationality
    if (applicationData.nationality === tenantCriteria.nationality) {
      score += 10;
    }

    // Calculate score based on tenancy duration
    const tenancyDuration = applicationData.tenancyDuration;
    const durationScore = {
      "Short term (< 4 Months)": tenancyDuration <= 3 ? (tenancyDuration * 10) : 0,
      "Mid term (4-9 Months)": tenancyDuration >= 4 && tenancyDuration <= 9 ? ((tenancyDuration - 3) * 10) : 0,
      "Long term (10-12 months)": tenancyDuration >= 10 && tenancyDuration <= 12 ? ((tenancyDuration - 9) * 10) : 0,
    };
    score += durationScore[tenantCriteria.tenancyDuration] || 0;

    return score;
  }
