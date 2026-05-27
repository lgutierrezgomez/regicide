/// Builds a shareable join URL with `?room=CODE` for the current origin (Flutter web).
String buildRoomInviteUrl(String roomCode) {
  final code = roomCode.trim().toUpperCase();
  final base = Uri.base;
  final path = base.path.isEmpty ? '/' : base.path;
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: path,
    queryParameters: {'room': code},
  ).toString();
}
