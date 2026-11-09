import 'dart:async';
import 'package:event_bus/event_bus.dart';

class AppEventBus {
  final eventBus = EventBus();

  StreamSubscription<T> listen<T>(void Function(T)? onData) =>
      eventBus.on<T>().listen(onData);

  void fire(dynamic event) => eventBus.fire(event);
}

// EXAMPLE EVENT
class ExampleEvent {}
