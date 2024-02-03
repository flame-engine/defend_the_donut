import 'dart:ui';

import 'package:pointer_lock/pointer_lock.dart';

class Mouse {
  static final _lock = PointerLock();

  static Future<void> init() => _lock.subscribeToRawInputData();

  // TODO: I think we want to use startPointerLockSession instead
  static Offset get delta {
    _lock.lastPointerDelta().then((value) => _delta = value);
    return _delta;
  }

  static Offset _delta = Offset.zero;

  static Future<void> lock() => _lock.lockPointer();

  static Future<void> unlock() => _lock.unlockPointer();
}
