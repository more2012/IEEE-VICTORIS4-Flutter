import 'package:awan/features/onboarding/controllers/onboarding_controller.dart';
import 'package:awan/features/onboarding/widgets/onboarding_widget.dart';
import 'package:awan/features/onboarding/models/onboarding_model.dart';
import 'package:awan/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<OnboardingController>(context);

    final List<OnboardingModel> onboardingPages = [
      OnboardingModel(
        AppConstants.onboardingImage1,
        "Welcome to 3AWN!",
        "Your health companion. We'll help you stay on track with your medications.",
      ),
      OnboardingModel(
        AppConstants.onboardingImage2,
        "Smart reminder for your medications",
        "Choose your dose and time... we'll remind you at the right moment",
      ),
      OnboardingModel(
        AppConstants.onboardingImage3,
        "Stay safe with one-tap SOS",
        "In case of emergency, send your location instantly to your trusted contacts",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar and Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (only show if not first page)
                  controller.currentPageIndex > 0
                      ? IconButton(
                          onPressed: () => controller.previousPage(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                        )
                      : const SizedBox(width: 40),

                  // Skip button (only show if not last page)
                  if (!controller.isLastPage)
                    TextButton(
                      onPressed: () =>
                          controller.jumpToLastPage(onboardingPages.length),
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (index) {
                  controller.onPageChanged(index, onboardingPages.length);
                },
                itemBuilder: (context, index) {
                  return OnboardingWidget(item: onboardingPages[index]);
                },
              ),
            ),

            // Indicators and Navigation Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.currentPageIndex == index
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Navigation Button
                  controller.isLastPage
                      ? // Get Started Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppConstants.loginRoute,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Get Started",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        )
                      : // Next Button (Circular)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => controller.nextPage(),
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
