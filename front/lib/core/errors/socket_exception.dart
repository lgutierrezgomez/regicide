class SocketFailure implements Exception {
  const SocketFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
