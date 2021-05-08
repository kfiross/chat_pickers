import 'package:flutter/material.dart';

PageController useMyPageController(ValueNotifier<int> tabSelected) {
  final PageController pageController = PageController();

  pageController.addListener(() {
    int currPage = pageController.page!.toInt();
    tabSelected.value = currPage;
  });

  return pageController;
}
