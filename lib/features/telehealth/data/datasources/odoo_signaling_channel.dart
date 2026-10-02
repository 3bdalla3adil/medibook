import 'package:web_socket_channel/web_socket_channel.dart';
import 'odoo_websocket_data_source.dart';

class OdooSignalingChannel {
  const OdooSignalingChannel();
  OdooWebSocketDataSource connect({required Uri endpoint, required String sessionToken}) {
    final uri = endpoint.replace(queryParameters: {...endpoint.queryParameters, 'token': sessionToken});
    return OdooWebSocketDataSource(WebSocketChannel.connect(uri));
  }
}
