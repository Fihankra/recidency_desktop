import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/keyFlow/provider/key_flow_provider.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/generated/assets.dart';

class StudentCard extends ConsumerStatefulWidget {
  const StudentCard({required this.student, this.keyLog, super.key,  this. controller});
  final StudentModel student;
  final KeyLogModel? keyLog;
  final TextEditingController? controller;
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
        child: me.role != Role.hallAdmin
            ? PopupMenuButton(
                itemBuilder: (context) => [
                      if ((widget.keyLog == null ||
                              widget.keyLog!.id == null) ||
                          widget.keyLog!.activity == 'in')
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(Icons.lock_open),
                            title: const Text('Collecting Key'),
                            onTap: () {
                              Navigator.pop(context);
                              ref
                                  .read(newKeyLogProvider.notifier)
                                  .addKeyActivity(
                                      student: widget.student,
                                      activity: 'out',
                                      ref: ref);
                            },
                          ),
                        ),
                      if ((widget.keyLog == null ||
                              widget.keyLog!.id == null) ||
                          widget.keyLog!.activity == 'out')
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(Icons.lock),
                            title: const Text('Returning Key'),
                            onTap: () {
                              Navigator.pop(context);
                              ref
                                  .read(newKeyLogProvider.notifier)
                                  .addKeyActivity(
                                      student: widget.student,
                                      activity: 'in',
                                      controller: widget.controller,
                                      ref: ref);
                            },
                          ),
                        ),
                    ],
                child: _buildStudentCard())
            : _buildStudentCard());
  }

  Widget _buildStudentCard() {
    return Transform.translate(
      offset: Offset(onHover ? -10 : 0, onHover ? -10 : 0),
      child: Card(
        elevation: onHover ? 10 : 4,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: onHover ? Colors.red : Colors.transparent),
            borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 300,
                height: 320,
                decoration: BoxDecoration(
                    image: widget.student.image != null &&
                            widget.student.image!.isNotEmpty
                        ? DecorationImage(
                            image: MemoryImage(
                                base64Decode(widget.student.image!)),
                            fit: BoxFit.cover)
                        : const DecorationImage(
                            image: AssetImage(Assets.imagesImageP),
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
                      fontSize: 16, fontWeight: FontWeight.bold),
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
                      style: getTextStyle(fontSize: 15, color: Colors.grey),
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
                      style: getTextStyle(fontSize: 15, color: Colors.grey),
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
    );
  }
}
