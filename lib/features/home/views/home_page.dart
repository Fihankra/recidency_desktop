import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/home/provider/key_flowlog_provider.dart';
import 'package:residency_desktop/features/home/views/componenets/student_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var keyFlow = ref.watch(keyflowProvider);
    var keyFlowRead = ref.read(keyflowProvider.notifier);
    var me = ref.read(myselfProvider);
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        PageHeaders(
          title: me.role != Role.hallAdmin ? 'Hall Key Flow' : 'Allocations',
          subTitle: me.role != Role.hallAdmin
              ? 'Enter  room number to get the key history of the room'
              : 'Enter room number to get the students in the room',
          hasBackButton: false,
        ),
        const SizedBox(
          height: 25,
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                width: 750,
                child: CustomTextFields(
                  controller: _textController,
                  hintText: 'Enter room number',
                  suffixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    keyFlowRead.searchStudent(value);
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (me.role != Role.hallAdmin)
                          if (keyFlow.lastKeyLog != null &&
                              keyFlow.lastKeyLog!.id != null)
                            Card(
                              child: SizedBox(
                                width: 500,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            image: keyFlow.lastKeyLog!
                                                        .studentImage !=
                                                    null
                                                ? DecorationImage(
                                                    image: FileImage(File(
                                                        keyFlow.lastKeyLog!
                                                            .studentImage!)),
                                                    fit: BoxFit.cover)
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Key for this room was last ${keyFlow.lastKeyLog!.activity == 'in' ? 'Returned' : 'Taken'} by ${keyFlow.lastKeyLog!.studentName}',
                                              style: getTextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color),
                                            ),
                                            const Divider(),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            //last key log student details
                                            //id
                                            Row(
                                              children: [
                                                Text(
                                                  'Student ID: ',
                                                  style: getTextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                                Text(
                                                  keyFlow
                                                      .lastKeyLog!.studentId!,
                                                  style: getTextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            //name
                                            Row(
                                              children: [
                                                Text(
                                                  'Student Name: ',
                                                  style: getTextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                                Text(
                                                  keyFlow
                                                      .lastKeyLog!.studentName!,
                                                  style: getTextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            //phone
                                            Row(
                                              children: [
                                                Text(
                                                  'Student Phone: ',
                                                  style: getTextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                                Text(
                                                  keyFlow.lastKeyLog!
                                                      .studentPhone!,
                                                  style: getTextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                              ],
                                            ),
                                            //date and time
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Date : ',
                                                  style: getTextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                                Text(
                                                  keyFlow.lastKeyLog!.date!,
                                                  style: getTextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Time : ',
                                                  style: getTextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                                Text(
                                                  keyFlow.lastKeyLog!.time!,
                                                  style: getTextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ))
                                    ]),
                              ),
                            ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (keyFlow.students.isNotEmpty)
                          Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              children: keyFlow.students
                                  .map((e) => StudentCard(
                                        controller: _textController,
                                        student: e,
                                        keyLog: keyFlow.lastKeyLog,
                                      ))
                                  .toList())
                        else
                          const Text(
                            'No Student found in this room',
                          )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ))
      ]),
    );
  }
}
