import 'dart:async';

import 'package:flutter/material.dart';

import 'carousel_options.dart';
import 'carousel_state.dart';
import 'utils.dart';

abstract class CarouselController {
  bool get ready;

  Future<Null> get onReady;

  void nextPage({Duration duration, Curve curve});

  void previousPage({Duration duration, Curve curve});

  void jumpToPage(int page);

  void animateToPage(int page, {Duration duration, Curve curve});

  factory CarouselController() => CarouselControllerImpl();
}

class CarouselControllerImpl implements CarouselController {
  final Completer<Null> _readyCompleter = Completer<Null>();

  CarouselState carouselState;

  set state(CarouselState state) {
    carouselState = state;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  void _setModeController() => carouselState.changeMode(CarouselPageChangedReason.controller);

  @override
  bool get ready => carouselState != null;

  @override
  Future<Null> get onReady => _readyCompleter.future;

  /// Animates the controlled [CarouselSlider] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> nextPage(
      {Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.linear}) async {
    final bool isNeedResetTimer = carouselState.options.pauseAutoPlayOnManualNavigate;
    if (isNeedResetTimer) {
      carouselState.onResetTimer();
    }
    await carouselState.pageController.nextPage(duration: duration, curve: curve);
    _setModeController();
    if (isNeedResetTimer) {
      carouselState.onResumeTimer();
    }
  }

  /// Animates the controlled [CarouselSlider] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> previousPage(
      {Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.linear}) async {
    final bool isNeedResetTimer = carouselState.options.pauseAutoPlayOnManualNavigate;
    if (isNeedResetTimer) {
      carouselState.onResetTimer();
    }
    _setModeController();
    await carouselState.pageController.previousPage(duration: duration, curve: curve);
    if (isNeedResetTimer) {
      carouselState.onResumeTimer();
    }
  }

  /// Changes which page is displayed in the controlled [CarouselSlider].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) {
    final index = getRealIndex(carouselState.pageController.page.toInt(),
        carouselState.realPage - carouselState.initialPage, carouselState.itemCount);

    _setModeController();
    final int pageToJump = carouselState.pageController.page.toInt() + page - index;
    return carouselState.pageController.jumpToPage(pageToJump);
  }

  /// Animates the controlled [CarouselSlider] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  Future<void> animateToPage(int page,
      {Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.linear}) async {
    final bool isNeedResetTimer = carouselState.options.pauseAutoPlayOnManualNavigate;
    if (isNeedResetTimer) {
      carouselState.onResetTimer();
    }
    final index = getRealIndex(carouselState.pageController.page.toInt(),
        carouselState.realPage - carouselState.initialPage, carouselState.itemCount);
    _setModeController();
    await carouselState.pageController.animateToPage(
        carouselState.pageController.page.toInt() + page - index,
        duration: duration,
        curve: curve);
    if (isNeedResetTimer) {
      carouselState.onResumeTimer();
    }
  }
}
