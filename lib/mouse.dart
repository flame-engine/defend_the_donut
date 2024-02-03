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

  static final _lock = PointerLock();

  static bool _pointerLocked = false;

  static ValueChanged<PointerDataPacket>? _onPointerDataPacket;

  static Future<void> init() async {
    _onPointerDataPacket = PlatformDispatcher.instance.onPointerDataPacket!;

    PlatformDispatcher.instance.onPointerDataPacket = (packet) async {
      _onPointerDataPacket?.call(packet);

      // If any of the data events is a move or hover we should get a new delta.
      final hasPointerMoved = packet.data.any((e) =>
          e.change == PointerChange.move || e.change == PointerChange.hover);

      // If the data is empty and the pointer is locked then we can assume that
      // the user did move the mouse because Flutter will still trigger the
      // onPointerDataPacket but it cant retrieve data because the pointer was
      // locked.
      final synthesizeMovement = packet.data.isEmpty && _pointerLocked;

      if (hasPointerMoved || synthesizeMovement) {
        _delta = await _lock.lastPointerDelta();
      }
    };
  }

  static Future<void> dispose() async {
    if (_onPointerDataPacket != null) {
      PlatformDispatcher.instance.onPointerDataPacket = _onPointerDataPacket;
    }
    return await unlock();
  }

  static Future<void> lock() async {
    if (_pointerLocked) return;
    return _lock.lockPointer().then((_) => _pointerLocked = true);
  }

  static Future<void> unlock() async {
    if (!_pointerLocked) return;
    return _lock.unlockPointer().then((_) => _pointerLocked = false);
  }
}
