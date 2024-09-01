import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  var onboardingCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    getOnboardingStatus();
  }

  Future<void> getOnboardingStatus() async {
    final preferences = await SharedPreferences.getInstance();
    onboardingCompleted.value = preferences.getBool('onboardingCompleted') ?? false;
  }

  Future<void> completeOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool('onboardingCompleted', true);
    onboardingCompleted.value = true;
  }
}