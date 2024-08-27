import 'package:defend_the_donut/parser/gltf/gltf_node.dart';

/// Wrapping mode. Valid values correspond to WebGL enums.
enum WrapMode {
  clampToEdge('CLAMP_TO_EDGE', 33071),
  mirroredRepeat('MIRRORED_REPEAT', 33648),
  repeat('REPEAT', 10497),
  ;

  final String name;
  final int value;

  const WrapMode(this.name, this.value);

  static WrapMode valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static WrapMode? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
