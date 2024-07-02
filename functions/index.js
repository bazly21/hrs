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
        const userBatch = db.batch();

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

          // Update user"s hasActiveTenancy field to false
          const tenancyData = doc.data();
          const tenantID = tenancyData.tenantID;
          const tenantRef = db.collection("users").doc(tenantID);
          userBatch.update(tenantRef, {hasActiveTenancy: false});
        });

        // Commit the batch writes
        await Promise.all([tenancyBatch.commit(), propertyBatch.commit(), userBatch.commit()]);
        console.log("Tenancy and property status updated successfully");
      } else {
        console.log("No expired tenancies found");
      }
    } catch (error) {
      console.error("Error updating tenancy and property status:", error);
    }
  });

  exports.updateApplicationStatusOnTenancyCreate = functions.firestore
    .document("properties/{propertyId}/tenancies/{tenancyId}")
    .onCreate(async (snapshot, context) => {
        const propertyId = context.params.propertyId;
        const db = admin.firestore();

        try {
            // Get all applications for this property with "Pending" status
            const applicationsSnapshot = await db.collection("properties")
                .doc(propertyId)
                .collection("applications")
                .where("status", "==", "Pending")
                .get();

            // If there are no pending applications, exit early
            if (applicationsSnapshot.empty) {
                console.log(`No pending applications found for property ${propertyId}`);
                return;
            }

            // Prepare batch write
            const batch = db.batch();

            applicationsSnapshot.docs.forEach((doc) => {
                batch.update(doc.ref, {status: "Declined"});
            });

            // Commit the batch
            await batch.commit();

            console.log(`Successfully updated`);
        } catch (error) {
            console.error("Error updating application statuses:", error);
        }
    });

exports.calculateTenantCriteriaScore = functions.firestore
  .document("properties/{propertyId}/applications/{applicationId}")
  .onCreate(async (snapshot, context) => {
    try {
      const db = admin.firestore();
      const applicationData = snapshot.data();
      const propertyID = context.params.propertyId;
      const applicantID = applicationData.applicantID;

      // Fetch the property document
      const propertySnapshot = await db
        .collection("properties")
        .doc(propertyID)
        .get();

      // Fetch applicant"s user document
      const applicantSnapshot = await db
        .collection("users")
        .doc(applicantID)
        .get();

      // Check if the property document exists
      if (propertySnapshot.exists && applicantSnapshot.exists) {
        // Extract tenantCriteria field from the property document
        const propertyData = propertySnapshot.data();

        // Check if the property document contains tenantCriteria field
        // If not, skip the calculation
        if (!propertyData.tenantCriteria) {
          return;
        }

        const tenantCriteria = propertyData.tenantCriteria;

        // Get the applicant"s overall rating
        const applicantData = applicantSnapshot.data();
        const overallRating = applicantData.ratingAverage?.tenant?.overallRating || 0;

        // Perform operations with tenantCriteria field
        const criteriaScore = calculateCriteriaScore(tenantCriteria, applicationData, overallRating);

        // Update the document with the calculated criteria score
        await snapshot.ref.update({criteriaScore: criteriaScore});
      } else {
        console.log("Property or applicant not found");
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
 * @param {number} overallRating - The overall rating of the applicant.
 * @return {number} The calculated criteria score.
 */
function calculateCriteriaScore(tenantCriteria, applicationData, overallRating) {
  let score = 0;

  // Add overall rating to the score
  score += overallRating;

  // Calculate score based on profile type
  if (applicationData.profileType === tenantCriteria.profileType) {
    score += 1;
  }

  // Calculate score based on number of pax
  const numberOfPax = applicationData.numberOfPax;
  const paxScore = {
    "Single or Couple": numberOfPax <= 2 ? 1 : 0,
    "Small Family (1 to 4 pax)": numberOfPax <= 4 ? numberOfPax : 0,
    "Large Family (5+ pax)": numberOfPax >= 5 ? (numberOfPax - 4) : 0,
  };
  score += paxScore[tenantCriteria.numberOfPax] || 0;

  // Calculate score based on nationality
  if (applicationData.nationality === tenantCriteria.nationality) {
    score += 1;
  }

  // Calculate score based on tenancy duration
  const tenancyDuration = applicationData.tenancyDuration;
  const durationScore = {
    "Short term (< 4 Months)": tenancyDuration <= 3 ? tenancyDuration : 0,
    "Mid term (4-9 Months)": tenancyDuration >= 4 && tenancyDuration <= 9 ? (tenancyDuration - 3) : 0,
    "Long term (10-12 months)": tenancyDuration >= 10 && tenancyDuration <= 12 ? (tenancyDuration - 9) : 0,
  };
  score += durationScore[tenantCriteria.tenancyDuration] || 0;

  return score;
}
