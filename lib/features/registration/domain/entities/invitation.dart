import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/auth_user.dart';

class Invitation extends Equatable {
  const Invitation({required this.token, required this.email, required this.role, required this.organizationId, required this.clinicIds, required this.expiresAt, this.acceptedAt});
  final String token;
  final String email;
  final UserRole role;
  final String organizationId;
  final Set<String> clinicIds;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  bool isExpired(DateTime now) => expiresAt.isBefore(now);
  bool get isUsed => acceptedAt != null;
  @override List<Object?> get props => [token, email, role, organizationId, clinicIds, expiresAt, acceptedAt];
}
