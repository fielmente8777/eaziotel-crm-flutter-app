// ============================================================
// CHATBOT FLOW MODELS  (Settings > WhatsApp > WhatsApp Flow)
//
// Web ka "FlowBuilder" (React Flow) jaisa hi data:
//   nodes: [ { id, type, position: {x, y}, data: {...} } ]
//   edges: [ { id, source, sourceHandle, target, type, animated } ]
//
// Node ke type:
//   sendMessage : text / photo / video / audio / document (blocks)
//   button      : sawaal + 3 tak button     (har button ka alag rasta)
//   list        : sawaal + list ke option   (har option ka alag rasta)
//   question    : sawaal, jawab variable me (ek rasta "next")
//   carousel    : photo wale card            (quick reply ka rasta)
//   flow        : WhatsApp form (Create Flow wala) kholta hai
//
// "data" ko waise hi rakhte hain jaisa server bhejta hai, taaki web aur
// app dono ek hi flow badal sakein (koi field gum na ho).
// ============================================================

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

enum ChatbotNodeType {
  sendMessage(
    'sendMessage',
    'Send Message',
    'Text, photo, video, audio or document',
    Icons.chat_bubble_outline,
    Color(0xFF22C55E),
  ),
  button(
    'button',
    'Buttons',
    'Let the guest choose a quick reply button',
    Icons.smart_button_outlined,
    Color(0xFFF97316),
  ),
  list(
    'list',
    'List',
    'Show a list of options to choose from',
    Icons.list_alt,
    Color(0xFF8B5CF6),
  ),
  question(
    'question',
    'Question',
    'Ask something and save the answer',
    Icons.help_outline,
    Color(0xFF0EA5E9),
  ),
  carousel(
    'carousel',
    'Carousel',
    'Swipeable cards with photos',
    Icons.view_carousel_outlined,
    Color(0xFF6366F1),
  ),
  flow(
    'flow',
    'Form Flow',
    'Open a WhatsApp form (from Create Flow)',
    Icons.dynamic_form_outlined,
    Color(0xFF14B8A6),
  ),
  unknown('', 'Step', '', Icons.circle_outlined, Color(0xFF94A3B8));

  const ChatbotNodeType(
    this.key,
    this.label,
    this.description,
    this.icon,
    this.color,
  );

  /// Server wala naam
  final String key;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  /// "Add step" menu me dikhne wale
  static const addable = [sendMessage, button, list, question, carousel, flow];

  static ChatbotNodeType from(String? key) =>
      values.firstWhere((t) => t.key == key, orElse: () => unknown);
}

/// Node se nikalne wala ek rasta (button / option / next)
class ChatbotOutput {
  const ChatbotOutput(this.handle, this.label);

  /// React Flow ka sourceHandle (null = node ka akela rasta)
  final String? handle;
  final String label;

  String get key => handle ?? '';
}

// ============================================================
// HELPERS
// ============================================================

Map<String, dynamic> chatbotMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<dynamic> chatbotList(dynamic v) => v is List ? v : const [];

/// JSON ki gehri copy (editor me badlo, Cancel par asli na badle)
Map<String, dynamic> chatbotDeepCopy(Map<String, dynamic> data) =>
    chatbotMap(jsonDecode(jsonEncode(data)));

final _random = Random();

/// Web ke uuid jaisa id
String chatbotId([String? prefix]) {
  String hex(int n) =>
      List.generate(n, (_) => _random.nextInt(16).toRadixString(16)).join();
  final id = '${hex(8)}-${hex(4)}-4${hex(3)}-${hex(4)}-${hex(12)}';
  return prefix == null ? id : '${prefix}_$id';
}

// ============================================================
// NODE
// ============================================================

class ChatbotNode {
  ChatbotNode({
    required this.id,
    required this.typeKey,
    required this.x,
    required this.y,
    Map<String, dynamic>? data,
    Map<String, dynamic>? extra,
  }) : data = data ?? {},
       extra = extra ?? {};

  final String id;
  final String typeKey;
  double x;
  double y;
  Map<String, dynamic> data;

  /// Server ke baaki field (width, height ...) jaise the waise wapas
  final Map<String, dynamic> extra;

  ChatbotNodeType get type => ChatbotNodeType.from(typeKey);

  factory ChatbotNode.fromJson(Map<String, dynamic> json) {
    final position = chatbotMap(json['position']);
    num n(dynamic v) => v is num ? v : num.tryParse('$v') ?? 0;

    return ChatbotNode(
      id: (json['id'] ?? '').toString(),
      typeKey: (json['type'] ?? '').toString(),
      x: n(position['x']).toDouble(),
      y: n(position['y']).toDouble(),
      data: chatbotMap(json['data']),
      extra: Map<String, dynamic>.from(json)
        ..removeWhere(
          (k, _) => const ['id', 'type', 'position', 'data'].contains(k),
        ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    'id': id,
    'type': typeKey,
    'position': {'x': x, 'y': y},
    'data': data,
  };

  /// Naya node (web ke addNode jaisa shuru ka data)
  factory ChatbotNode.create(ChatbotNodeType type, double x, double y) {
    return ChatbotNode(
      id: chatbotId(),
      typeKey: type.key,
      x: x,
      y: y,
      data: defaultData(type),
    );
  }

  static Map<String, dynamic> defaultData(ChatbotNodeType type) {
    switch (type) {
      case ChatbotNodeType.sendMessage:
        return {'blocks': []};
      case ChatbotNodeType.button:
        return {
          'type': 'interactive',
          'interactive': {
            'type': 'button',
            'body': {'text': 'Ask a question here'},
            'action': {
              'buttons': [
                {
                  'type': 'reply',
                  'reply': {'id': chatbotId('btn_1'), 'title': 'Answer 1'},
                },
              ],
            },
          },
          'variable': '',
        };
      case ChatbotNodeType.list:
        return {
          'type': 'interactive',
          'interactive': {
            'type': 'list',
            'body': {'text': 'Select an option'},
            'action': {
              'button': 'Choose',
              'sections': [
                {
                  'title': 'Section 1',
                  'rows': [
                    {'id': chatbotId('row_1_1'), 'title': 'Option 1'},
                  ],
                },
              ],
            },
          },
          'variable': '',
        };
      case ChatbotNodeType.question:
        return {
          'question': 'Ask a question here',
          'variable': '',
          'type': 'text',
          'required': false,
        };
      case ChatbotNodeType.carousel:
        return {
          'type': 'interactive',
          'interactive': {
            'type': 'carousel',
            'body': {'text': 'Choose an option'},
            'action': {'cards': []},
          },
          'variable': '',
        };
      case ChatbotNodeType.flow:
        return {
          'type': 'interactive',
          'interactive': {
            'type': 'flow',
            'body': {'text': 'Please fill in your details below 👇'},
            'footer': {'text': 'Powered by Eazotel'},
            'action': {
              'name': 'flow',
              'parameters': {
                'flow_message_version': '3',
                'flow_id': '',
                'flow_cta': 'Fill Details',
                'flow_action': 'navigate',
                'flow_action_payload': {'screen': ''},
              },
            },
          },
        };
      case ChatbotNodeType.unknown:
        return {};
    }
  }

  // ---------- Rasta (outputs) ----------

  List<ChatbotOutput> get outputs => outputsOf(typeKey, data);

  /// Data se rasta nikalo (editor me bhi kaam aata hai)
  static List<ChatbotOutput> outputsOf(
    String typeKey,
    Map<String, dynamic> data,
  ) {
    final interactive = chatbotMap(data['interactive']);
    final action = chatbotMap(interactive['action']);

    switch (ChatbotNodeType.from(typeKey)) {
      case ChatbotNodeType.button:
        return [
          for (final b in chatbotList(action['buttons']))
            if (chatbotMap(chatbotMap(b)['reply'])['id'] != null)
              ChatbotOutput(
                chatbotMap(chatbotMap(b)['reply'])['id'].toString(),
                (chatbotMap(chatbotMap(b)['reply'])['title'] ?? 'Button')
                    .toString(),
              ),
        ];
      case ChatbotNodeType.list:
        return [
          for (final s in chatbotList(action['sections']))
            for (final r in chatbotList(chatbotMap(s)['rows']))
              if (chatbotMap(r)['id'] != null)
                ChatbotOutput(
                  chatbotMap(r)['id'].toString(),
                  (chatbotMap(r)['title'] ?? 'Option').toString(),
                ),
        ];
      case ChatbotNodeType.carousel:
        return [
          for (final card in chatbotList(action['cards']))
            for (final b in chatbotList(
              chatbotMap(chatbotMap(card)['action'])['buttons'],
            ))
              if (chatbotMap(chatbotMap(b)['quick_reply'])['id'] != null)
                ChatbotOutput(
                  chatbotMap(chatbotMap(b)['quick_reply'])['id'].toString(),
                  (chatbotMap(chatbotMap(b)['quick_reply'])['title'] ??
                          'Button')
                      .toString(),
                ),
          const ChatbotOutput('default', 'Default'),
        ];
      case ChatbotNodeType.question:
        return const [ChatbotOutput('next', 'Next')];
      case ChatbotNodeType.flow:
        return const [ChatbotOutput(null, 'After form')];
      case ChatbotNodeType.sendMessage:
      case ChatbotNodeType.unknown:
        return const [ChatbotOutput(null, 'Next')];
    }
  }

  // ---------- Card par chhota sa matlab ----------

  String get summary {
    final interactive = chatbotMap(data['interactive']);
    final body = chatbotMap(interactive['body'])['text']?.toString() ?? '';

    switch (type) {
      case ChatbotNodeType.sendMessage:
        final blocks = chatbotList(data['blocks']).map(chatbotMap).toList();
        if (blocks.isEmpty) return 'Empty message. Tap to add content.';
        final first = blocks.first;
        final text = (first['title'] ?? '').toString().trim();
        final kinds = blocks.map((b) => b['type']).toSet().join(', ');
        return text.isNotEmpty
            ? text
            : '${blocks.length} item${blocks.length > 1 ? 's' : ''} ($kinds)';
      case ChatbotNodeType.question:
        final q = (data['question'] ?? data['message'] ?? '').toString();
        final v = (data['variable'] ?? '').toString();
        return v.isEmpty ? q : '$q\n→ saved in $v';
      case ChatbotNodeType.carousel:
        final cards = chatbotList(chatbotMap(interactive['action'])['cards']);
        return '$body\n${cards.length} card${cards.length == 1 ? '' : 's'}';
      case ChatbotNodeType.flow:
        final p = chatbotMap(chatbotMap(interactive['action'])['parameters']);
        final cta = (p['flow_cta'] ?? 'Open Flow').toString();
        return '$body\n[$cta]';
      default:
        return body.isEmpty ? type.label : body;
    }
  }
}

// ============================================================
// EDGE (teer: ek node se dusre tak)
// ============================================================

class ChatbotEdge {
  ChatbotEdge({
    required this.source,
    required this.target,
    this.sourceHandle,
    Map<String, dynamic>? extra,
  }) : extra = extra ?? {};

  final String source;
  final String target;
  final String? sourceHandle;
  final Map<String, dynamic> extra;

  String get handleKey => sourceHandle ?? '';

  factory ChatbotEdge.connect({
    required String source,
    required String target,
    String? sourceHandle,
  }) {
    return ChatbotEdge(
      source: source,
      target: target,
      sourceHandle: sourceHandle,
      extra: {
        // React Flow jaisa id
        'id': 'reactflow__edge-$source${sourceHandle ?? ''}-$target',
        'type': 'smoothstep',
        'animated': true,
        'targetHandle': null,
      },
    );
  }

  factory ChatbotEdge.fromJson(Map<String, dynamic> json) {
    final handle = json['sourceHandle'];
    return ChatbotEdge(
      source: (json['source'] ?? '').toString(),
      target: (json['target'] ?? '').toString(),
      sourceHandle: handle == null || '$handle'.isEmpty ? null : '$handle',
      extra: Map<String, dynamic>.from(json)
        ..removeWhere(
          (k, _) => const ['source', 'target', 'sourceHandle'].contains(k),
        ),
    );
  }

  Map<String, dynamic> toJson() => {
    ...extra,
    'source': source,
    'sourceHandle': sourceHandle,
    'target': target,
  };
}

// ============================================================
// GET /api/v1/whatsapp/flow?hid=  -> result.docs.flow {nodes, edges}
// ============================================================

class ChatbotFlowResponse {
  final bool? success;
  final int? responseStatusCode;
  final String? responseMessage;

  /// Server par flow ka _id (auto message ke "Flow" me yahi chunte hain)
  final String flowId;
  final List<ChatbotNode> nodes;
  final List<ChatbotEdge> edges;

  ChatbotFlowResponse({
    this.success,
    this.responseStatusCode,
    this.responseMessage,
    this.flowId = '',
    this.nodes = const [],
    this.edges = const [],
  });

  factory ChatbotFlowResponse.fromJson(Map<String, dynamic> json) {
    final docs = chatbotMap(chatbotMap(json['result'])['docs']);
    var flow = docs['flow'];
    if (flow is List) flow = flow.isEmpty ? null : flow.first;
    final f = chatbotMap(flow);

    return ChatbotFlowResponse(
      success: json['success'] as bool?,
      responseStatusCode: json['responseStatusCode'] as int?,
      responseMessage: json['responseMessage']?.toString(),
      flowId: (f['_id'] ?? '').toString(),
      nodes: chatbotList(
        f['nodes'],
      ).map((e) => ChatbotNode.fromJson(chatbotMap(e))).toList(),
      edges: chatbotList(
        f['edges'],
      ).map((e) => ChatbotEdge.fromJson(chatbotMap(e))).toList(),
    );
  }
}
