import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_columns_model.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_rows_model.dart';
import 'package:residency_desktop/core/widgets/table/widgets/custom_table.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/features/students/provider/student_provider.dart';
import 'package:residency_desktop/features/students/usecase/student_usecase.dart';
import 'package:residency_desktop/features/students/views/components/view_student.dart';

class StudentList extends ConsumerStatefulWidget {
  const StudentList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StudentListState();
}

class _StudentListState extends ConsumerState<StudentList> {
  @override
  void initState() {
    //saveDummyStudents();
    super.initState();
  }

  saveDummyStudents() async {
    var students = await StudentModel.dummyDtata();
    var db = ref.watch(dbProvider);
    for (var student in students) {
      await StudentUsecase(db: db!).addStudent(student);
    }
    ref.invalidate(studentFutureProvider);
  }

  @override
  Widget build(BuildContext context) {
    var students = ref.watch(studentFutureProvider);
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        PageHeaders(
          title: 'Residential Students',
          subTitle: 'List of all Residential Students',
          hasBackButton: false,
          extraButtonText: 'New Student',
          hasExtraButton: true,
          onExtraButtonPressed: () {
            context.go(RouterInfo.newStudentRoute.path);
          },
        ),
        const SizedBox(
          height: 10,
        ),
        students.when(data: (data) {
          data.sort((a, b) => a.firstname!.compareTo(b.firstname!));
          var studentsData = ref.watch(studentProvider(data));
          var studentReader = ref.read(studentProvider(data).notifier);
          var tableTextStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontFamily: 'openSans',
              fontSize: 14,
              fontWeight: FontWeight.w500);
          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomTable<StudentModel>(
                    currentIndex: studentsData.currentPageItems.isEmpty
                        ? 0
                        : data.indexOf(studentsData.currentPageItems[0]) + 1,
                    lastIndex:
                        studentsData.pageSize * (studentsData.currentPage + 1),
                    pageSize: studentsData.pageSize,
                    onPageSizeChanged: (value) {
                      studentReader.onPageSizeChange(value!);
                    },
                    onPreviousPage: studentsData.hasPreviousPage
                        ? () {
                            studentReader.previousPage();
                          }
                        : null,
                    onNextPage: studentsData.hasNextPage
                        ? () {
                            studentReader.nextPage();
                          }
                        : null,
                    showColumnHeadersAtFooter: true,
                    rows: [
                      for (var item in studentsData.currentPageItems)
                        CustomTableRow<StudentModel>(
                          item: item,
                          context: context,
                          index: studentsData.currentPageItems.indexOf(item),
                          selectRow: (value) {},
                          isSelected: false,
                        ),
                    ],
                    columns: [
                      CustomTableColumn(
                        title: 'Image',
                        width: 60,
                        cellBuilder: (student) {
                          return CircleAvatar(
                            radius: 20,
                            backgroundImage: FileImage(File(student.image!)),
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Student ID',
                        width: 150,
                        cellBuilder: (student) {
                          return Text(
                            student.id ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Firstname',
                        cellBuilder: (student) {
                          return Text(
                            student.firstname ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Surname',
                        cellBuilder: (student) {
                          return Text(
                            student.surname ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Gender',
                        width: 100,
                        cellBuilder: (student) {
                          return Text(
                            student.gender ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Phone',
                        cellBuilder: (assistant) {
                          return Text(
                            assistant.phone ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Block',
                        width: 100,
                        cellBuilder: (student) {
                          return Text(
                            student.block ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Room',
                        width: 80,
                        isNumeric: true,
                        cellBuilder: (student) {
                          return Text(
                            student.room ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Level',
                        width: 100,
                        cellBuilder: (student) {
                          return Text(
                            student.level ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Departemt',
                        cellBuilder: (student) {
                          return Text(
                            student.department ?? '',
                            style: tableTextStyle,
                          );
                        },
                      ),
                      //actions
                      CustomTableColumn(
                        title: 'Actions',
                        width: 200,
                        cellBuilder: (student) {
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(selectedStudentProvider.notifier)
                                      .setStudent(student);
                                  context.go(
                                    RouterInfo.editStudentRoute.path,
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: secondaryColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  CustomDialog.showCustom(
                                      ui: ViewStudent(
                                    student: student,
                                  ));
                                },
                                icon: Icon(
                                  MdiIcons.eye,
                                  color: primaryColor,
                                ),
                              ),
                              //delete
                              IconButton(
                                onPressed: () {
                                  CustomDialog.showInfo(
                                      message:
                                          'Are you sure you want to delete this student?',
                                      buttonText: 'Delete',
                                      onPressed: () {
                                        ref
                                            .read(selectedStudentProvider
                                                .notifier)
                                            .deleteStudent(student, ref);
                                      });
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    data: studentsData.items,
                    header: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //search
                          SizedBox(
                            width: 500,
                            child: CustomTextFields(
                              hintText: 'Search Student',
                              suffixIcon: const Icon(Icons.search),
                              onChanged: (value) {
                                studentReader.search(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 25),
                          //export popup menu
                          PopupMenuButton(
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  value: 'pdf',
                                  child: PopupMenuButton<int>(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 1,
                                        child: Row(
                                          children: [
                                            Icon(Icons.all_inbox),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("All Data")
                                          ],
                                        ),
                                      ),
                                      // popupmenu item 2
                                      const PopupMenuItem(
                                        value: 2,
                                        // row has two child icon and text
                                        child: Row(
                                          children: [
                                            Icon(Icons.table_rows),
                                            SizedBox(
                                              // sized box with width 10
                                              width: 10,
                                            ),
                                            Text("Table Content")
                                          ],
                                        ),
                                      ),
                                    ],
                                    elevation: 2,
                                    child: const Row(
                                      children: [
                                        Icon(FontAwesomeIcons.filePdf),
                                        SizedBox(width: 5),
                                        Text('Export as PDF'),
                                      ],
                                    ),
                                    onSelected: (value) {
                                      if (value == 1) {
                                        studentReader.exportStudent(
                                          dataLength: 'all',
                                          format: 'pdf',
                                        );
                                      } else {
                                        studentReader.exportStudent(
                                          dataLength: 'table',
                                          format: 'pdf',
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const PopupMenuItem(
                                  height: 2,
                                  enabled: false,
                                  child: Divider(
                                    color: primaryColor,
                                    thickness: 2,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'excel',
                                  child: PopupMenuButton<int>(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 1,
                                        child: Row(
                                          children: [
                                            Icon(Icons.all_inbox),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text("All Data")
                                          ],
                                        ),
                                      ),
                                      // popupmenu item 2
                                      const PopupMenuItem(
                                        value: 2,
                                        // row has two child icon and text
                                        child: Row(
                                          children: [
                                            Icon(Icons.table_rows),
                                            SizedBox(
                                              // sized box with width 10
                                              width: 10,
                                            ),
                                            Text("Table Content")
                                          ],
                                        ),
                                      ),
                                    ],
                                    elevation: 2,
                                    child: const Row(
                                      children: [
                                        Icon(FontAwesomeIcons.fileExcel),
                                        SizedBox(width: 5),
                                        Text('Export as Excel'),
                                      ],
                                    ),
                                    onSelected: (value) {
                                      if (value == 1) {
                                        studentReader.exportStudent(
                                          dataLength: 'all',
                                          format: 'xlsx',
                                        );
                                      } else {
                                        studentReader.exportStudent(
                                          dataLength: 'table',
                                          format: 'xlsx',
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ];
                            },
                            onSelected: (value) {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: primaryColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    MdiIcons.export,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Export',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          );
        }, error: (error, stack) {
          return const Expanded(
            child: Center(child: Text('Something went wrong')),
          );
        }, loading: () {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }),
      ]),
    );
  }
}
