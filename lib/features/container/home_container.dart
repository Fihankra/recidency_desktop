import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/provider/theme_provider.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/widgets/components/side_bar.dart';
import 'package:residency_desktop/features/container/action_controls.dart';
import 'package:window_manager/window_manager.dart';

import 'provider/main_provider.dart';

class HomeContainer extends ConsumerStatefulWidget {
  const HomeContainer({required this.child, this.shellContext, super.key});
  final StatefulNavigationShell child;
  final BuildContext? shellContext;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeContainerState();
}

class _HomeContainerState extends ConsumerState<HomeContainer> {
  @override
  Widget build(BuildContext context) {
    var data = ref.watch(mainProvider);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Row(
          children: [
            const SideBar(),
            Expanded(
              child: Column(
                children: [
                  DragToMoveArea(
                    child: Container(
                      color: Theme.of(context).colorScheme.background,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      child: Row(
                        children: [
                          const Spacer(),
                          //dark and light mode
                          IconButton(
                            onPressed: () {
                              ref.read(themeProvider.notifier).toggleTheme();
                            },
                            icon: Icon(
                              ref.watch(themeProvider) == darkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              // color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const ActionControls(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: data.when(
                      loading: () =>  Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          Text('Loading data from server',style: getTextStyle()),
                        ],
                      )),
                      error: (e, s) => Center(child: Text('Unable to load data from server, Contact admin',style: getTextStyle(),)),
                      data: (data) {
                        return FocusTraversalGroup(
                          key: ValueKey('body${widget.child.key}'),
                          child: widget.child,
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
