import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:pos_app/utils/app_theme.dart';

class OnboardingService {
  static void showTour(
    BuildContext context, {
    required List<TargetFocus> targets,
    Function()? onFinish,
    Function()? onSkip,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: AppTheme.primaryColor,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: onFinish,
      onSkip: () {
        if (onSkip != null) onSkip();
        return true;
      },
      onClickTarget: (target) {
        debugPrint('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        debugPrint('onClickOverlay: $target');
      },
    ).show(context: context);
  }

  static TargetFocus createTarget({
    required GlobalKey key,
    required String identify,
    required String title,
    required String content,
    ContentAlign align = ContentAlign.bottom,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      alignSkip: Alignment.topRight,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    content,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
