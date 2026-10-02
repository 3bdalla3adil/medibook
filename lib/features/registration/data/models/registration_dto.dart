import '../../domain/entities/registration_draft.dart';
class RegistrationDto { const RegistrationDto(this.email, this.password, this.displayName); final String email,password,displayName; Map<String,dynamic> toJson()=>{'email':email,'password':password,'display_name':displayName}; factory RegistrationDto.fromDomain(RegistrationDraft d)=>RegistrationDto(d.email,d.password,d.displayName); }
