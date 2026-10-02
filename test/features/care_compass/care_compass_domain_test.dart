import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/care_compass/domain/entities/care_compass_item.dart';
import 'package:medibook/features/family_care/domain/entities/family_member.dart';
void main(){test('care compass item is value comparable',(){final item=CareCompassItem(id:'prep',title:'Prepare',subtitle:'Checklist',kind:CompassItemKind.preparation,status:CompassItemStatus.now,dueAt:DateTime(2026,1,1),route:'/care/readiness/1',accent:0xffD99B54);expect(item,equals(item));});test('family member access is explicit',(){const member=FamilyMember(id:'x',name:'A',relationship:'Mother',initials:'A',access:FamilyMemberAccess.pending,nextCareLabel:'Review');expect(member.access,FamilyMemberAccess.pending);});}
