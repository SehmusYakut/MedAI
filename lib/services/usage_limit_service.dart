import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'central_config.dart';

class UsageLimitService extends ChangeNotifier {
  static const String _remainingQueriesKey = 'tipakademi_remaining_queries';
  static const String _lastResetTimeKey = 'tipakademi_last_reset_time';
  static const String _isPremiumKey = 'tipakademi_is_premium';
  static const String _offTopicCounterKey = 'tipakademi_off_topic_counter';
  static const String _offTopicLastResetDayKey = 'tipakademi_off_topic_last_reset_day';

  final SharedPreferences _prefs;
  int _remainingQueries = 5;
  DateTime _lastResetTime = DateTime.now();
  bool _isPremium = false;
  bool _listenerInitialized = false;

  UsageLimitService(this._prefs) {
    _loadFromPrefs();
    // Sync the status asynchronously on startup to verify against active entitlements
    syncSubscriptionStatus();
  }

  void _initRevenueCatListener() {
    if (CentralConfig.isRevenueCatMockMode) return;
    if (_listenerInitialized) return;
    try {
      Purchases.addCustomerInfoUpdateListener((customerInfo) async {
        final isPremiumActive = customerInfo.entitlements.all['TipAkademi Pro']?.isActive ?? false;
        await setPremium(isPremiumActive);
      });
      _listenerInitialized = true;
    } catch (e) {
      debugPrint('[Developer Warning] Failed to register RevenueCat listener: $e');
    }
  }

  /// Synchronizes subscription status dynamically with RevenueCat server.
  Future<void> syncSubscriptionStatus() async {
    if (CentralConfig.isRevenueCatMockMode) return;
    try {
      // Ensure RevenueCat is configured before calling any Purchases API
      await CentralConfig.configurePurchases();

      if (await Purchases.isConfigured) {
        _initRevenueCatListener();

        // Sync authenticated Firebase user with RevenueCat
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          final rcAppUserId = await Purchases.appUserID;
          if (rcAppUserId != firebaseUser.uid) {
            await Purchases.logIn(firebaseUser.uid);
          }
        } else {
          final rcAppUserId = await Purchases.appUserID;
          if (!rcAppUserId.startsWith(r'$RCAnonymousID')) {
            await Purchases.logOut();
          }
        }

        final customerInfo = await Purchases.getCustomerInfo();
        final isPremiumActive = customerInfo.entitlements.all['TipAkademi Pro']?.isActive ?? false;
        await setPremium(isPremiumActive);
      }
    } catch (e) {
      debugPrint('[Developer Warning] Failed to sync subscription status: $e');
    }
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
    _checkAndResetOffTopicDaily();
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
    _checkAndResetOffTopicDaily();
  }

  /// Returns the current off-topic counter, auto-checking calendar day reset first.
  int getOffTopicCounter() {
    _checkAndResetOffTopicDaily();
    return _prefs.getInt(_offTopicCounterKey) ?? 0;
  }

  /// Increments the off-topic counter by 1, auto-checking calendar day reset first.
  Future<void> incrementOffTopicCounter() async {
    _checkAndResetOffTopicDaily();
    int current = _prefs.getInt(_offTopicCounterKey) ?? 0;
    current++;
    await _prefs.setInt(_offTopicCounterKey, current);
    notifyListeners();
  }

  /// Resets the off-topic counter to 0.
  Future<void> resetOffTopicCounter() async {
    await _prefs.setInt(_offTopicCounterKey, 0);
    notifyListeners();
  }

  /// Verifies if a new calendar day has begun, and if so, resets the off-topic counter to 0.
  void _checkAndResetOffTopicDaily() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastResetDay = _prefs.getString(_offTopicLastResetDayKey);
    if (lastResetDay != todayStr) {
      _prefs.setInt(_offTopicCounterKey, 0);
      _prefs.setString(_offTopicLastResetDayKey, todayStr);
    }
  }
}
