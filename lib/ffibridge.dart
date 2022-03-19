import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

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
