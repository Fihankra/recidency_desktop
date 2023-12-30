import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
         PageHeaders(
          title: 'Broadcast Messages',
          subTitle: 'List of all broadcast messages',
          hasBackButton: false,
          extraButtonText: 'New Message',
          hasExtraButton: true,
          onExtraButtonPressed: () {
            context.go(RouterInfo.newMessageRoute.path );
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            color: Colors.white,
          ),
        ),
      ]),
    );
  }
}
