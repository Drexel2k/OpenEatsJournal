import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  late PageController _pageViewController;
  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        PageView(
          /// [PageView.scrollDirection] defaults to [Axis.horizontal].
          /// Use [Axis.vertical] to scroll vertically.
          controller: _pageViewController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Center(child: Text("First Page", style: textTheme.titleLarge)),
            Center(child: Text("Second Page", style: textTheme.titleLarge)),
            Center(child: Text("Third Page", style: textTheme.titleLarge)),
          ],
        ),
      ],
    );
  }
}