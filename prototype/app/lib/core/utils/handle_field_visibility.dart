// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studio_app/core/components/base/app_stateful_widget.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/theme/app_theme.dart';

class HandleFieldVisibility extends StatefulWidget {
  const HandleFieldVisibility({
    required this.child,
    required this.focusNode,
    this.onFocusChanged,
    super.key,
  });

  final FocusNode focusNode;
  final Widget child;
  final VoidCallback? onFocusChanged;

  @override
  HandleFieldVisibilityState createState() => HandleFieldVisibilityState();
}

class HandleFieldVisibilityState
    extends AppStatefulWidget<HandleFieldVisibility>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleVisibility);
    if (widget.onFocusChanged != null) {
      widget.focusNode.addListener(widget.onFocusChanged!);
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() =>
      widget.focusNode.hasFocus ? _handleVisibility() : null;

  Future<void> _keyboardChanged() async {
    if (mounted) {
      final edgeInsets = MediaQuery.of(context).viewInsets;
      while (mounted && MediaQuery.of(context).viewInsets == edgeInsets) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    return;
  }

  Future<void> _handleVisibility() async {
    await Future.any([
      _keyboardChanged(),
      Future<void>.delayed(const Duration(milliseconds: 100)),
    ]);

    if (!widget.focusNode.hasFocus) return;

    await Scrollable.ensureVisible(
      context,
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 100),
      alignment: 0.4,
    );
  }

  @override
  Widget buildWidget(BuildContext context, AppI18n i18n, AppTheme theme) {
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.focusNode.removeListener(_handleVisibility);
    if (widget.onFocusChanged != null) {
      widget.focusNode.removeListener(widget.onFocusChanged!);
    }
    super.dispose();
  }
}
