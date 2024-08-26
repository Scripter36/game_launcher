import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:game_launcher/provider/game.dart';
import 'package:game_launcher/utils/image_loader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class GameCard extends HookConsumerWidget {
  final GameData gameData;
  const GameCard(this.gameData, {Key? key}) : super(key: key);

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
                    begin: Alignment(0.0, -0.5),
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.4),
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      gameData.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      direction: Axis.vertical,
                      spacing: 16,
                      children:
                          gameData.metadata.entries.map((entry) => GameMetaDataItem(entry.key, entry.value)).toList(),
                    ),
                    const SizedBox(height: 64),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              PhosphorIcon(PhosphorIcons.play(PhosphorIconsStyle.bold), size: 24),
                              SizedBox(width: 16, height: 24),
                              Text('실행하기')
                            ],
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF000000),
                            backgroundColor: const Color(0x99FFFFFF),
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            textStyle: const TextStyle(
                              fontFamily: 'Paperlogy',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            visualDensity: VisualDensity.standard,
                            splashFactory: NoSplash.splashFactory,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              PhosphorIcon(PhosphorIcons.githubLogo(PhosphorIconsStyle.bold), size: 24),
                              SizedBox(width: 16),
                              Text('코드 보기')
                            ],
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFFFFFF),
                            backgroundColor: const Color(0x20FFFFFF),
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            textStyle: const TextStyle(
                              fontFamily: 'Paperlogy',
                              fontSize: 24,
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
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xFFC5C5C5),
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
