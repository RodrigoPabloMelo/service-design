import 'package:flutter/material.dart';
import 'package:studio_app/core/components/base/app_stateless_widget.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/theme/app_theme.dart';
import 'package:studio_app/features/example/presentation/view_models/example_page_cubit.dart';
import 'package:provider/provider.dart';

class ExamplePageForm extends AppStatelessWidget {
  const ExamplePageForm({super.key});

  @override
  Widget buildWidget(BuildContext context, AppI18n i18n, AppTheme theme) {
    final cubit = context.watch<ExamplePageCubit>();

    return Form(
      child: Column(
        children: [
          TextField(
            onChanged: cubit.onFieldChanged,
            decoration: InputDecoration(
              labelText: i18n.get('app.features.example.form.exampleLabel'),
              hintText: i18n.get('app.features.example.form.exampleHint'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: cubit.onField2Changed,
            decoration: InputDecoration(
              labelText: i18n.get('app.features.example.form.exampleLabel2'),
              hintText: i18n.get('app.features.example.form.exampleHint2'),
            ),
          ),
        ],
      ),
    );
  }
}
