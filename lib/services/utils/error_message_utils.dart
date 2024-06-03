import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String genericUpdateErrorMessage =
    "An error occurred while updating the profile. Please try again.";
const String genericRegisterErrorMessage =
    "An error occurred while registering the profile. Please try again.";
const String canceledErrorMessage = "Image upload has been canceled.";
const String unauthorizedErrorMessage =
    "User doesn't have permission to access the object.";
const String unknownErrorMessage =
    "An unknown error occurred. Please try again.";

// For Firebase Auth
const String invalidPhoneNumberErrorMessage =
    "The phone number entered is invalid.";
const String tooManyRequestsErrorMessage =
    "Too many requests. Please try again later.";
const String networkRequestFailedErrorMessage =
    "Network error. Please check your connection.";
const String quotaExceededErrorMessage =
    "SMS quota exceeded. Please try again later.";
const String phoneNumberExistsErrorMessage =
    "The phone number is already in use by another account.";
const String invalidAccessErrorMessage =
    "Invalid access. Please sign in again.";

// Generic error messages
const String genericFutureErrorMessage =
    "An error occurred while getting the data. Please try again.";

String getErrorMessage(Object e) {
  String errorMessage;

  if (e is FirebaseException) {
    if (e.plugin == 'firebase_firestore') {
      switch (e.code) {
        case 'cancelled':
          errorMessage = "The operation was cancelled.";
          break;
        case 'unknown':
          errorMessage = "Unknown error occurred.";
          break;
        case 'invalid-argument':
          errorMessage = "Invalid argument provided.";
          break;
        case 'deadline-exceeded':
          errorMessage = "Operation timed out.";
          break;
        case 'not-found':
          errorMessage = "Document not found.";
          break;
        case 'already-exists':
          errorMessage = "Document already exists.";
          break;
        case 'permission-denied':
          errorMessage = "Permission denied.";
          break;
        case 'resource-exhausted':
          errorMessage = "Resource exhausted.";
          break;
        case 'failed-precondition':
          errorMessage = "Failed precondition.";
          break;
        case 'aborted':
          errorMessage = "Operation aborted.";
          break;
        case 'out-of-range':
          errorMessage = "Out of range.";
          break;
        case 'unimplemented':
          errorMessage = "Operation not implemented.";
          break;
        case 'internal':
          errorMessage = "Internal error.";
          break;
        case 'unavailable':
          errorMessage = "Service unavailable.";
          break;
        case 'data-loss':
          errorMessage = "Data loss.";
          break;
        case 'unauthenticated':
          errorMessage = "Unauthenticated.";
          break;
        default:
          errorMessage = "An error occurred with Firestore.";
      }
    } else if (e.plugin == 'firebase_storage') {
      switch (e.code) {
        case 'unknown':
          errorMessage = "Unknown error occurred.";
          break;
        case 'object-not-found':
          errorMessage = "No object exists at the desired reference.";
          break;
        case 'bucket-not-found':
          errorMessage = "No bucket is configured for Cloud Storage.";
          break;
        case 'project-not-found':
          errorMessage = "No project is configured for Cloud Storage.";
          break;
        case 'quota-exceeded':
          errorMessage = "Quota on your Cloud Storage bucket has been exceeded.";
          break;
        case 'unauthenticated':
          errorMessage = "User is unauthenticated. Authenticate and try again.";
          break;
        case 'unauthorized':
          errorMessage = "User is not authorized to perform the desired action.";
          break;
        case 'retry-limit-exceeded':
          errorMessage = "Max retry time for operation exceeded, please try again.";
          break;
        case 'invalid-checksum':
          errorMessage = "File on the client does not match the checksum of the file received by the server.";
          break;
        case 'canceled':
          errorMessage = "User canceled the operation.";
          break;
        case 'invalid-event-name':
          errorMessage = "Invalid event name provided. Must be one of ['state_changed'].";
          break;
        case 'invalid-url':
          errorMessage = "Invalid URL provided to refFromURL().";
          break;
        case 'invalid-argument':
          errorMessage = "Invalid argument provided.";
          break;
        default:
          errorMessage = "An error occurred with Firebase Storage.";
      }
    } else if (e.plugin == 'firebase_auth') {
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = "Invalid verification code.";
          break;
        case 'invalid-verification-id':
          errorMessage = "Invalid verification ID.";
          break;
        case 'invalid-phone-number':
          errorMessage = "Invalid phone number.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address.";
          break;
        case 'user-disabled':
          errorMessage = "User account is disabled.";
          break;
        case 'user-not-found':
          errorMessage = "User not found.";
          break;
        case 'wrong-password':
          errorMessage = "Wrong password.";
          break;
        case 'email-already-in-use':
          errorMessage = "Email is already in use.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Operation not allowed.";
          break;
        case 'weak-password':
          errorMessage = "Weak password.";
          break;
        case 'missing-phone-number':
          errorMessage = "Phone number is missing.";
          break;
        case 'quota-exceeded':
          errorMessage = "SMS quota for the project has been exceeded.";
          break;
        case 'session-expired':
          errorMessage = "Verification code has expired.";
          break;
        default:
          errorMessage = "An error occurred with authentication.";
      }
    } else {
      errorMessage = "An unknown error occurred in Firebase services";
    }
  } else {
    errorMessage = "An unknown error occurred.";
  }

  return errorMessage;
}
