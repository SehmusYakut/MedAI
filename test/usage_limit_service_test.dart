import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medway/services/usage_limit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UsageLimitService Off-Topic Guardrail & Penalty Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      dotenv.loadFromString(envString: 'REVENUECAT_ANDROID_KEY=mock_key\nREVENUECAT_IOS_KEY=mock_key');
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('Initial off-topic counter should be 0', () async {
      final service = UsageLimitService(prefs);
      expect(service.getOffTopicCounter(), 0);
    });

    test('Incrementing off-topic counter should work and persist', () async {
      final service = UsageLimitService(prefs);
      
      await service.incrementOffTopicCounter();
      expect(service.getOffTopicCounter(), 1);

      // Verify persistence by loading a new instance of the service
      final newService = UsageLimitService(prefs);
      expect(newService.getOffTopicCounter(), 1);
    });

    test('Resetting off-topic counter should set it to 0', () async {
      final service = UsageLimitService(prefs);
      await service.incrementOffTopicCounter();
      expect(service.getOffTopicCounter(), 1);

      await service.resetOffTopicCounter();
      expect(service.getOffTopicCounter(), 0);
    });

    test('Should reset off-topic counter on a new calendar day', () async {
      final service = UsageLimitService(prefs);
      await service.incrementOffTopicCounter();
      expect(service.getOffTopicCounter(), 1);

      // Manually set last reset day in SharedPreferences to yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = "${yesterday.year}-${yesterday.month}-${yesterday.day}";
      await prefs.setString('medai_off_topic_last_reset_day', yesterdayStr);

      // Accessing the counter should trigger a check and reset it to 0
      expect(service.getOffTopicCounter(), 0);

      // Verify the reset day key was updated to today
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month}-${now.day}";
      expect(prefs.getString('medai_off_topic_last_reset_day'), todayStr);
    });

    test('Deducting rights work correctly', () async {
      final service = UsageLimitService(prefs);
      // Default free tier is 5 queries
      expect(service.getRemainingRights(), 5);

      await service.decrementRight();
      expect(service.getRemainingRights(), 4);
    });

    test('Transitions between Free and Premium tiers update remaining rights correctly', () async {
      final service = UsageLimitService(prefs);
      expect(service.isPremium, false);
      expect(service.getRemainingRights(), 5);

      await service.setPremium(true);
      expect(service.isPremium, true);
      expect(service.getRemainingRights(), 50);

      await service.setPremium(false);
      expect(service.isPremium, false);
      expect(service.getRemainingRights(), 5);
    });
  });
}
