import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageLimitService extends ChangeNotifier {
  static const String _remainingQueriesKey = 'medai_remaining_queries';
  static const String _lastResetTimeKey = 'medai_last_reset_time';
  static const String _isPremiumKey = 'medai_is_premium';

  final SharedPreferences _prefs;
  int _remainingQueries = 5;
  DateTime _lastResetTime = DateTime.now();
  bool _isPremium = false;

  UsageLimitService(this._prefs) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    _isPremium = _prefs.getBool(_isPremiumKey) ?? false;
    _remainingQueries = _prefs.getInt(_remainingQueriesKey) ?? (_isPremium ? 50 : 5);
    
    final lastResetStr = _prefs.getString(_lastResetTimeKey);
    if (lastResetStr != null) {
      try {
        _lastResetTime = DateTime.parse(lastResetStr);
      } catch (_) {
        _lastResetTime = DateTime.now();
        _prefs.setString(_lastResetTimeKey, _lastResetTime.toIso8601String());
      }
    } else {
      _lastResetTime = DateTime.now();
      _prefs.setString(_lastResetTimeKey, _lastResetTime.toIso8601String());
    }
  }

  /// Returns the remaining allowed queries for the current 24-hour cycle.
  int getRemainingRights() {
    return _remainingQueries;
  }

  /// Returns whether the user is a Premium subscriber.
  bool get isPremium => _isPremium;

  /// Sets the premium status and notifies listeners.
  Future<void> setPremium(bool premium) async {
    _isPremium = premium;
    await _prefs.setBool(_isPremiumKey, premium);
    _remainingQueries = premium ? 50 : 5;
    await _prefs.setInt(_remainingQueriesKey, _remainingQueries);
    notifyListeners();
  }

  /// Deducts exactly 1 credit upon a successful, verified API response.
  Future<void> decrementRight() async {
    if (_remainingQueries > 0) {
      _remainingQueries--;
      await _prefs.setInt(_remainingQueriesKey, _remainingQueries);
      notifyListeners();
    }
  }

  /// Compares DateTime.now() with the stored last_reset_time.
  /// If the difference is >= 24 hours, resets the pool and overwrites last_reset_time with the current timestamp.
  Future<void> checkAndResetDailyLimit() async {
    final now = DateTime.now();
    final difference = now.difference(_lastResetTime);
    if (difference.inHours >= 24) {
      _remainingQueries = _isPremium ? 50 : 5;
      _lastResetTime = now;
      await _prefs.setInt(_remainingQueriesKey, _remainingQueries);
      await _prefs.setString(_lastResetTimeKey, _lastResetTime.toIso8601String());
      notifyListeners();
    }
  }

  /// Helper method to reset remaining queries to 0 for testing purposes
  Future<void> testForceExhaustQueries() async {
    _remainingQueries = 0;
    await _prefs.setInt(_remainingQueriesKey, 0);
    notifyListeners();
  }

  /// Helper method to reset last reset time to 25 hours ago for testing purposes
  Future<void> testForcePass24Hours() async {
    _lastResetTime = DateTime.now().subtract(const Duration(hours: 25));
    await _prefs.setString(_lastResetTimeKey, _lastResetTime.toIso8601String());
    notifyListeners();
  }
}
