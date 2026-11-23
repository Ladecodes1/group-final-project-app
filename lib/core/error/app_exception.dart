/// A readable error that the UI can show directly in a SnackBar.
///
/// Repositories catch low-level Firebase errors and rethrow them as
/// [AppException] so the presentation layer never depends on Firebase.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
