import 'dart:math' show Random;

import 'package:flame_3d/core.dart';

const enableAudio = false;

final random = Random();
const worldRadius = 450.0;
const worldRadius2 = worldRadius * worldRadius;

extension Vector4Entries on Vector4 {
  List<double> get entries => [x, y, z, w];
}
