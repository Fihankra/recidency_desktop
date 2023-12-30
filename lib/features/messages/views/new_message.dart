import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';

class NewMessagePage extends ConsumerStatefulWidget {
  const NewMessagePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends ConsumerState<NewMessagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        PageHeaders(
          title: 'New Message',
          subTitle: 'Send a new message to all students',
          hasBackButton: true,
          hasExtraButton: false,
          onBackButtonPressed: () {
            context.go(RouterInfo.messagesRoute.path);
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
