import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension ContextExtension on BuildContext {
  void pop() => GoRouter.of(this).pop();

  void go(String path) => GoRouter.of(this).go(path);

  Future<T?> push<T>(String path) => GoRouter.of(this).push(path);

  void popDialog({dynamic value}) => Navigator.of(this).pop(value);
}
