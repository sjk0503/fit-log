import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _homeKey = 'tutorial_home_shown';
  static const String _cameraKey = 'tutorial_camera_shown';

  Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_onboardingKey) ?? false);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<bool> shouldShowHomeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_homeKey) ?? false);
  }

  Future<bool> shouldShowCameraTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_cameraKey) ?? false);
  }

  Future<void> completeHomeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeKey, true);
  }

  Future<void> completeCameraTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cameraKey, true);
  }

  /// Resets all tutorial flags so they appear again. Used by a "restart
  /// onboarding" action in Settings.
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_homeKey);
    await prefs.remove(_cameraKey);
  }
}
