import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_exception.dart';

/// Turns a Firebase error code into a message a student can understand.
String friendlyFirebaseMessage(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return "You don't have permission to do that.";
    case 'unavailable':
      return 'No connection. Check your internet and try again.';
    case 'not-found':
      return 'We could not find that item.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

/// Runs [action] and converts Firebase errors into [AppException].
/// Every repository uses this so error handling is written once.
Future<T> guardFirebase<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on FirebaseException catch (e) {
    throw AppException(friendlyFirebaseMessage(e));
  }
}

/// Used with Stream.handleError so stream errors are also friendly.
Never rethrowFriendly(Object error) {
  if (error is FirebaseException) {
    throw AppException(friendlyFirebaseMessage(error));
  }
  throw error;
}
