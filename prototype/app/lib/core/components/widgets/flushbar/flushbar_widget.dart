import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:studio_app/core/components/base/app_stateful_widget.dart';
import 'package:studio_app/core/components/widgets/flushbar/flushbar_area_cubit.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/theme/app_theme.dart';

class FlushbarWidget extends StatefulWidget {
  const FlushbarWidget({required this.flushbar, super.key});

  final Flushbar flushbar;

  @override
  FlushBarWidgetState createState() => FlushBarWidgetState();
}

class FlushBarWidgetState extends AppStatefulWidget<FlushbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future<void>.delayed(widget.flushbar.duration).then((value) {
            if (!mounted) return;
            _controller.reverse();
          });
        } else if (status == AnimationStatus.dismissed) {
          injector.get<FlushbarAreaCubit>().removeFlushbar(widget.flushbar);
        }
      });

    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context, AppI18n i18n, AppTheme theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return SlideTransition(
          position: _animation,
          child: Dismissible(
            key: ObjectKey(widget.flushbar),
            direction: DismissDirection.up,
            onDismissed: (_) {
              injector.get<FlushbarAreaCubit>().removeFlushbar(widget.flushbar);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 15,
                    color: Colors.black.withValues(alpha: 0.3),
                  )
                ],
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    switch (widget.flushbar.type) {
                      FlushbarType.alert => 'assets/icons/example.svg',
                    },
                    width: 18,
                    height: 18,
                    excludeFromSemantics: true,
                    colorFilter: ColorFilter.mode(
                      switch (widget.flushbar.type) {
                        FlushbarType.alert => theme.secondaryColor,
                      },
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.flushbar.text,
                      style: theme.titleLargeText.copyWith(
                        color: theme.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
