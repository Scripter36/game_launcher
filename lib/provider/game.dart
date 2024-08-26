import 'dart:convert';
import 'dart:io';
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
  }) = _GameData;

  factory GameData.fromJson(Map<String, Object?> json) => _$GameDataFromJson(json);
}

@riverpod
Future<List<GameData>> getGameData(GetGameDataRef ref) async {
  final dir = Directory.current.path;
  final file = File('$dir/data/games.json');
  if (!file.existsSync()) {
    return [];
  }

  final json = jsonDecode(await file.readAsString());
  return (json as List).map((e) => GameData.fromJson(e)).toList();
}
