import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/errors/api_exception.dart';
import '../../domain/entities/room.dart';
import '../models/room_response.dart';

class RoomApi {
  RoomApi({http.Client? client, AppConfig? config})
      : _client = client ?? http.Client(),
        _config = config ?? AppConfig.instance;

  final http.Client _client;
  final AppConfig _config;

  Uri _uri(String path) => Uri.parse('${_config.apiBaseUrl}$path');

  Future<RoomResponse> createRoom(String displayName) async {
    final response = await _client.post(
      _uri('/rooms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'displayName': displayName}),
    );
    return _parseRoomResponse(response, successStatuses: {201});
  }

  Future<Room> fetchRoom(String roomCode) async {
    final code = roomCode.trim().toUpperCase();
    final response = await _client.get(_uri('/rooms/$code'));
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 404) {
      throw ApiException(
        body['error'] as String? ?? 'Room not found',
        code: body['code'] as String? ?? 'ROOM_NOT_FOUND',
      );
    }
    if (response.statusCode != 200) {
      final message = body['error'] as String? ?? 'Request failed';
      throw ApiException(message, code: body['code'] as String?);
    }

    final roomJson = body['room'];
    if (roomJson is! Map) {
      throw ApiException('Invalid room response');
    }
    return RoomDto.fromJson(Map<String, dynamic>.from(roomJson)).toEntity();
  }

  Future<RoomResponse> joinRoom(String roomCode, String displayName) async {
    final code = roomCode.trim().toUpperCase();
    final response = await _client.post(
      _uri('/rooms/$code/join'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'displayName': displayName}),
    );
    return _parseRoomResponse(response, successStatuses: {200});
  }

  RoomResponse _parseRoomResponse(
    http.Response response, {
    required Set<int> successStatuses,
  }) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (!successStatuses.contains(response.statusCode)) {
      final message = body['error'] as String? ?? 'Request failed';
      final code = body['code'] as String?;
      throw ApiException(message, code: code);
    }

    return RoomResponse.fromJson(body);
  }
}
