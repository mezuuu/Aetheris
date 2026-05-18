import 'package:flutter/widgets.dart';

import 'player_controller.dart';

class AetherisScope extends InheritedNotifier<PlayerController> {
  const AetherisScope({
    super.key,
    required PlayerController controller,
    required super.child,
  }) : super(notifier: controller);

  static PlayerController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AetherisScope>();
    assert(scope != null, 'AetherisScope was not found above this context.');
    return scope!.notifier!;
  }
}
