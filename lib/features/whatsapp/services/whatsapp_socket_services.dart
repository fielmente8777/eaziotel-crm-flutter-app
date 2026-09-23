import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WhatsappSocketService {
  WhatsappSocketService._();

  static const String socketUrl = 'wss://gian-1eve.onrender.com';

  static WebSocketChannel? _channel;

  static bool get isConnected => _channel != null;

  static void connect({required Function(Map<String, dynamic>) onMessage}) {
    // Already connected
    if (_channel != null) {
      print('');
      print('==============================================');
      print('⚠️ WHATSAPP SOCKET ALREADY CONNECTED');
      print('==============================================');
      return;
    }

    print('');
    print('==================================================');
    print('🔌 CONNECTING WHATSAPP SOCKET');
    print('==================================================');
    print('URL: $socketUrl');
    print('==================================================');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(socketUrl));

      print('');
      print('==================================================');
      print('✅ WHATSAPP SOCKET CONNECTED');
      print('==================================================');

      _channel!.stream.listen(
        (message) {
          print('');
          print('==================================================');
          print('📡 RAW SOCKET MESSAGE RECEIVED');
          print('==================================================');

          try {
            // --------------------------------------------------
            // RAW MESSAGE
            // --------------------------------------------------

            print('RAW TYPE: ${message.runtimeType}');
            print('RAW DATA: $message');

            // --------------------------------------------------
            // DECODE
            // --------------------------------------------------

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

            // --------------------------------------------------
            // FULL DECODED DATA
            // --------------------------------------------------

            print('');
            print('--------------------------------------------------');
            print('📦 DECODED SOCKET DATA');
            print('--------------------------------------------------');

            print(decoded);

            // --------------------------------------------------
            // CHECK MAP
            // --------------------------------------------------

            if (decoded is! Map) {
              print('');
              print('⚠️ SOCKET DATA IS NOT A MAP');
              print('TYPE: ${decoded.runtimeType}');
              print('==================================================');

              return;
            }

            final data = Map<String, dynamic>.from(decoded);

            // --------------------------------------------------
            // EVENT
            // --------------------------------------------------

            final event = data['event'];

            print('');
            print('==================================================');
            print('📡 SOCKET EVENT');
            print('==================================================');
            print('EVENT: $event');
            print('==================================================');

            // --------------------------------------------------
            // EVENT DATA
            // --------------------------------------------------

            final eventData = data['data'];

            print('');
            print('--------------------------------------------------');
            print('📨 EVENT DATA');
            print('--------------------------------------------------');
            print(eventData);
            print('--------------------------------------------------');

            // --------------------------------------------------
            // WHATSAPP NEW MESSAGE
            // --------------------------------------------------

            if (event == 'WHATSAPP_NEW_MESSAGE') {
              print('');
              print('==================================================');
              print('📩 WHATSAPP_NEW_MESSAGE RECEIVED');
              print('==================================================');

              if (eventData is Map) {
                print(
                  'Conversation ID: '
                  '${eventData['conversationId']}',
                );

                print(
                  'Message ID: '
                  '${eventData['messageId']}',
                );

                print(
                  'Sender: '
                  '${eventData['sender']}',
                );

                print(
                  'From: '
                  '${eventData['from']}',
                );

                print(
                  'To: '
                  '${eventData['to']}',
                );

                print(
                  'Direction: '
                  '${eventData['direction']}',
                );

                print(
                  'Message Type: '
                  '${eventData['messageType']}',
                );

                print(
                  'Body: '
                  '${eventData['body']}',
                );

                print(
                  'Status: '
                  '${eventData['status']}',
                );

                print(
                  'Name: '
                  '${eventData['name']}',
                );
              }

              print('==================================================');
            }

            // --------------------------------------------------
            // WHATSAPP MESSAGE STATUS
            // --------------------------------------------------

            if (event == 'WHATSAPP_MESSAGE_STATUS') {
              print('');
              print('==================================================');
              print('📨 WHATSAPP_MESSAGE_STATUS RECEIVED');
              print('==================================================');

              if (eventData is Map) {
                print(
                  'Message ID: '
                  '${eventData['messageId']}',
                );

                print(
                  'Status: '
                  '${eventData['status']}',
                );

                print(
                  'Phone Number ID: '
                  '${eventData['phoneNumberId']}',
                );
              }

              print('==================================================');
            }

            // --------------------------------------------------
            // WHATSAPP NEW CONVERSATION
            // --------------------------------------------------

            if (event == 'WHATSAPP_NEW_CONVERSATION') {
              print('');
              print('==================================================');
              print('🆕 WHATSAPP_NEW_CONVERSATION RECEIVED');
              print('==================================================');

              print(eventData);

              print('==================================================');
            }

            // --------------------------------------------------
            // UNKNOWN EVENT
            // --------------------------------------------------

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

            // --------------------------------------------------
            // SEND TO CONTROLLER
            // --------------------------------------------------

            onMessage(data);

            print('');
            print('==================================================');
            print('📡 SOCKET EVENT HANDLED');
            print('==================================================');
            print('EVENT: $event');
            print('==================================================');
          } catch (e, stackTrace) {
            print('');
            print('==================================================');
            print('❌ SOCKET JSON PARSE ERROR');
            print('==================================================');
            print('ERROR: $e');
            print('STACK: $stackTrace');
            print('==================================================');
          }
        },

        onError: (error) {
          print('');
          print('==================================================');
          print('❌ WHATSAPP SOCKET ERROR');
          print('==================================================');
          print(error);
          print('==================================================');

          _channel = null;
        },

        onDone: () {
          print('');
          print('==================================================');
          print('🔴 WHATSAPP SOCKET CLOSED');
          print('==================================================');
          print('==================================================');

          _channel = null;
        },

        cancelOnError: false,
      );
    } catch (e, stackTrace) {
      print('');
      print('==================================================');
      print('❌ WHATSAPP SOCKET CONNECTION ERROR');
      print('==================================================');
      print('ERROR: $e');
      print('STACK: $stackTrace');
      print('==================================================');

      _channel = null;
    }
  }

  static void send(Map<String, dynamic> data) {
    if (_channel == null) {
      print('');
      print('⚠️ SOCKET SEND FAILED');
      print('Socket is not connected');
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

      _channel!.sink.add(encodedData);
    } catch (e) {
      print('');
      print('❌ SOCKET SEND ERROR: $e');
    }
  }

  static Future<void> disconnect() async {
    print('');
    print('==================================================');
    print('🔌 DISCONNECTING WHATSAPP SOCKET');
    print('==================================================');

    if (_channel == null) {
      print('⚠️ Socket already disconnected');
      print('==================================================');
      return;
    }

    try {
      await _channel!.sink.close();

      print('✅ SOCKET DISCONNECTED');
    } catch (e) {
      print('❌ SOCKET DISCONNECT ERROR: $e');
    }

    _channel = null;

    print('==================================================');
  }
}
