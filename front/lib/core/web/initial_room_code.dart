/// Reads `?room=CODE` from the page URL (Flutter web).
String? readInitialRoomCodeFromUrl() {
  final room = Uri.base.queryParameters['room'];
  if (room == null || room.trim().isEmpty) {
    return null;
  }
  return room.trim().toUpperCase();
}
