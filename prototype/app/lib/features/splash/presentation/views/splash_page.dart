import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/core/components/base/app_stateful_page.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/routes/app_routes.dart';
import 'package:studio_app/core/theme/app_theme.dart';
import 'package:studio_app/core/utils/extensions/context_extension.dart';
import 'package:studio_app/features/splash/presentation/view_models/splash_page_cubit.dart';
import 'package:studio_app/features/splash/presentation/views/splash_page_actions.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends AppStatefulPage<SplashPage>
    implements SplashPageActions {
  late final _cubit = SplashPageCubit(this);

  @override
  void initState() {
    super.initState();
    _cubit.initalize();
  }

  @override
  Widget buildWidget(BuildContext context, AppI18n i18n, AppTheme theme) {
    return Scaffold(
      body: Container(
        color: theme.primaryColor,
        child: Center(
          child: Text(
            i18n.get('appName'),
            textAlign: TextAlign.center,
            style: theme.displayLargeText.copyWith(
              color: theme.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void navToExample() => context.push<void>(AppRoutes.example);

  @override
  List<BlocProvider>? get providers => [BlocProvider.value(value: _cubit)];

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}
