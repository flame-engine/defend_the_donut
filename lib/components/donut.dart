import 'dart:async';

import 'package:defend_the_donut/components/base_component.dart';
import 'package:defend_the_donut/utils.dart';
import 'package:flame/geometry.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d_extras/parser/model_parser.dart';

enum DonutType {
  donut1('objects/donuts/donut_1.obj'),
  donut2('objects/donuts/donut_2.glb'),

  ;

  final String path;

  const DonutType(this.path);
}

class Donut extends BaseComponent {
  final DonutType type;
  late Vector3 _rotationAxis;

  Donut._({
    required this.type,
    required super.position,
    required super.model,
  });

  @override
  FutureOr<void> onLoad() async {
    transform.scale = Vector3.all(150.0);
    transform.rotation = Quaternion.euler(
      random.nextDouble() * tau,
      random.nextDouble() * tau,
      random.nextDouble() * tau,
    );
    _rotationAxis = Vector3(
      random.nextDouble(),
      random.nextDouble(),
      random.nextDouble(),
    );
  }

  @override
  void doUpdate(double dt) {
    final angle = _rotationSpeed * dt;
    final dr = Quaternion.axisAngle(_rotationAxis, angle);
    transform.rotation = transform.rotation * dr;
  }

  static const _rotationSpeed = 0.2;

  static Future<Donut> donut({
    required Vector3 position,
  }) async {
    final type = DonutType.values.first;
    return Donut._(
      type: type,
      position: position,
      model: await ModelParser.parse(type.path),
    );
  }
}
