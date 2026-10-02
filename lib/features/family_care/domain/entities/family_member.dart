import 'package:equatable/equatable.dart';

enum FamilyMemberAccess { owner, shared, pending }
class FamilyMember extends Equatable { const FamilyMember({required this.id,required this.name,required this.relationship,required this.initials,required this.access,required this.nextCareLabel,this.isSelf=false}); final String id,name,relationship,initials,nextCareLabel; final FamilyMemberAccess access; final bool isSelf; @override List<Object?> get props=>[id,name,relationship,initials,access,nextCareLabel,isSelf]; }
