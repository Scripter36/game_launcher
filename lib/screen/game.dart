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
              ref.read(gameDataListProvider.notifier).execute(index);
            }
          }
        },
        child: Scaffold(
          body: Center(
            child: games.when(
              data: (data) {
                return PageView.builder(
                  controller: controller,
                  scrollBehavior: AppScrollBehavior(),
                  itemBuilder: (context, index) {
                    final game = data[(index - initialPage) % data.length];
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: GameCard(game),
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ),
        ));
  }
}
