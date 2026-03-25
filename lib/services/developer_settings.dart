import 'package:shared_preferences/shared_preferences.dart';

class DeveloperSettings {
  static const _verboseKey = 'verbose_errors';
  static const _logCapKey = 'log_cap';
  static const _logAgeKey = 'log_age';

  static bool _verbose = false;
  static int _logCap = 25;
  static int _logAgeDays = 30;

  static bool get verbose => _verbose;
  static int get logCap => _logCap;
  static int get logAgeDays => _logAgeDays;

  static const logCapOptions = [10, 25, 50, 100];
  static const logAgeOptions = [7, 30, 90];

  static String logAgeLabel(int days) {
    return switch (days) {
      7 => 'Last Week',
      30 => 'Last Month',
      90 => 'Last 3 Months',
      _ => '$days days',
    };
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _verbose = prefs.getBool(_verboseKey) ?? false;
    _logCap = prefs.getInt(_logCapKey) ?? 25;
    _logAgeDays = prefs.getInt(_logAgeKey) ?? 30;
  }

  static Future<void> setVerbose(bool value) async {
    _verbose = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_verboseKey, value);
  }

  static Future<void> setLogCap(int value) async {
    _logCap = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_logCapKey, value);
  }

  static Future<void> setLogAgeDays(int value) async {
    _logAgeDays = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_logAgeKey, value);
  }
}
