import 'package:equatable/equatable.dart';

class Player extends Equatable {
  const Player({
    required this.id,
    required this.displayName,
    this.connected = false,
  });

  final String id;
  final String displayName;
  final bool connected;

  @override
  List<Object?> get props => [id, displayName, connected];
}
