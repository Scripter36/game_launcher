import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:game_launcher/provider/game.dart';
import 'package:game_launcher/utils/image_loader.dart';
import 'package:game_launcher/utils/text.dart';
import 'package:game_launcher/widgets/buttons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';

class GameCard extends HookConsumerWidget {
  final GameData gameData;
  final int index;
  final bool playVideo;
  const GameCard({required this.gameData, required this.index, this.playVideo = false, Key? key}) : super(key: key);

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

    final videoPlayer = useState<VideoPlayerController?>(null);

    useEffect(() {
      if (gameData.video != null) {
        videoPlayer.value = VideoPlayerController.file(ImageLoader.loadImageFile(gameData.video!));
        videoPlayer.value!.initialize().then((_) {
          if (videoPlayer.value == null) {
            return;
          }
          if (playVideo) {
            videoPlayer.value!.setLooping(true);
            videoPlayer.value!.play();
          } else {
            videoPlayer.value!.pause();
          }
        });

        return () {
          videoPlayer.value!.dispose();
        };
      }

      return null;
    }, [gameData.video]);

    useEffect(() {
      if (playVideo) {
        videoPlayer.value?.play();
      } else {
        videoPlayer.value?.pause();
      }

      return null;
    }, [playVideo]);

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
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (videoPlayer.value != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: VideoPlayer(videoPlayer.value!),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: backgroundImage.value!.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Container(
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
                                    .map((entry) =>
                                        [const SizedBox(height: 12), GameMetaDataItem(entry.key, entry.value)])
                                    .expand((element) => element)
                                    .toList(),
                              ],
                            ),
                          ),
                          IntrinsicWidth(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ...gameData.links
                                    .map((link) => [
                                          TextButton(
                                            onPressed: () {},
                                            child: Row(
                                              children: [
                                                switch (link.type) {
                                                  'github' => PhosphorIcon(
                                                      PhosphorIcons.githubLogo(PhosphorIconsStyle.bold),
                                                      size: 20),
                                                  'steam' => PhosphorIcon(
                                                      PhosphorIcons.steamLogo(PhosphorIconsStyle.bold),
                                                      size: 20),
                                                  _ =>
                                                    PhosphorIcon(PhosphorIcons.link(PhosphorIconsStyle.bold), size: 20),
                                                },
                                                SizedBox(width: 16),
                                                Text(link.name),
                                              ],
                                            ),
                                            style: ButtonStyles.secondary,
                                          ),
                                          const SizedBox(height: 16),
                                        ])
                                    .expand((e) => e)
                                    .toList(),
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
                                  style: gameData.isLaunched ? ButtonStyles.error : ButtonStyles.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
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
