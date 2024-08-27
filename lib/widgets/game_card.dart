import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:game_launcher/provider/game.dart';
import 'package:game_launcher/utils/image_loader.dart';
import 'package:game_launcher/utils/text.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class GameCard extends HookConsumerWidget {
  final GameData gameData;
  final int index;
  const GameCard({required this.gameData, required this.index, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aspectRatio = useState(16 / 9);
    final backgroundImage = useState<Image?>(null);

    useEffect(() {
      ImageLoader.loadImage(gameData.image).then((imageData) {
        backgroundImage.value = imageData.image;
        aspectRatio.value = imageData.width / imageData.height;
      });

      return null;
    }, []);

    if (backgroundImage.value == null) {
      return Container();
    } else {
      return Focus(
        descendantsAreFocusable: false,
        canRequestFocus: false,
        child: Center(
          child: AspectRatio(
            aspectRatio: aspectRatio.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 16,
                    offset: const Offset(0, 0),
                  ),
                ],
                image: DecorationImage(
                  image: backgroundImage.value!.image,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(64),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.5),
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gameData.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...gameData.metadata.entries
                              .map((entry) => [const SizedBox(height: 12), GameMetaDataItem(entry.key, entry.value)])
                              .expand((element) => element)
                              .toList(),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              PhosphorIcon(PhosphorIcons.githubLogo(PhosphorIconsStyle.bold), size: 20),
                              SizedBox(width: 16),
                              Text('코드 보기')
                            ],
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFFFFFF),
                            backgroundColor: const Color(0x20FFFFFF),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(
                              fontFamily: 'Paperlogy',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            visualDensity: VisualDensity.standard,
                            splashFactory: NoSplash.splashFactory,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            if (gameData.isLaunched) {
                              ref.read(gameDataListProvider.notifier).terminateGame(index);
                            } else {
                              ref.read(gameDataListProvider.notifier).launchGame(index);
                            }
                          },
                          child: AnimatedSwitcher(
                            duration: Durations.medium1,
                            child: Row(
                              key: ValueKey(gameData.isLaunched),
                              children: [
                                gameData.isLaunched
                                    ? PhosphorIcon(PhosphorIcons.stop(PhosphorIconsStyle.bold), size: 20)
                                    : PhosphorIcon(PhosphorIcons.play(PhosphorIconsStyle.bold), size: 20),
                                SizedBox(width: 16, height: 24),
                                gameData.isLaunched ? Text('종료하기') : Text('실행하기'),
                              ],
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: gameData.isLaunched ? Color(0xFFFFFFFF) : Color(0xFF000000),
                            backgroundColor: gameData.isLaunched ? Color(0x99DA3737) : Color(0x99FFFFFF),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(
                              fontFamily: 'Paperlogy',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            visualDensity: VisualDensity.standard,
                            splashFactory: NoSplash.splashFactory,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class GameMetaDataItem extends HookConsumerWidget {
  final String label;
  final String value;
  const GameMetaDataItem(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xFFC5C5C5),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            TextUtils.keepWord(value),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
