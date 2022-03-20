import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'board.dart';

// Scroll-O-Sprites @ https://imgur.com/a/uHx4k
// 360x1422

class SpritePainter extends CustomPainter {
  SpritePainter({Cell? this.cell});

  Cell? cell;
  ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    ui.Image? img = SpriteSheet.instance().image;
    if (img == null) {
      return;
    }

    image = img;

    canvas.save();

    final Paint paint = Paint()
      ..colorFilter =
          ColorFilter.mode(cell?.color ?? Colors.white, BlendMode.srcATop);

    int sprite = cell?.sprite ?? 0;
    double sy = (sprite / 20).floor().toDouble();
    double sx = sprite - (sy * 20);
    Offset src = Offset(sx * 18, sy * 18);

    Size sz = SpriteSheet.instance().size;
    canvas.drawImageRect(img, src & Size(16, 16),
        Offset(-sz.width / 2, -sz.height / 2) & sz, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return image == null;
  }
}

class Sprite extends StatelessWidget {
  Sprite({Key? key, Cell? this.cell}) : super(key: key);

  Cell? cell;

  @override
  Widget build(BuildContext context) {
    BoardData board = Provider.of<BoardData>(context);
    if (board.hasRip) {
      return Text(cell?.data ?? '',
          style: TextStyle(color: cell?.color, fontSize: 20));
    }
    return CustomPaint(painter: SpritePainter(cell: cell));
  }
}

class SpriteSheet {
  Map<String, int> tilesetMap = {};
  Map<String, Color> colorMap = {};

  ui.Image? image;
  Size size = const Size(32, 32);

  static SpriteSheet? theSprites;
  static SpriteSheet instance() {
    if (theSprites == null) {
      theSprites = SpriteSheet();
      theSprites?.initialize();
    }
    return theSprites ?? SpriteSheet();
  }

  // load the image async and then draw with `canvas.drawImage(image, Offset.zero, Paint());`
  Future<ui.Image> loadImageAsset(String assetName) async {
    final data = await rootBundle.load(assetName);
    return decodeImageFromList(data.buffer.asUint8List());
  }

  void initialize() async {
    tilesetMap['.'] = 525; // floor
    tilesetMap['#'] = 526; // floor path
    tilesetMap['-'] = 562; //522; // wall
    tilesetMap['|'] = 563; //522; // wall

    // modify!
    tilesetMap['0'] = 565; // corner wall
    tilesetMap['1'] = 566; // corner wall
    tilesetMap['2'] = 567; // corner wall
    tilesetMap['3'] = 568; // corner wall
    tilesetMap['4'] = 911; // bow
    tilesetMap['5'] = 912; // arrows(darts)
    tilesetMap['6'] = 908; // mace
    tilesetMap['8'] = 905; // spear

    tilesetMap['+'] = 534; // door
    tilesetMap['%'] = 532; // staircase

    tilesetMap[':'] = 822; // food
    tilesetMap['!'] = 845; // potion
    tilesetMap[']'] = 926; // armor // 913-helmet
    tilesetMap[')'] = 903; // weapon
    tilesetMap['/'] = 983; // wand or staf
    tilesetMap['='] = 929; // ring
    tilesetMap['*'] = 755; // gold
    tilesetMap['?'] = 988; // scroll
    tilesetMap['^'] = 622; // trap
    tilesetMap['\$'] = 985; // magic
    tilesetMap[','] = 930; // amulet

    tilesetMap['@'] = 124; // knight

    // monsters
    tilesetMap['A'] = 287; // aquator
    tilesetMap['B'] = 283; // bat
    tilesetMap['C'] = 405; // centaur
    tilesetMap['D'] = 293; // dragon
    tilesetMap['E'] = 282; // emu
    tilesetMap['F'] = 463; // venus flytrap
    tilesetMap['G'] = 292; // griffin
    tilesetMap['H'] = 342; // hobgoblin
    tilesetMap['I'] = 462; // ice monster
    tilesetMap['J'] = 163; // jabberwock
    tilesetMap['K'] = 346; // kestrel   // colorize
    tilesetMap['L'] = 465; // leprechaun
    tilesetMap['M'] = 194; // medusa
    tilesetMap['N'] = 408; // nymph
    tilesetMap['O'] = 344; // orc
    tilesetMap['P'] = 409; // phantom
    tilesetMap['Q'] = 289; // quagga
    tilesetMap['R'] = 284; // rattlesnake // colorize!
    tilesetMap['S'] = 288; // snake
    tilesetMap['T'] = 343; // troll
    tilesetMap['U'] = 294; // black unicorn
    tilesetMap['V'] = 165; // vampire
    tilesetMap['W'] = 409; // wraith
    tilesetMap['X'] = 467; // xroc
    tilesetMap['Y'] = 291; // yeti
    tilesetMap['Z'] = 402; // zombie

    // color map
    colorMap['.'] = const Color.fromRGBO(0x40, 0x40, 0x40, 1);
    colorMap['#'] = const Color.fromRGBO(0x60, 0x40, 0x00, 1);

    colorMap['*'] = Colors.yellow;

    for (int i = 65; i <= 65 + 26; i++) {
      colorMap[String.fromCharCode(i)] = Colors.red;
    }

    colorMap[')'] = Colors.purpleAccent;
    colorMap[']'] = Colors.purpleAccent;
    colorMap['4'] = Colors.purpleAccent;
    colorMap['5'] = Colors.purpleAccent;
    colorMap['6'] = Colors.purpleAccent;
    colorMap['8'] = Colors.purpleAccent;

    colorMap['?'] = Colors.purpleAccent;
    colorMap['!'] = Colors.purpleAccent;
    colorMap['/'] = Colors.purpleAccent;
    colorMap[':'] = Colors.purpleAccent;
    colorMap['\$'] = Colors.purpleAccent;
    colorMap[','] = Colors.yellow;

    colorMap['^'] = const Color.fromRGBO(0x50, 0xff, 0x55, 1);
    colorMap['%'] = const Color.fromRGBO(0x50, 0xff, 0x55, 1);

    colorMap['+'] = Colors.orange;
    colorMap['-'] = const Color.fromRGBO(0x0, 0xff, 0xff, 1);
    colorMap['|'] = colorMap['-'] ?? Colors.white;
    colorMap['0'] = colorMap['-'] ?? Colors.white;
    colorMap['1'] = colorMap['-'] ?? Colors.white;
    colorMap['2'] = colorMap['-'] ?? Colors.white;
    colorMap['3'] = colorMap['-'] ?? Colors.white;

    colorMap['@'] = const Color.fromRGBO(0xff, 0xff, 0xaa, 1);

    image = await loadImageAsset('assets/Scroll-o-Sprites.png');
  }
}
