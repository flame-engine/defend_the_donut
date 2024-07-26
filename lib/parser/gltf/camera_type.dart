import 'package:defend_the_donut/parser/gltf/gltf_node.dart';

/// Specifies if the camera uses a perspective or orthographic projection.
enum CameraType {
  perspective,
  orthographic,
  ;

  static CameraType valueOf(String value) {
    return values.firstWhere((e) => e.toString() == value);
  }

  static CameraType? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
