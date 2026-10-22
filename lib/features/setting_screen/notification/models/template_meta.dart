// ============================================================
// TEMPLATE META
//
// The save API needs info about the chosen template with each call message
// (the web sends it too):
//   {"name", "language", "bodyText", "variables", "headerVariables",
//    "headerType", "buttons"}
// All of this comes from the WhatsApp template list.
// ============================================================

import 'package:eazotel/features/whatsapp/models/whatsappTemaplateModle.dart';
import 'package:get/get.dart';

Map<String, dynamic> templateMetaOf(WhatsappTemplate template) {
  TemplateComponent? part(String type) => template.components?.firstWhereOrNull(
    (c) => c.type?.toUpperCase() == type,
  );

  final header = part('HEADER');
  final body = part('BODY');

  return {
    'name': template.name,
    'language': template.language,
    'bodyText': body?.text?.replaceAll('\r\n', '\n') ?? '',
    // The template's example values (like ["John", "91XXXXXXXX"])
    'variables': body?.example?.bodyText?.firstOrNull ?? <String>[],
    'headerVariables': header?.example?.headerText ?? <String>[],
    'headerType': header?.format,
    'buttons': <dynamic>[],
  };
}
