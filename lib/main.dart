import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';

import 'input.dart';

class FFIBridge {
  static bool initialize() {
    nativeApiLib = Platform.isMacOS || Platform.isIOS
        ? DynamicLibrary.process() // macos and ios
        : (DynamicLibrary.open(Platform.isWindows // windows
            ? 'api.dll'
            : 'libapi.so')); // android and linux

    final _add = nativeApiLib
        .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add');
    add = _add.asFunction<int Function(int, int)>();

    final _cap = nativeApiLib.lookup<
        NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>('capitalize');
    _capitalize = _cap.asFunction<Pointer<Utf8> Function(Pointer<Utf8>)>();

    final _initApp =
        nativeApiLib.lookup<NativeFunction<Void Function()>>('initApp');
    initApp = _initApp.asFunction<void Function()>();

    final _getSB = nativeApiLib
        .lookup<NativeFunction<Pointer<Utf8> Function()>>('getScreenBuffer');
    _getScreenBuffer = _getSB.asFunction<Pointer<Utf8> Function()>();

    final _pk = nativeApiLib
        .lookup<NativeFunction<Void Function(Pointer<Utf8>)>>('pushString');
    _pushKey = _pk.asFunction<void Function(Pointer<Utf8>)>();

    return true;
  }

  static late DynamicLibrary nativeApiLib;
  static late Function add;
  static late Function _capitalize;
  static late Function initApp;
  static late Function _getScreenBuffer;
  static late Function _pushKey;

  static String capitalize(String str) {
    final _str = str.toNativeUtf8();
    Pointer<Utf8> res = _capitalize(_str);
    calloc.free(_str);
    return res.toDartString();
  }

  static void pushKey(String str) {
    final _str = str.toNativeUtf8();
    _pushKey(_str);
    calloc.free(_str);
  }

  static String getScreenBuffer() {
    Pointer<Utf8> res = _getScreenBuffer();
    return res.toDartString();
  }
}

void main() {
  FFIBridge.initialize();
  FFIBridge.initApp();
  FFIBridge.pushKey(' ');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameView(),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({Key? key}) : super(key: key);

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  String buffer = '';

  void _updateScreen() {
    setState(() {
      buffer = FFIBridge.getScreenBuffer();
    });
  }

  @override
  Widget build(BuildContext context) {
    // draw the buffer into flutter
    double cw = 12;
    double ch = 20;
    List<Widget> rows = [];
    if (buffer.length >= 3200) {
      for (int i = 0; i < 25; i++) {
        List<Widget> cells = [];
        for (int j = 0; j < 80; j++) {
          String c = buffer[i * 80 + j];
          cells.add(SizedBox(width: cw, height: ch, child: Text(c)));
        }
        rows.add(Row(children: cells));
      }
    }

    return Scaffold(
        body: InputListener(
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: rows),
        ),
      ),
      onKeyDown: (String key,
          {int keyId = 0,
          bool shift = false,
          bool control = false,
          bool softKeyboard = false}) {

        int k = keyId;
          if (!shift && (k >= LogicalKeyboardKey.keyA.keyId &&
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
          case 'Enter':
            s = '\n';
            break;
          default:
            print(key);
            break;
        }

        if (s.length == 1) {
          FFIBridge.pushKey(s);
        }
        Future.delayed(const Duration(milliseconds: 10), _updateScreen);
      },
    ));
  }
}
