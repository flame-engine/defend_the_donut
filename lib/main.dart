import 'package:flutter/widgets.dart';
import 'package:flame/game.dart' show GameWidget;
import 'package:defend_the_donut/space_game_3d.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  final game = SpaceGame3D();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      return;
    }

    if (!game.isPaused) {
      game.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}
