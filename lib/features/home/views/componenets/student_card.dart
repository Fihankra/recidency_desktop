import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/keyFlow/provider/key_flow_provider.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';

class StudentCard extends ConsumerStatefulWidget {
  const StudentCard(this.student, this.keyLog, {super.key});
  final StudentModel student;
  final KeyLogModel? keyLog;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StudentCardState();
}

class _StudentCardState extends ConsumerState<StudentCard> {
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    var me = ref.read(myselfProvider);
    return InkWell(
        onTap: () {},
        onHover: (value) {
          setState(() {
            onHover = value;
          });
        },
        child: PopupMenuButton(
          itemBuilder: (context) => [
            if (me.role != Role.hallAdmin)
              if (widget.keyLog == null || widget.keyLog!.activity == 'in')
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.lock_open),
                    title: const Text('Collecting Key'),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(newKeyLogProvider.notifier).addKeyActivity(
                          student: widget.student, activity: 'out', ref: ref);
                    },
                  ),
                ),
            if (me.role != Role.hallAdmin)
              if (widget.keyLog == null || widget.keyLog!.activity == 'out')
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Returning Key'),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(newKeyLogProvider.notifier).addKeyActivity(
                          student: widget.student, activity: 'in', ref: ref);
                    },
                  ),
                ),
          ],
          child: Transform.translate(
            offset: Offset(onHover ? -10 : 0, onHover ? -10 : 0),
            child: Card(
              elevation: onHover ? 10 : 4,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: onHover ? Colors.red : Colors.transparent),
                  borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 250,
                      height: 230,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(File(widget.student.image!)),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${widget.student.firstname} ${widget.student.surname}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Room: ',
                            style:
                                getTextStyle(fontSize: 15, color: Colors.grey),
                            children: [
                              TextSpan(
                                  text: widget.student.room,
                                  style: getTextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .color,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold))
                            ]),
                      ),
                    ),
                    //student phone
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Phone: ',
                            style:
                                getTextStyle(fontSize: 15, color: Colors.grey),
                            children: [
                              TextSpan(
                                  text: widget.student.phone,
                                  style: getTextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .color,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold))
                            ]),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
