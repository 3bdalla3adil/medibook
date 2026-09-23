import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository({FirebaseFirestore? firestore,FirebaseAuth? auth,FirebaseMessaging? messaging}):_firestore=firestore??FirebaseFirestore.instance,_auth=auth??FirebaseAuth.instance,_messaging=messaging??FirebaseMessaging.instance;
  final FirebaseFirestore _firestore; final FirebaseAuth _auth; final FirebaseMessaging _messaging; final _push=StreamController<AppNotification>.broadcast(); StreamSubscription<RemoteMessage>? _sub;
  CollectionReference<Map<String,dynamic>> get _collection { final uid=_auth.currentUser?.uid; if(uid==null) throw StateError('authenticated_user_required'); return _firestore.collection('users').doc(uid).collection('notifications'); }
  @override Future<Result<List<AppNotification>>> getInAppNotifications()=>guard(() async {final s=await _collection.orderBy('created_at',descending:true).limit(100).get(); return s.docs.map(_map).toList(growable:false);});
  @override Future<Result<void>> markRead(String id)=>guard(()=>_collection.doc(id).update({'read_at':FieldValue.serverTimestamp()}));
  @override Future<Result<void>> initializePush()=>guard(() async {await _messaging.requestPermission(alert:true,badge:true,sound:true); await _messaging.getToken(); await _sub?.cancel(); _sub=FirebaseMessaging.onMessage.listen((m){final id=m.data['notification_id']?.toString(); if(id!=null&&id.isNotEmpty) unawaited(_emit(id));});});
  Future<void> _emit(String id) async {final d=await _collection.doc(id).get(); if(d.exists) _push.add(_mapDoc(d));}
  @override Stream<AppNotification> get pushNotifications=>_push.stream;
  AppNotification _map(QueryDocumentSnapshot<Map<String,dynamic>> d)=>_mapDoc(d);
  AppNotification _mapDoc(DocumentSnapshot<Map<String,dynamic>> d){final x=d.data()??{}; return AppNotification(id:d.id,type:NotificationType.values.firstWhere((v)=>v.name==x['type'],orElse:()=>NotificationType.system),channel:NotificationChannel.inApp,title:x['title']?.toString()??'',body:x['body']?.toString(),createdAt:(x['created_at'] as Timestamp?)?.toDate()??DateTime.now().toUtc(),readAt:(x['read_at'] as Timestamp?)?.toDate(),action:x['action']?.toString());}
  @override Future<Result<void>> dispose() async {await _sub?.cancel(); await _push.close(); return const Ok(null);}
}
