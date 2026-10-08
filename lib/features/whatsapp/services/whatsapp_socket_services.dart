import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WhatsappSocketService {
  WhatsappSocketService._();

  static const String socketUrl = 'wss://gian-1eve.onrender.com';

  static WebSocketChannel? _channel;

  static Timer? _reconnectTimer;

  static bool _isConnecting = false;
  static bool _isManuallyDisconnected = false;

  static Function(Map<String, dynamic>)? _onMessage;

  static bool get isConnected => _channel != null;

  // ============================================================
  // CONNECT
  // ============================================================

  static void connect({required Function(Map<String, dynamic>) onMessage}) {
    _onMessage = onMessage;

    // Manual disconnect ke baad connect kiya gaya hai
    _isManuallyDisconnected = false;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    // Already connected
    if (_channel != null) {
      print('⚠️ WHATSAPP SOCKET ALREADY CONNECTED');
      return;
    }

    // Already connecting
    if (_isConnecting) {
      print('⚠️ WHATSAPP SOCKET CONNECTION ALREADY IN PROGRESS');
      return;
    }

    _connectInternal();
  }

  // ============================================================
  // INTERNAL CONNECT
  // ============================================================

  static Future<void> _connectInternal() async {
    if (_isManuallyDisconnected) {
      print('⚠️ Socket manually disconnected. Reconnect cancelled.');
      return;
    }

    if (_channel != null) {
      return;
    }

    if (_isConnecting) {
      return;
    }

    _isConnecting = true;

    print('');
    print('==================================================');
    print('🔌 CONNECTING WHATSAPP SOCKET');
    print('==================================================');
    print('URL: $socketUrl');
    print('==================================================');

    WebSocketChannel? channel;

    try {
      channel = WebSocketChannel.connect(Uri.parse(socketUrl));

      // connect() turant return ho jata hai. Asli connection ka result
      // "ready" me aata hai — internet na ho (Failed host lookup) to error
      // yahin milta hai. Ise await na karein to wo error unhandled reh
      // jata hai aur app ko rok deta hai.
      await channel.ready.timeout(const Duration(seconds: 15));
    } catch (e) {
      print('');
      print('==================================================');
      print('❌ WHATSAPP SOCKET CONNECTION ERROR');
      print('==================================================');
      print('ERROR: $e');
      print('==================================================');

      _isConnecting = false;

      _closeQuietly(channel);

      _scheduleReconnect();

      return;
    }

    _isConnecting = false;

    // Connect hote hote disconnect() call ho gaya
    if (_isManuallyDisconnected) {
      _closeQuietly(channel);
      return;
    }

    _channel = channel;
    _reconnectAttempts = 0;

    print('');
    print('==================================================');
    print('✅ WHATSAPP SOCKET CONNECTED');
    print('==================================================');

    final connected = channel;

    connected.stream.listen(
      (message) {
        _handleMessage(message);
      },

      onError: (error, stackTrace) {
        print('');
        print('==================================================');
        print('❌ WHATSAPP SOCKET ERROR');
        print('==================================================');
        print('ERROR: $error');
        print('==================================================');

        // Error ke baad automatically reconnect
        _onChannelClosed(connected);
      },

      onDone: () {
        print('');
        print('==================================================');
        print('🔴 WHATSAPP SOCKET CLOSED');
        print('==================================================');

        // Socket khud close hua to automatically reconnect
        _onChannelClosed(connected);
      },

      cancelOnError: false,
    );
  }

  // Purane channel ka late error/close naye channel ko na hata de
  static void _onChannelClosed(WebSocketChannel channel) {
    if (!identical(_channel, channel)) return;

    _channel = null;

    _scheduleReconnect();
  }

  static void _closeQuietly(WebSocketChannel? channel) {
    if (channel == null) return;

    try {
      channel.sink.close().catchError((_) {});
    } catch (_) {}
  }

  // ============================================================
  // RECONNECT
  // ============================================================

  // Lagatar fail hone par wait badhta hai: 3s, 6s, 12s, 24s, phir 30s
  static int _reconnectAttempts = 0;

  static void _scheduleReconnect() {
    // Agar manually disconnect kiya gaya hai
    // to reconnect mat karo
    if (_isManuallyDisconnected) {
      print('🛑 Manual disconnect detected. No reconnect.');
      return;
    }

    // Agar already reconnect timer laga hua hai
    if (_reconnectTimer != null) {
      return;
    }

    final seconds = (3 * (1 << _reconnectAttempts.clamp(0, 4))).clamp(3, 30);

    _reconnectAttempts++;

    print('');
    print('==================================================');
    print('🔄 SOCKET RECONNECT SCHEDULED');
    print('==================================================');
    print('Retrying in $seconds seconds...');
    print('==================================================');

    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _reconnectTimer = null;

      if (_isManuallyDisconnected) {
        print('🛑 Reconnect cancelled because socket was disposed.');
        return;
      }

      print('');
      print('==================================================');
      print('🔄 RESTARTING WHATSAPP SOCKET');
      print('==================================================');

      _connectInternal();
    });
  }
  // ============================================================
  // HANDLE MESSAGE
  // ============================================================

  static void _handleMessage(dynamic message) {
    print('');
    print('==================================================');
    print('📡 RAW SOCKET MESSAGE RECEIVED');
    print('==================================================');

    try {
      print('RAW TYPE: ${message.runtimeType}');
      print('RAW DATA: $message');

      dynamic decoded;

      if (message is String) {
        decoded = jsonDecode(message);
      } else if (message is List<int>) {
        final text = utf8.decode(message);

        print('DECODED TEXT: $text');

        decoded = jsonDecode(text);
      } else {
        print(
          '⚠️ UNKNOWN SOCKET MESSAGE TYPE: '
          '${message.runtimeType}',
        );
        return;
      }

      print('');
      print('--------------------------------------------------');
      print('📦 DECODED SOCKET DATA');
      print('--------------------------------------------------');

      print(decoded);

      if (decoded is! Map) {
        print('');
        print('⚠️ SOCKET DATA IS NOT A MAP');
        print('TYPE: ${decoded.runtimeType}');
        print('==================================================');
        return;
      }

      final data = Map<String, dynamic>.from(decoded);

      final event = data['event'];
      final eventData = data['data'];

      print('');
      print('==================================================');
      print('📡 SOCKET EVENT');
      print('==================================================');
      print('EVENT: $event');
      print('==================================================');

      print('');
      print('--------------------------------------------------');
      print('📨 EVENT DATA');
      print('--------------------------------------------------');
      print(eventData);
      print('--------------------------------------------------');

      // ========================================================
      // WHATSAPP NEW MESSAGE
      // ========================================================

      if (event == 'WHATSAPP_NEW_MESSAGE') {
        print('');
        print('==================================================');
        print('📩 WHATSAPP_NEW_MESSAGE RECEIVED');
        print('==================================================');

        if (eventData is Map) {
          print('Conversation ID: ${eventData['conversationId']}');
          print('Message ID: ${eventData['messageId']}');
          print('Sender: ${eventData['sender']}');
          print('From: ${eventData['from']}');
          print('To: ${eventData['to']}');
          print('Direction: ${eventData['direction']}');
          print('Message Type: ${eventData['messageType']}');
          print('Body: ${eventData['body']}');
          print('Status: ${eventData['status']}');
          print('Name: ${eventData['name']}');
        }

        print('==================================================');
      }

      // ========================================================
      // WHATSAPP MESSAGE STATUS
      // ========================================================

      if (event == 'WHATSAPP_MESSAGE_STATUS') {
        print('');
        print('==================================================');
        print('📨 WHATSAPP_MESSAGE_STATUS RECEIVED');
        print('==================================================');

        if (eventData is Map) {
          print('Message ID: ${eventData['messageId']}');
          print('Status: ${eventData['status']}');
          print('Phone Number ID: ${eventData['phoneNumberId']}');
        }

        print('==================================================');
      }

      // ========================================================
      // WHATSAPP NEW CONVERSATION
      // ========================================================

      if (event == 'WHATSAPP_NEW_CONVERSATION') {
        print('');
        print('==================================================');
        print('🆕 WHATSAPP_NEW_CONVERSATION RECEIVED');
        print('==================================================');

        print(eventData);

        print('==================================================');
      }

      // ========================================================
      // UNKNOWN EVENT
      // ========================================================

      if (event != 'WHATSAPP_NEW_MESSAGE' &&
          event != 'WHATSAPP_MESSAGE_STATUS' &&
          event != 'WHATSAPP_NEW_CONVERSATION') {
        print('');
        print('==================================================');
        print('⚠️ UNKNOWN / NEW SOCKET EVENT');
        print('==================================================');
        print('EVENT: $event');
        print('DATA: $eventData');
        print('==================================================');
      }

      // ========================================================
      // SEND TO CONTROLLER
      // ========================================================

      if (_onMessage != null) {
        try {
          _onMessage!(data);
        } catch (e, stackTrace) {
          print('');
          print('==================================================');
          print('❌ ON MESSAGE CALLBACK ERROR');
          print('==================================================');
          print('ERROR: $e');
          print('STACK: $stackTrace');
          print('==================================================');
        }
      }

      print('');
      print('==================================================');
      print('📡 SOCKET EVENT HANDLED');
      print('==================================================');
      print('EVENT: $event');
      print('==================================================');
    } catch (e, stackTrace) {
      print('');
      print('==================================================');
      print('❌ SOCKET MESSAGE / JSON PARSE ERROR');
      print('==================================================');
      print('ERROR: $e');
      print('STACK: $stackTrace');
      print('==================================================');
    }
  }

  // ============================================================
  // SEND
  // ============================================================

  static void send(Map<String, dynamic> data) {
    final channel = _channel;

    if (channel == null) {
      print('');
      print('⚠️ SOCKET SEND FAILED');
      print('Socket is not connected');
      print('==================================================');
      return;
    }

    try {
      final encodedData = jsonEncode(data);

      print('');
      print('==================================================');
      print('📤 SOCKET SEND');
      print('==================================================');
      print(encodedData);
      print('==================================================');

      channel.sink.add(encodedData);
    } catch (e, stackTrace) {
      print('');
      print('==================================================');
      print('❌ SOCKET SEND ERROR');
      print('==================================================');
      print('ERROR: $e');
      print('STACK: $stackTrace');
      print('==================================================');

      // Send fail hone par bhi reconnect try karo
      _channel = null;

      _scheduleReconnect();
    }
  }

  // ============================================================
  // DISCONNECT / DISPOSE
  // ============================================================

  static Future<void> disconnect() async {
    print('');
    print('==================================================');
    print('🔌 DISCONNECTING WHATSAPP SOCKET');
    print('==================================================');

    // IMPORTANT:
    // Is flag ki wajah se dispose ke baad auto reconnect nahi hoga.
    _isManuallyDisconnected = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final channel = _channel;

    _channel = null;
    _isConnecting = false;

    if (channel == null) {
      print('⚠️ Socket already disconnected');
      print('==================================================');
      return;
    }

    try {
      await channel.sink.close();

      print('✅ SOCKET DISCONNECTED');
    } catch (e, stackTrace) {
      print('');
      print('❌ SOCKET DISCONNECT ERROR');
      print('ERROR: $e');
      print('STACK: $stackTrace');
    }

    print('==================================================');
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  static Future<void> dispose() async {
    print('🗑️ WHATSAPP SOCKET SERVICE DISPOSE');

    await disconnect();

    _onMessage = null;
  }
}
