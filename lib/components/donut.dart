import 'dart:async';

import 'package:flame/geometry.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:defend_the_donut/components/base_component.dart';
import 'package:defend_the_donut/parser/obj_parser.dart';
import 'package:defend_the_donut/utils.dart';

enum DonutType {
  donut1('objects/donuts/donut_1.obj');

  final String path;

  const DonutType(this.path);
}

class Donut extends BaseComponent {
  final DonutType type;
  late Vector3 _rotationAxis;

  Donut({
    required this.type,
    required super.position,
  }) : super(mesh: Mesh());

  @override
  FutureOr<void> onLoad() async {
    await ObjParser.parse(type.path, applyTo: mesh);
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
}
