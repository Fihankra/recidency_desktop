import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/provider/theme_provider.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/features/container/action_controls.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:window_manager/window_manager.dart';

class AuthContainerPage extends ConsumerStatefulWidget {
  const AuthContainerPage({required this.child, this.shellContext, super.key});
  final StatefulNavigationShell child;
  final BuildContext? shellContext;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContainerPageState();
}

class _ContainerPageState extends ConsumerState<AuthContainerPage> {
  @override
  Widget build(BuildContext context) {
    var settings = ref.watch(settingsFutureProvider);
    return Scaffold(
        appBar: AppBar(
          elevation: 5,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: DragToMoveArea(
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
        body: settings.when(
            data: (data) {
              return FocusTraversalGroup(
                key: ValueKey('body${widget.child.key}'),
                child: widget.child,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => FocusTraversalGroup(
                  key: ValueKey('body${widget.child.key}'),
                  child: widget.child,
                )));
  }
}
