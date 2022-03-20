import 'package:flutter/material.dart';
import 'sprites.dart';
import 'ffibridge.dart';

class Cell {
  String data = '';
  int x = 0;
  int y = 0;
  int sprite = 0;
  Color color = Colors.white;
}

class BoardData extends ChangeNotifier {
  String buffer = '';
  String message = '';
  bool hasMore = false;
  bool hasRip = false;
  Map<String, String> stats = {};
  List<Cell> cells = [];

  Cell player = Cell();

  String getLine(int l) {
    String res = '';
    for (int i = 0; i < 80; i++) {
      res += buffer[l * 80 + i];
    }
    return res;
  }

  bool isWall(String c, String c2) {
    return c == '-' || c == '|' || c == '+' || (c == '@' && c2 == '|');
  }

  String getCharAt(int y, int x) {
    if (x < 0 || x >= 80) return '?';
    if (y < 0 || y >= 25) return '?';
    return buffer[(y * 80) + x];
  }

  void modifyWeaponTiles() {
    // int MACE = 0;
    // int SWORD = 1;
    // int BOW = 2;
    // int ARROW = 3;
    // int DAGGER = 4;
    // int TWOSWORD = 5;
    // int DART = 6;
    // int SHIRAKEN = 7;
    // int SPEAR = 8;
    // int FLAME = 9;

    for (int r = 0; r < 25; r++) {
      for (int c = 0; c < 80; c++) {
        int idx = (r * 80) + c;
        String cc = buffer[idx];
        String nc = cc;

        if (cc != ')') {
          continue;
        }

        int wt = FFIBridge.whatThing(r, c);
        switch (wt) {
          case 0: // MACE:
            nc = '6';
            break;
          case 2: // BOW:
            nc = '4';
            break;
          case 7: //SHIRAKEN:
          case 6: // DART:
          case 3: //ARROW:
            nc = '5';
            break;
          default: // 1 (sword
            break;
        }

        if (nc != cc) {
          buffer = buffer.substring(0, idx) + nc + buffer.substring(idx + 1);
        }
      }
    }
  }

  void modifyCornerTiles() {
    for (int r = 0; r < 25; r++) {
      for (int c = 0; c < 80; c++) {
        int idx = (r * 80) + c;
        String cc = buffer[idx];
        String nc = cc;

        if (cc != '-') {
          continue;
        }

        String left = getCharAt(r, c - 1);
        String right = getCharAt(r, c + 1);
        String up = getCharAt(r - 1, c);
        String down = getCharAt(r + 1, c);
        String up2 = getCharAt(r - 2, c);
        String down2 = getCharAt(r + 2, c);

        if (!isWall(left, '|') && isWall(right, '|') && isWall(down, down2)) {
          nc = '0';
        } else if (isWall(left, '|') &&
            !isWall(right, '|') &&
            isWall(down, down2)) {
          nc = '1';
        } else if (!isWall(left, '|') &&
            isWall(right, '|') &&
            isWall(up, up2)) {
          nc = '2';
        } else if (isWall(left, '|') &&
            !isWall(right, '|') &&
            isWall(up, up2)) {
          nc = '3';
        }

        if (nc != cc) {
          buffer = buffer.substring(0, idx) + nc + buffer.substring(idx + 1);
        }
      }
    }
  }

  void parseBuffer(String buf) {
    SpriteSheet sheet = SpriteSheet.instance();
    buffer = buf;

    // r.i.p.
    String rip = getLine(12);
    hasRip = rip.contains('PEACE');

    // parse the message
    message = getLine(0).trim();
    hasMore = message.contains('--More--');

    // parse status > Level: 1  Gold: 0      Hp: 12(12)  Str: 16(16)  Arm: 4   Exp: 1/0
    String status = getLine(23);
    RegExp regExp = RegExp(
      r"(([a-zA-Z]{0,9}):\s{0,8}([0-9()/]{0,9}))",
      caseSensitive: false,
      multiLine: false,
    );
    final matches = regExp.allMatches(status);
    for (final m in matches) {
      var g = m.groups([2, 3]);
      if (g.length == 2) {
        stats[g[0] ?? '-'] = g[1] ?? '';
      }
    }

    // parse the map
    cells.clear();

    // if dead!

    if (buffer.length >= 3200) {
      if (!hasRip) {
        modifyCornerTiles();
        modifyWeaponTiles();
      }

      // start at 1 - skips the message
      // end before 23 - skips the stats
      for (int i = 1; i < 23; i++) {
        for (int j = 0; j < 80; j++) {
          String c = buffer[i * 80 + j];
          if (c != ' ') {
            Color clr = sheet.colorMap[c] ?? Colors.white;
            Cell cell = Cell()
              ..data = c
              ..x = j
              ..y = i
              ..sprite = sheet.tilesetMap[c] ?? 0
              ..color = clr;
            cells.add(cell);
            if (c == '@') {
              player = cell;
            }
          }
        }
      }
    }

    if (hasRip) {
      message = '';
      hasMore = false;
    }

    notifyListeners();
  }
}
