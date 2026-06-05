import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

class ChatStorageService {
  static const String _sessionsKey = 'medai_chat_sessions';
  final SharedPreferences _prefs;

  ChatStorageService(this._prefs);

  String get _currentSessionsKey {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return '${_sessionsKey}_${user.uid}';
    }
    return _sessionsKey;
  }

  List<ChatSession> getAllSessions() {
    final String? sessionsJson = _prefs.getString(_currentSessionsKey);
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
    await _prefs.setString(_currentSessionsKey, sessionsJson);
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

  Future<void> linkGuestSessionsToUser(String userId) async {
    final String? guestSessionsJson = _prefs.getString(_sessionsKey);
    if (guestSessionsJson != null && guestSessionsJson.trim().isNotEmpty) {
      try {
        final List<dynamic> guestDecoded = jsonDecode(guestSessionsJson);
        final guestSessions = guestDecoded.map((item) => ChatSession.fromJson(item)).toList();
        
        if (guestSessions.isNotEmpty) {
          final String userKey = '${_sessionsKey}_$userId';
          final String? userSessionsJson = _prefs.getString(userKey);
          List<ChatSession> userSessions = [];
          if (userSessionsJson != null && userSessionsJson.trim().isNotEmpty) {
            final List<dynamic> userDecoded = jsonDecode(userSessionsJson);
            userSessions = userDecoded.map((item) => ChatSession.fromJson(item)).toList();
          }
          
          // Merge guest sessions into user sessions. Avoid duplicates by ID.
          for (var guestSession in guestSessions) {
            if (!userSessions.any((s) => s.id == guestSession.id)) {
              userSessions.add(guestSession);
            }
          }
          
          // Save merged sessions under user key
          final String mergedJson = jsonEncode(userSessions.map((s) => s.toJson()).toList());
          await _prefs.setString(userKey, mergedJson);
          
          // Clear guest sessions
          await _prefs.remove(_sessionsKey);
        }
      } catch (e) {
        debugPrint('[ChatStorageService] Error linking guest sessions to user: $e');
      }
    }
  }
}
