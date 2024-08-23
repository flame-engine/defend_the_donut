import 'package:defend_the_donut/parser/gltf/gltf_node.dart';

mixin GltfNodeWithData<T> on GltfNode {
  late T _data;

  Future<void> init() async {
    _data = await loadData();
  }

  Future<T> loadData();
  T getData() => _data;
}