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
    @Default(0) int pid,
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

  Future<bool> launchGame(int index) async {
    final previousState = await future;
    final game = previousState[index];
    if (game.isLaunched) {
      return false;
    }

    state = AsyncData(previousState.map((e) {
      if (e == game) {
        return e.copyWith(isLaunched: false);
      } else {
        return e;
      }
    }).toList());
    final completer = Completer<bool>();

    final dir = Directory.current.path;

    final process = await Process.start(p.join(dir, game.path), [], mode: ProcessStartMode.detached);

    // wait until the process is finished
    state = AsyncData(previousState.map((e) {
      if (e == game) {
        return e.copyWith(isLaunched: true, pid: process.pid);
      } else {
        return e;
      }
    }).toList());

    // check if the process is still running every 500ms
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      try {
        Process.run('tasklist', ['/FI', 'PID eq ${process.pid}']).then((result) {
          if (!result.stdout.toString().contains(' ${process.pid} ')) {
            state = AsyncData(previousState.map((e) {
              if (e == game) {
                return e.copyWith(isLaunched: false, pid: 0);
              } else {
                return e;
              }
            }).toList());
            if (!completer.isCompleted) {
              completer.complete(true);
              // cancel the timer
              timer.cancel();
            }
          }
        });
      } catch (e) {
        // ignore
      }
    });

    return completer.future;
  }

  Future<bool> terminateGame(int index) async {
    final previousState = await future;
    final game = previousState[index];
    if (!game.isLaunched) {
      return false;
    }

    await Process.killPid(game.pid);
    return true;
  }
}
