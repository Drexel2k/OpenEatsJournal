import 'package:flutter/material.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_state_data.dart';

class OnboardingState extends InheritedWidget {
  const OnboardingState({
    super.key,
    required this.data,
    required super.child,
  });

  final OnboardingStateData data;

  static OnboardingState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OnboardingState>()!;
  }

  @override
  // This method should return true if the old widget's data is different
  // from this widget's data. If true, any widgets that depend on this widget
  // by calling `of()` will be re-built.
  bool updateShouldNotify(OnboardingState oldWidget) {
    if (data.gender != oldWidget.data.gender) {
      return false;
    }

    if (data.birthDay != oldWidget.data.birthDay) {
      return false;
    }

    if (data.height != oldWidget.data.height) {
      return false;
    }

    if (data.weight != oldWidget.data.weight) {
      return false;
    }

    if (data.activityFactor != oldWidget.data.activityFactor) {
      return false;
    }

    if (data.target != oldWidget.data.target) {
      return false;
    }

    return true;
  }
}