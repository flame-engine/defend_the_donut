import 'package:defend_the_donut/parser/gltf/accessor_type.dart';
import 'package:defend_the_donut/parser/gltf/buffer_view.dart';
import 'package:defend_the_donut/parser/gltf/component_type.dart';
import 'package:defend_the_donut/parser/gltf/gltf_node.dart';
import 'package:defend_the_donut/parser/gltf/gltf_ref.dart';
import 'package:defend_the_donut/parser/gltf/gltf_root.dart';
import 'package:defend_the_donut/parser/gltf/sparse_accessor.dart';
import 'package:flame_3d/core.dart';

class RawAccessor extends GltfNode {
  /// The reference to the buffer view.
  /// When undefined, the accessor **MUST** be initialized with zeros; `sparse` property or extensions **MAY** override zeros with actual values.
  final GltfRef<BufferView> bufferView;

  /// The offset relative to the start of the buffer view in bytes.
  ///
  /// This **MUST** be a multiple of the size of the component datatype.
  /// This property **MUST NOT** be defined when `bufferView` is undefined.
  final int byteOffset;

  /// The datatype of the accessor's components.
  /// UNSIGNED_INT type **MUST NOT** be used for any accessor that is not referenced by `mesh.primitive.indices`.
  final ComponentType componentType;

  /// Specifies whether integer data values are normalized (`true`) to [0, 1] (for unsigned types) or to [-1, 1] (for signed types) when they are accessed.
  /// This property **MUST NOT** be set to `true` for accessors with `FLOAT` or `UNSIGNED_INT` component type.
  final bool normalized;

  /// The number of elements referenced by this accessor, not to be confused with the number of bytes or number of components.
  final int count;

  /// Specifies if the accessor's elements are scalars, vectors, or matrices.
  /// This should match the type parameter [T].
  final AccessorType type;

  /// Maximum value of each component in this accessor.
  /// Array elements **MUST** be treated as having the same data type as accessor's `componentType`.
  /// Both `min` and `max` arrays have the same length.
  ///
  /// The length is determined by the value of the `type` property; it can be 1, 2, 3, 4, 9, or 16.
  /// `normalized` property has no effect on array values: they always correspond to the actual values stored in the buffer.
  /// When the accessor is sparse, this property **MUST** contain maximum values of accessor data with sparse substitution applied.
  final List<double>? max;

  /// Minimum value of each component in this accessor.
  ///
  /// Array elements **MUST** be treated as having the same data type as accessor's `componentType`.
  /// Both `min` and `max` arrays have the same length.
  ///
  /// The length is determined by the value of the `type` property; it can be 1, 2, 3, 4, 9, or 16.
  /// 
  /// `normalized` property has no effect on array values: they always correspond to the actual values stored in the buffer.
  /// When the accessor is sparse, this property **MUST** contain minimum values of accessor data with sparse substitution applied.
  final List<double>? min;

  /// Sparse storage of elements that deviate from their initialization value.
  final SparseAccessor? sparse;

  List<num> data() {
    final buffer = bufferView.get();
    if (byteOffset != 0) {
      throw Exception('Accessor byteOffset is not supported yet.');
    }
    final bytes = buffer.data(0 * byteOffset);

    final byteData = bytes.buffer.asByteData();
    final step = buffer.byteStride ?? componentType.byteSize;

    int cursor = 0;
    final result = <num>[];
    while (cursor <= bytes.length - step) {
      result.add(componentType.parseData(byteData, cursor));
      cursor += step;
    }
    return result;
  }

  List<T> _typedData<T>(int size, T Function(List<num>) producer) {
    _verifyNotSparse();
    _verifyAccessorType(size);
    final view = data();
    final result = <T>[];
    for (var i = 0; i < view.length; i += size) {
      result.add(producer(view.sublist(i, i + size)));
    }
    return result;
  }

  void _verifyAccessorType(int size) {
    if (type.size != size) {
      throw Exception('Accessor type mismatch: $type != $size');
    }
  }

  void _verifyNotSparse() {
    if (sparse != null) {
      throw Exception('Accessor is sparse: not supported yet.');
    }
  }

  RawAccessor({
    required super.root,
    required this.bufferView,
    required this.byteOffset,
    required this.componentType,
    required this.normalized,
    required this.count,
    required this.type,
    required this.max,
    required this.min,
    required this.sparse,
  });

  RawAccessor.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
          root: root,
          bufferView: Parser.ref(root, map, 'bufferView')!,
          byteOffset: Parser.integer(map, 'byteOffset') ?? 0,
          componentType: ComponentType.parse(map, 'componentType')!,
          normalized: Parser.boolean(map, 'normalized') ?? false,
          count: Parser.integer(map, 'count')!,
          type: AccessorType.parse(map, 'type')!,
          max: Parser.floatList(root, map, 'max'),
          min: Parser.floatList(root, map, 'min'),
          sparse: Parser.object(root, map, 'sparse', SparseAccessor.parse),
        );
}

abstract class TypedAccessor<T> extends GltfNode {
  final RawAccessor rawAccessor;

  TypedAccessor({
    required super.root,
    required RawAccessor accessor,
  }) : rawAccessor = accessor;

  List<T> typedData();

  void _checkAccessorType(AccessorType expected) {
    final type = rawAccessor.type;
    if (type != expected) {
      throw Exception('Accessor type mismatch: $type != $expected');
    }
  }
}

class IntAccessor extends TypedAccessor<int> {
  IntAccessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<int> typedData() {
    _checkAccessorType(AccessorType.scalar);
    return rawAccessor._typedData(1, (list) => list[0].toInt());
  }
}

class Vector2Accessor extends TypedAccessor<Vector2> {
  Vector2Accessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<Vector2> typedData() {
    _checkAccessorType(AccessorType.vec2);
    return rawAccessor._typedData(2, (it) => Vector2.array(it.cast()));
  }
}

class Vector3Accessor extends TypedAccessor<Vector3> {
  Vector3Accessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<Vector3> typedData() {
    _checkAccessorType(AccessorType.vec3);
    return rawAccessor._typedData(3, (it) => Vector3.array(it.cast()));
  }
}
