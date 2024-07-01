import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/utils.dart';
import 'package:flame_3d/extensions.dart';

abstract class GltfNode {
  final GltfRoot root;

  GltfNode({
    required this.root,
  });
}

class Parser {
  Parser._();

  static GltfRef<T>? ref<T extends GltfNode>(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    final index = map[key];
    if (index == null) {
      return null;
    }
    return GltfRef<T>(
      root: root,
      index: index as int,
    );
  }

  static List<GltfRef<T>>? refList<T extends GltfNode>(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as List<Object?>?)
        ?.map((e) => GltfRef<T>(
              root: root,
              index: e as int,
            ))
        .toList();
  }

  static Vector3? vector3(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    return map['baseColorFactor']
        ?.let((e) => e as List<Object?>)
        .let((e) => Vector3Factory.fromList(e.cast()));
  }

  static Matrix4? matrix4(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    return map[key]
        ?.let((e) => e as List<Object?>)
        .let((e) => Matrix4.fromList(e.cast()));
  }

  static Vector4? vector4(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    return map[key]
        ?.let((e) => e as List<Object?>)
        .let((e) => Vector4Factory.fromList(e.cast()));
  }

  static int? integer(
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as num?)?.toInt();
  }

  static double? float(
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as num?)?.toDouble();
  }

  static bool? boolean(
    Map<String, Object?> map,
    String key,
  ) {
    return map[key] as bool?;
  }

  static List<double>? floatList(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as List<Object?>?)
        ?.map((e) => (e as num).toDouble())
        .toList();
  }

  static String? string(
    Map<String, Object?> map,
    String key,
  ) {
    return map[key] as String?;
  }

  static T? object<T>(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
    T Function(GltfRoot, Map<String, Object?>) parser,
  ) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    return parser(root, value as Map<String, Object?>);
  }

  static T? integerEnum<T extends Enum>(
    Map<String, Object?> map,
    String key,
    T Function(int) valueOf,
  ) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    return valueOf(value as int);
  }

  static T? stringEnum<T extends Enum>(
    Map<String, Object?> map,
    String key,
    T Function(String) valueOf,
  ) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    return valueOf(value as String);
  }

  static List<T>? objectList<T>(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
    T Function(GltfRoot, Map<String, Object?>) parser,
  ) {
    return (map[key] as List<Object?>?)
        ?.map((e) => parser(root, e as Map<String, Object?>))
        .toList();
  }

  static Map<String, int>? mapInt(
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as Map<String, Object?>?)
        ?.map((key, value) => MapEntry(key, value as int));
  }
}
