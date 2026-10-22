// ============================================================
// FLOW BUILDER MODELS  (Settings > WhatsApp > Flows > Create Flow)
//
// WhatsApp Flow = a form that opens inside WhatsApp.
//   FlowTemplateOption : what kind of flow (Lead Generation / Feedback)
//   FlowScreenDraft    : one page of the form (title + fields)
//   FlowFieldDraft     : one question (label, type, required)
//
// Sent to the server (POST /api/v1/whatsapp/flow/create):
//   { flowName, category, screens: [ { id, title,
//       fields: [ { label, type, required } ] } ] }
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlowTemplateOption {
  const FlowTemplateOption({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;

  /// Server name: LEAD_GENERATION / FEEDBACK_FORM
  final String category;
  final String title;
  final String description;
  final IconData icon;

  static const List<FlowTemplateOption> all = [
    FlowTemplateOption(
      id: 'lead-generation',
      category: 'LEAD_GENERATION',
      title: 'Lead Generation',
      description: 'Request user sign up and generate leads effortlessly.',
      icon: Icons.person_add_alt_1_outlined,
    ),
    FlowTemplateOption(
      id: 'feedback-form',
      category: 'FEEDBACK_FORM',
      title: 'Feedback Form',
      description: 'Send feedback forms to customers and get feedback easily.',
      icon: Icons.rate_review_outlined,
    ),
  ];
}

/// Field types (same as web)
enum FlowFieldType {
  text('text', 'Short Answer', Icons.short_text),
  textarea('textarea', 'Long Text', Icons.notes),
  email('email', 'Email', Icons.alternate_email),
  number('number', 'Number', Icons.pin_outlined),
  date('date', 'Date', Icons.calendar_today_outlined);

  const FlowFieldType(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

class FlowFieldDraft {
  FlowFieldDraft({String label = 'New Field'})
    : label = TextEditingController(text: label);

  final TextEditingController label;
  final type = FlowFieldType.text.obs;
  final required = false.obs;

  Map<String, dynamic> toJson() => {
    'label': label.text.trim(),
    'type': type.value.value,
    'required': required.value,
  };

  void dispose() => label.dispose();
}

class FlowScreenDraft {
  FlowScreenDraft({required this.id, String title = 'New Screen'})
    : title = TextEditingController(text: title);

  final int id;
  final TextEditingController title;
  final fields = <FlowFieldDraft>[].obs;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title.text.trim(),
    'fields': fields.map((f) => f.toJson()).toList(),
  };

  void dispose() {
    title.dispose();
    for (final f in fields) {
      f.dispose();
    }
  }
}
