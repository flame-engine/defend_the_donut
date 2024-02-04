import 'dart:async';

import 'package:flame/geometry.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:space_nico/components/base_component.dart';
import 'package:space_nico/obj_parser.dart';
import 'package:space_nico/utils.dart';

class Donut extends BaseComponent {
  late Vector3 _rotationAxis;

  Donut({
    required super.position,
  }) : super(mesh: Mesh());

  @override
  FutureOr<void> onLoad() async {
    await ObjParser.parse('objects/donut.obj', applyTo: mesh);
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
