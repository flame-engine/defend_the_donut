import 'dart:ui';
import 'dart:math' as math;

import 'package:defend_the_donut/components/cylinder_mesh.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class Beam extends MeshComponent {
  Beam({
    required double radius,
    required double height,
  }) : super(
          mesh: CylinderMesh(
            radius: radius,
            height: height,
            material: SpatialMaterial()..albedoColor = const Color(0xFFFF0000),
          ),
        );

  static Beam generate({
    required Vector3 start,
    required Vector3 end,
    double radius = _beamRadius,
  }) {
    final beam = Beam(
      radius: radius,
      height: start.distanceTo(end),
    );
    beam.transform.setFrom(_calculateTransform(start, end));
    return beam;
  }

  static Transform3D _calculateTransform(
    Vector3 start,
    Vector3 end,
  ) {
    final direction = end - start;
    final length = direction.length;

    final bottomCenter = Vector3(0, -length / 2, 0);
    final topCenter = Vector3(0, length / 2, 0);

    final translation = start - bottomCenter;

    final rotation = _calculateRotationMatrix(
      bottomCenter: translation + bottomCenter,
      topCenter: translation + topCenter,
      target: end,
    );

    final translationMatrix = Matrix4.translation(translation);
    final rotationMatrix = _rotateAroundPoint(rotation, start);
    final transform = rotationMatrix * translationMatrix;

    return Transform3D.fromMatrix4(transform);
  }

  static Matrix4 _calculateRotationMatrix({
    required Vector3 bottomCenter,
    required Vector3 topCenter,
    required Vector3 target,
  }) {
    final origin = (topCenter - bottomCenter).normalized();
    final dest = (target - bottomCenter).normalized();

    final normal = origin.cross(dest);
    if (normal.length == 0) {
      return Matrix4.identity();
    }

    final dotProduct = origin.dot(dest);
    final angle = math.acos(dotProduct);

    return Matrix4.identity()..rotate(normal, angle);
  }

  static Matrix4 _rotateAroundPoint(Matrix4 rotation, Vector3 point) {
    return Matrix4.translation(point) * rotation * Matrix4.translation(-point);
  }

  static const _beamRadius = 0.02;
}
