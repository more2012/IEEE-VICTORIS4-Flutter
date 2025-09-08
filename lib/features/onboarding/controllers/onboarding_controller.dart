import 'package:flutter/material.dart';

class OnboardingController with ChangeNotifier {
  final PageController pageController = PageController();
  bool isLastPage = false;
  int currentPageIndex = 0;

  void onPageChanged(int index, int totalPages) {
    currentPageIndex = index;
    isLastPage = (index == totalPages - 1);
    notifyListeners();
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void jumpToLastPage(int totalPages) {
    pageController.jumpToPage(totalPages - 1);
  }
}
