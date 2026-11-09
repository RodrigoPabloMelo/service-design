import 'package:flutter/material.dart';
import 'package:studio_app/core/components/base/app_stateless_widget.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/theme/app_theme.dart';

class AppExampleButton extends AppStatelessWidget {
  const AppExampleButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget buildWidget(BuildContext context, AppI18n i18n, AppTheme theme) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(theme.secondaryColor),
        foregroundColor: WidgetStateProperty.all(theme.primaryColor),
      ),
      child: Text(
        text,
        style: theme.titleLargeText.copyWith(
          color: theme.primaryColor,
        ),
      ),
    );
  }
}
