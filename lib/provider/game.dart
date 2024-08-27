import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';
part 'game.g.dart';

@freezed
class GameData with _$GameData {
  const factory GameData({
    required String name,
    required Map<String, String> metadata,
    required String path,
    required String image,
    String? video,
    @Default(false) bool isLaunched,
    @Default(false) bool isLaunching,
  }) = _GameData;

  factory GameData.fromJson(Map<String, Object?> json) => _$GameDataFromJson(json);
}

@riverpod
class GameDataList extends _$GameDataList {
  @override
  Future<List<GameData>> build() async {
    final dir = Directory.current.path;
    final file = File(p.join(dir, 'data/games.json'));
    if (!file.existsSync()) {
      return [];
    }

    final json = jsonDecode(await file.readAsString());
    return (json as List).map((e) => GameData.fromJson(e)).toList();
  }

  Future<bool> execute(int index) async {
    final previousState = await future;
    final game = previousState[index];
    if (game.isLaunched || game.isLaunching) {
      return false;
    }

    state = AsyncData(previousState.map((e) {
      if (e == game) {
        return e.copyWith(isLaunching: true, isLaunched: false);
      } else {
        return e;
      }
    }).toList());
    final completer = Completer<bool>();

    final dir = Directory.current.path;
    Process.start(p.join(dir, game.path), []).then((process) {
      state = AsyncData(previousState.map((e) {
        if (e == game) {
          return e.copyWith(isLaunching: false, isLaunched: true);
        } else {
          return e;
        }
      }).toList());

      process.exitCode.then((exitCode) {
        state = AsyncData(previousState.map((e) {
          if (e == game) {
            return e.copyWith(isLaunching: false, isLaunched: false);
          } else {
            return e;
          }
        }).toList());
        completer.complete(true);
      });
    }).onError((error, stackTrace) {
      state = AsyncData(previousState.map((e) {
        if (e == game) {
          return e.copyWith(isLaunching: false, isLaunched: false);
        } else {
          return e;
        }
      }).toList());
      completer.complete(false);
    });

    return completer.future;
  }
}
