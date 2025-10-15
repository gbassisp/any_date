/// Exception thrown when date parsing fails.
class DateParsingException implements Exception {
  /// Creates a [DateParsingException] with the given [message].
  DateParsingException(this.message, [this.innerException, this.stackTrace]);

  /// The error message.
  final String message;

  /// Optional inner exception.
  final Exception? innerException;

  /// The stack trace at the point where the exception was thrown.
  final StackTrace? stackTrace;

  @override
  String toString() => 'DateParsingException: $message\n$stackTrace';
}
