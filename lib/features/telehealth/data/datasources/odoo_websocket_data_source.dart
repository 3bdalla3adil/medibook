import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
class OdooWebSocketDataSource { OdooWebSocketDataSource(this._channel); final WebSocketChannel _channel; Stream<Map<String,dynamic>> get messages=>_channel.stream.where((e)=>e is String).map((e)=>jsonDecode(e as String) as Map<String,dynamic>); void send(String kind,Map<String,dynamic> payload)=>_channel.sink.add(jsonEncode({'kind':kind,'payload':payload})); Future<void> close()=>_channel.sink.close(); }
