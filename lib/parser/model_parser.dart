import 'package:defend_the_donut/flame3d/model.dart';
import 'package:defend_the_donut/parser/glb_parser.dart';
import 'package:defend_the_donut/parser/obj_parser.dart';

abstract class ModelParser {
  Future<Model> parse(String filePath);

  static GlbParser glb = GlbParser();
  static ObjParser obj = ObjParser();
}