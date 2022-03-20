import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'board.dart';
import 'input.dart';
import 'sprites.dart';
import 'ffibridge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FFIBridge.initialize();
  FFIBridge.initApp();
  FFIBridge.pushKey(' ');

  BoardData board = BoardData();

  Widget app = MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => board),
  ], child: Game());

  runApp(app);
}

class Game extends StatelessWidget {
  const Game({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const GameView(),
    );
  }
}

class GameMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BoardData board = Provider.of<BoardData>(context);

    Size screen = MediaQuery.of(context).size;
    RenderObject? obj = context.findRenderObject();
    if (obj != null) {
      RenderBox? box = obj as RenderBox;
      screen = box.size;
    }

    // map
    Size size = SpriteSheet.instance().size;
    Offset playerXY =
        Offset(board.player.x * size.width, board.player.y * size.height);

    if (board.hasRip) {
      size = Size(16, 16);
      playerXY = Offset(40 * size.width, 20 * size.height);
    }

    Offset center =
        Offset(screen.width / 2 - playerXY.dx, screen.height / 2 - playerXY.dy);

    List<Widget> map = [];
    for (final c in board.cells) {
      map.add(Positioned(
          top: center.dy + (size.height * (c.y - 2)),
          left: center.dx + (size.width * c.x),
          child: Sprite(cell: c)));
    }

    return Stack(children: map);
  }
}

class GameView extends StatefulWidget {
  const GameView({Key? key}) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  void _updateScreen() {
    String buffer = FFIBridge.getScreenBuffer();
    BoardData data = Provider.of<BoardData>(context, listen: false);
    data.parseBuffer(buffer);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _updateScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    BoardData board = Provider.of<BoardData>(context);

    // stats
    double fontSize = (Platform.isAndroid ? 12 : 20);
    TextStyle statStyle = TextStyle(
        // fontFamily: 'PixelFont',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white);
    List<Widget> stats = [];
    for (final k in board.stats.keys) {
      String v = board.stats[k] ?? '';
      if (stats.isNotEmpty) {
        stats.add(Expanded(child: Container()));
      }
      stats.add(Row(children: [
        Text('$k: ', style: statStyle),
        Text('$v  ', style: statStyle)
      ]));
    }

    if (board.hasRip) {
      stats = [];
    }

    // commands
    List<InputTool> commands = [
      InputTool(icon: Icons.arrow_back, title: 'Left', cmd: 'h'),
      InputTool(icon: Icons.arrow_downward, title: 'Down', cmd: 'j'),
      InputTool(icon: Icons.arrow_upward, title: 'Up', cmd: 'k'),
      InputTool(icon: Icons.arrow_forward, title: 'Right', cmd: 'l'),
      InputTool(icon: Icons.update, title: 'Rest', cmd: '.'),
      InputTool(icon: Icons.keyboard_arrow_up, title: 'Space', cmd: '<'),
      InputTool(icon: Icons.keyboard_arrow_down, title: 'Space', cmd: '>'),
      InputTool(icon: Icons.space_bar, title: 'Space', cmd: ' '),
      InputTool(icon: Icons.cancel_outlined, title: 'Escape', cmd: '\x1b'),
    ];

    if (board.hasRip) {
      commands = [
        InputTool(
            icon: Icons.play_arrow,
            title: 'Left',
            cmd: '',
            onPressed: () {
              FFIBridge.restartApp();
              Future.delayed(const Duration(milliseconds: 500), _updateScreen);
            }),
      ];
    }

    TextStyle messageStyle = const TextStyle(
        fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white);

    return Scaffold(
        body: InputListener(
      toolbar: commands,
      showToolbar: true,
      child: Column(children: [
        // stats
        Padding(
            padding: EdgeInsets.only(top: Platform.isAndroid ? 32 : 0),
            child: Row(children: stats)),

        // map
        Expanded(child: GameMap()),

        Text(board.message, style: messageStyle),
      ]),
      onKeyDown: (String key,
          {int keyId = 0,
          bool shift = false,
          bool control = false,
          bool softKeyboard = false}) {
        int k = keyId;
        if (!shift &&
                (k >= LogicalKeyboardKey.keyA.keyId &&
                    k <= LogicalKeyboardKey.keyZ.keyId) ||
            (k + 32 >= LogicalKeyboardKey.keyA.keyId &&
                k + 32 <= LogicalKeyboardKey.keyZ.keyId)) {
          String ch =
              String.fromCharCode(97 + k - LogicalKeyboardKey.keyA.keyId);
          key = ch;
        }

        String s = key;

        switch (key) {
          case 'Arrow Up':
            s = 'k';
            break;
          case 'Arrow Down':
            s = 'j';
            break;
          case 'Arrow Left':
            s = 'h';
            break;
          case 'Arrow Right':
            s = 'l';
            break;
          case 'Space':
            s = ' ';
            break;
          case 'Escape':
            s = '\x1b';
            break;
          case 'Enter':
            s = '\n';
            break;
          default:
            if (key.length > 1) {
              print(key);
            }
            break;
        }

        if (s.length == 1) {
          FFIBridge.pushKey(s);
        }
        Future.delayed(const Duration(milliseconds: 50), _updateScreen);
      },
    ));
  }
}
