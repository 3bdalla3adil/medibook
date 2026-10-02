import 'package:equatable/equatable.dart';

enum CompassItemKind { appointment, medication, preparation, result, habit, followUp }
enum CompassItemStatus { now, next, completed, waiting }

class CareCompassItem extends Equatable {
  const CareCompassItem({required this.id,required this.title,required this.subtitle,required this.kind,required this.status,required this.dueAt,required this.route,required this.accent});
  final String id,title,subtitle,route;
  final CompassItemKind kind;
  final CompassItemStatus status;
  final DateTime dueAt;
  final int accent;
  @override List<Object?> get props=>[id,title,subtitle,kind,status,dueAt,route,accent];
}
