import 'dart:convert';

import 'package:eazotel/core/api/api_clint_servic.dart';
import 'package:eazotel/core/constants/api_base_url.dart';
import 'package:eazotel/features/dashboard_screen/models/leads_responce_modle.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LeadDetailsNotesController extends GetxController {
  final LeadModel leads;

  LeadDetailsNotesController(this.leads);

  final RxList<LeadNoteModel> notes = <LeadNoteModel>[].obs;
  final RxBool isLoading = false.obs;

  String get leadId => leads.leadId ?? leads.id ?? '';
  String get hid => leads.hid ?? leads.hId ?? '';

  @override
  void onInit() {
    super.onInit();
    notes.assignAll(leads.notes ?? <LeadNoteModel>[]);
  }

  Future<bool> createNote({
    required String activitySource,
    required String message,
  }) async {
    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty) {
      return false;
    }

    if (leadId.isEmpty || hid.isEmpty) {
      return false;
    }

    try {
      isLoading.value = true;

      final newNote = LeadNoteModel(
        activitySource: activitySource,
        message: cleanMessage,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );

      final List<LeadNoteModel> updatedNotes = [...notes, newNote];

      final body = {
        'notes': updatedNotes.map((note) => note.toJson()).toList(),
      };

      final response = await ApiClient.put(
        '/api/v1/leads/$leadId/update?hid=$hid',
        body: body,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        notes.assignAll(updatedNotes);
        leads.notes = updatedNotes;
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Create Note Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteNote(int index) async {
    if (index < 0 || index >= notes.length) {
      return false;
    }

    if (leadId.isEmpty || hid.isEmpty) {
      return false;
    }

    try {
      isLoading.value = true;

      final List<LeadNoteModel> updatedNotes = List<LeadNoteModel>.from(notes);

      updatedNotes.removeAt(index);

      final body = {
        'notes': updatedNotes.map((note) => note.toJson()).toList(),
      };

      final response = await ApiClient.put(
        '/api/v1/leads/$leadId/update?hid=$hid',
        body: body,
        authenticated: true,
        baseUrl: BaseUrl.production2,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        notes.assignAll(updatedNotes);
        leads.notes = updatedNotes;
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Delete Note Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
