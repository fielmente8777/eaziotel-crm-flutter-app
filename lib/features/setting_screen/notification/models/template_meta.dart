// ============================================================
// TEMPLATE META
//
// Save API har call message ke saath chune hue template ki jaankari
// maangti hai (web bhi bhejta hai):
//   {"name", "language", "bodyText", "variables", "headerVariables",
//    "headerType", "buttons"}
// Ye sab WhatsApp template list se nikalta hai.
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
    // Template ke example values (jaise ["John", "91XXXXXXXX"])
    'variables': body?.example?.bodyText?.firstOrNull ?? <String>[],
    'headerVariables': header?.example?.headerText ?? <String>[],
    'headerType': header?.format,
    'buttons': <dynamic>[],
  };
}
