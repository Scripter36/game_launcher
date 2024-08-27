import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:game_launcher/provider/game.dart';
import 'package:game_launcher/utils/scroll_behavior.dart';
import 'package:game_launcher/widgets/game_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GamePage extends StatefulHookConsumerWidget {
  const GamePage({super.key});

  @override
  ConsumerState createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<GameData>> games = ref.watch(gameDataListProvider);

    // simple hack to make the page view infinite in both directions
    const int initialPage = 1073741823;
    final PageController controller = usePageController(viewportFraction: 0.9, initialPage: initialPage);
    final FocusNode focusNode = useFocusNode();

    final page = useState(0);

    // listen to page change
    useEffect(() {
      final listener = () {
        final index = (controller.page!.round() - initialPage) % games.asData!.value.length;
        page.value = index;
      };
      controller.addListener(listener);
      return () {
        controller.removeListener(listener);
      };
    }, [games]);

    return KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (value) {
          if (value is KeyDownEvent) {
            if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
              controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
            } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
              controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
            } else if (value.logicalKey == LogicalKeyboardKey.enter) {
              final index = (controller.page!.round() - initialPage) % games.asData!.value.length;
              ref.read(gameDataListProvider.notifier).launchGame(index);
            }
          }
        },
        child: Scaffold(
          body: Center(
            child: games.when(
              data: (data) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: Colors.black,
                    ),
                    AnimatedSwitcher(
                      duration: Durations.medium1,
                      child: Container(
                        key: ValueKey(data[page.value].image),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(p.join(Directory.current.path, data[page.value].image))),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: Color(0xFF323232).withOpacity(0.5),
                    ),
                    PageView.builder(
                      controller: controller,
                      scrollBehavior: AppScrollBehavior(),
                      itemBuilder: (context, index) {
                        final gameIndex = (index - initialPage) % data.length;
                        final game = data[gameIndex];
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: GameCard(gameData: game, index: gameIndex),
                        );
                      },
                    )
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ),
        ));
  }
}
