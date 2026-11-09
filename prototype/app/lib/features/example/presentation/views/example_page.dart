import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/core/components/base/app_stateful_page.dart';
import 'package:studio_app/core/components/widgets/app_dialog.dart';
import 'package:studio_app/core/components/widgets/app_example_button.dart';
import 'package:studio_app/core/components/widgets/flushbar/flushbar_area_cubit.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/theme/app_theme.dart';
import 'package:studio_app/core/utils/show_actions.dart';
import 'package:studio_app/features/example/presentation/view_models/example_page_cubit.dart';
import 'package:studio_app/features/example/presentation/views/example_page_actions.dart';
import 'package:studio_app/features/example/presentation/widgets/example_page_form.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  ExamplePageState createState() => ExamplePageState();
}

class ExamplePageState extends AppStatefulPage<ExamplePage>
    implements ExamplePageActions {
  @override
  Widget buildWidget(BuildContext context, AppI18n i18n, AppTheme theme) {
    final cubit = context.read<ExamplePageCubit>();

    return BlocSelector<ExamplePageCubit, ExamplePageCubitState, bool>(
      selector: (state) => state.isLoading,
      builder: (context, isLoading) {
        return AbsorbPointer(
          absorbing: isLoading,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: theme.primaryColor,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        i18n.get('app.features.example.title'),
                        style: theme.titleLargeText.copyWith(
                          color: theme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ExamplePageForm(),
                      const SizedBox(height: 32),
                      AppExampleButton(
                        text:
                            i18n.get('app.features.example.form.exampleButton'),
                        onPressed: cubit.onExamplePressed,
                      ),
                      const SizedBox(height: 8),
                      AppExampleButton(
                        text: i18n
                            .get('app.features.example.form.exampleButton2'),
                        onPressed: cubit.showFlushbar,
                      ),
                      const SizedBox(height: 8),
                      AppExampleButton(
                        text: i18n
                            .get('app.features.example.form.exampleButton3'),
                        onPressed: cubit.showModalBottomSheet,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  List<BlocProvider>? get providers => [
        BlocProvider<ExamplePageCubit>(
          create: (context) => ExamplePageCubit(this),
        ),
      ];

  @override
  void showModalBottomSheet() {
    showAppDialog<void>(
      name: '/example/modal-bottom-sheet',
      context: context,
      builder: (context) {
        final i18n = context.read<AppI18n>();
        final theme = context.read<AppTheme>();

        return AppDialog(
          children: [
            Text(
              i18n.get('app.features.example.form.exampleButton3'),
              style: theme.titleLargeText.copyWith(
                color: theme.secondaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void showFlushbar() {
    final i18n = context.read<AppI18n>();
    injector.get<FlushbarAreaCubit>().showFlushbar(
          Flushbar.alert(
            text: i18n.get('app.features.example.title'),
          ),
        );
  }
}
