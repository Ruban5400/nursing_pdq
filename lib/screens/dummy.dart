// ── Result wrapper ────────────────────────────────────────────────────────────

enum PatientInfoStatus { success, notFound, unauthorized, serverError }

class PatientInfoResult {
  final PatientInfoStatus status;
  final Map<String, dynamic>? data;
  final String? message;

  const PatientInfoResult._({
    required this.status,
    this.data,
    this.message,
  });

  factory PatientInfoResult.success(Map<String, dynamic> data) =>
      PatientInfoResult._(status: PatientInfoStatus.success, data: data);

  factory PatientInfoResult.notFound() => const PatientInfoResult._(
    status: PatientInfoStatus.notFound,
    message: 'No records found for this patient.',
  );

  factory PatientInfoResult.unauthorized() => const PatientInfoResult._(
    status: PatientInfoStatus.unauthorized,
    message: 'Session expired. Please log in again.',
  );

  factory PatientInfoResult.serverError([String? detail]) => PatientInfoResult._(
    status: PatientInfoStatus.serverError,
    message: detail ?? 'A server error occurred. Please try again.',
  );

  bool get isSuccess => status == PatientInfoStatus.success;
}


enum ApiExceptionType { unauthorized, noRecords, network, timeout, serverError }

class ApiException implements Exception {
  final ApiExceptionType type;
  final String? message;

  const ApiException._(this.type, [this.message]);

  const factory ApiException.unauthorized()           = _Unauthorized;
  const factory ApiException.noRecords([String? msg]) = _NoRecords;
  const factory ApiException.network()                = _Network;
  const factory ApiException.timeout()                = _Timeout;
  factory       ApiException.serverError([String? m]) =>
      ApiException._(ApiExceptionType.serverError, m);
}

class _Unauthorized extends ApiException {
  const _Unauthorized() : super._(ApiExceptionType.unauthorized);
}
class _NoRecords extends ApiException {
  const _NoRecords([String? msg]) : super._(ApiExceptionType.noRecords, msg);
}
class _Network extends ApiException {
  const _Network() : super._(ApiExceptionType.network);
}
class _Timeout extends ApiException {
  const _Timeout() : super._(ApiExceptionType.timeout);
}

// ── Usage ─────────────────────────────────────────────────────────────────────

// final result = await getPatientInfo(userUnit, barcodeScanRes);
//
// switch (result.status) {
//   case PatientInfoStatus.success:
//     final data = result.data!;
//     // use data['patient_name'], data['uhid'], etc.
//
//   case PatientInfoStatus.notFound:
//     // show "No records found" UI
//
//   case PatientInfoStatus.unauthorized:
//     // clear session → navigate to login
//
//   case PatientInfoStatus.serverError:
//     // show result.message in a snackbar / dialog
// }