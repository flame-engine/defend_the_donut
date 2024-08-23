import 'package:defend_the_donut/flame3d/model.dart';
import 'package:defend_the_donut/parser/glb_parser.dart';
import 'package:defend_the_donut/parser/gltf_parser.dart';
import 'package:defend_the_donut/parser/obj_parser.dart';

abstract class ModelParser {
  Future<Model> parse(String filePath);

  static GltfParser gltf = GltfParser();
  static GlbParser glb = GlbParser();
  static ObjParser obj = ObjParser();

  static String prefix(String filePath) {
    return filePath.substring(0, filePath.lastIndexOf('/') + 1);
  }
}
