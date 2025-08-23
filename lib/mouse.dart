import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:pointer_lock/pointer_lock.dart';

class Mouse {
  static Offset getDelta() {
    final delta = _delta;
    _delta = Offset.zero;
    return delta;
  }

  static Offset _delta = Offset.zero;
  static StreamSubscription<PointerLockMoveEvent>? _subscription;

  static Future<void> dispose() async {
    _subscription?.cancel();
  }

  static Future<void> reset() async {
    _delta = Offset.zero;
  }

  static Future<void> lock() async {
    _subscription?.cancel();
    _subscription = pointerLock.createSession().listen((event) {
      _delta += event.delta;
    });
  }

  static Future<void> unlock() async {
    _subscription?.cancel();
  }
}
