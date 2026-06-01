import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

class ChatStorageService {
  static const String _sessionsKey = 'medai_chat_sessions';
  final SharedPreferences _prefs;

  ChatStorageService(this._prefs);

  List<ChatSession> getAllSessions() {
    final String? sessionsJson = _prefs.getString(_sessionsKey);
    if (sessionsJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      final sessions = decoded.map((item) => ChatSession.fromJson(item)).toList();
      // Sort by lastInteraction descending
      sessions.sort((a, b) => b.lastInteraction.compareTo(a.lastInteraction));
      return sessions;
    } catch (e) {
      debugPrint('[ChatStorageService] Error decoding sessions: $e');
      return [];
    }
  }

  Future<void> _saveSessions(List<ChatSession> sessions) async {
    final String sessionsJson = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_sessionsKey, sessionsJson);
  }

  Future<void> saveSession(ChatSession session) async {
    final sessions = getAllSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }
    await _saveSessions(sessions);
  }

  Future<void> saveMessage(String sessionId, ChatMessage message) async {
    final sessions = getAllSessions();
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final session = sessions[index];
      final updatedMessages = List<ChatMessage>.from(session.messages)..add(message);
      
      // If title is default and this is the first user message, rename session
      String updatedTitle = session.title;
      if ((session.title == 'New Clinical Case...' || session.title.isEmpty) && message.sender == 'user') {
        updatedTitle = message.text.length > 30 ? '${message.text.substring(0, 30)}...' : message.text;
      }

      sessions[index] = session.copyWith(
        messages: updatedMessages,
        title: updatedTitle,
        lastInteraction: DateTime.now(),
      );
      await _saveSessions(sessions);
    }
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    final sessions = getAllSessions();
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      sessions[index] = sessions[index].copyWith(
        title: newTitle,
        lastInteraction: DateTime.now(),
      );
      await _saveSessions(sessions);
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final sessions = getAllSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await _saveSessions(sessions);
  }
}
