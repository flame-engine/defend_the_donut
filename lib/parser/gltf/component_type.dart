import 'dart:typed_data';

import 'package:defend_the_donut/parser/gltf/gltf_node.dart';

/// The datatype of the accessor's components.
enum ComponentType {
  byte(value: 5120, byteSize: 1),
  unsignedByte(value: 5121, byteSize: 1),
  short(value: 5122, byteSize: 2),
  unsignedShort(value: 5123, byteSize: 2),
  unsignedInt(value: 5125, byteSize: 4),
  float(value: 5126, byteSize: 4),
  ;

  final int value;
  final int byteSize;

  const ComponentType({
    required this.value,
    required this.byteSize,
  });

  num parseData(ByteData byteData, int cursor) {
    final formatter = switch (this) {
      ComponentType.byte => (e, _) => byteData.getInt8(e),
      ComponentType.unsignedByte => (e, _) => byteData.getUint8(e),
      ComponentType.short => byteData.getInt16,
      ComponentType.unsignedShort => byteData.getUint16,
      ComponentType.unsignedInt => byteData.getUint32,
      ComponentType.float => byteData.getFloat32,
    };
    return formatter(cursor, Endian.little);
  }

  static ComponentType valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static ComponentType? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
