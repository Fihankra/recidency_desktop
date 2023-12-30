import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_columns_model.dart';
import 'package:residency_desktop/core/widgets/table/widgets/custom_table.dart';
import 'package:residency_desktop/features/dashboard/data/attendance_model.dart';
import 'package:residency_desktop/features/dashboard/provider/attendance_provider.dart';
import '../../../core/widgets/table/data/models/custom_table_rows_model.dart';

class AttendancePage extends ConsumerStatefulWidget {
  const AttendancePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AttendancePageState();
}

class _AttendancePageState extends ConsumerState<AttendancePage> {
  @override
  Widget build(BuildContext context) {
    var attendancesData = ref.watch(attendanceFutureProvider);
    return Container(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          PageHeaders(
            title: 'Assistant Attendance',
            subTitle: 'History of assistant attendance',
            hasBackButton: true,
            onBackButtonPressed: () {
              context.go(RouterInfo.dashboardRoute.path);
            },
            hasExtraButton: false,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: attendancesData.when(data: (data) {
              var attendanceData = ref.watch(attendanceProvider(data));
              var attendanceNotifier =
                  ref.read(attendanceProvider(data).notifier);
              return CustomTable<AttendanceModel>(
                  header: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //filter by date picked
                          Container(
                            width: 300,
                            height: 50,
                            padding: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all()),
                            child: Row(children: [
                              RichText(
                                  text: TextSpan(
                                      text: 'Filtered by: ',
                                      style: getTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                      children: [
                                    TextSpan(
                                      text: ref.watch(attendanceFilter),
                                      style: getTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ])),

                              const Spacer(),
                              //close if there is filter
                              if (ref.watch(attendanceFilter) != 'All')
                                InkWell(
                                  onTap: () {
                                    attendanceNotifier.init();
                                    ref.read(attendanceFilter.notifier).state =
                                        'All';
                                  },
                                  child: Card(
                                      child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        ),
                                    child: const Center(
                                        child: Icon(
                                      Icons.close,
                                      
                                    )),
                                  )),
                                ),
                              InkWell(
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2019),
                                    lastDate: DateTime.now(),
                                    //ondate picked
                                  ).then((value) {
                                    if (value != null) {
                                      attendanceNotifier.filterByDate(
                                          value, ref);
                                    }
                                  });
                                },
                                child: Card(
                                    child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: secondaryColor),
                                  child: const Center(
                                      child: Icon(
                                    Icons.filter_list,
                                    color: Colors.white,
                                  )),
                                )),
                              )
                            ]),
                          ),
                          const SizedBox(width: 15),
                         
                            SizedBox(
                              width: 500,
                              child: CustomTextFields(
                                hintText: 'Search for assistant name',
                                suffixIcon: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      ref
                                          .read(isAttendanceSearchingProvider
                                              .notifier)
                                          .state = false;
                                    }),
                                onChanged: (query) {
                                  attendanceNotifier.search(query);
                                },
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              
                                PopupMenuButton(
                                  
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                        value: 'pdf',
                                        child: Row(
                                          children: [
                                            Icon(FontAwesomeIcons.filePdf),
                                            SizedBox(width: 5),
                                            Text('Export as PDF'),
                                          ],
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
                                      const PopupMenuItem(
                                        value: 'excel',
                                        child: Row(
                                          children: [
                                            Icon(FontAwesomeIcons.fileExcel),
                                            SizedBox(width: 5),
                                            Text('Export as Excel'),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                  onSelected: (value) {},
                                  child:Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 15),
                                          decoration: BoxDecoration(
                                            color: secondaryColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border:
                                                Border.all(color: primaryColor),
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
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                            ],
                          ),
                        ]),
                  ),
                  currentIndex: attendanceData.currentPageItems.isNotEmpty
                      ? data.indexOf(attendanceData.currentPageItems[0]) + 1
                      : 0,
                  lastIndex: attendanceData.pageSize *
                      (attendanceData.currentPage + 1),
                  pageSize: attendanceData.pageSize,
                  onPageSizeChanged: (value) {
                    attendanceNotifier.onPageSizeChange(value!);
                  },
                  onPreviousPage: attendanceData.hasPreviousPage
                      ? () {
                          attendanceNotifier.previousPage();
                        }
                      : null,
                  onNextPage: attendanceData.hasNextPage
                      ? () {
                          attendanceNotifier.nextPage();
                        }
                      : null,
                  rows: [
                    for (int i = 0;
                        i < attendanceData.currentPageItems.length;
                        i++)
                      CustomTableRow(
                        item: attendanceData.currentPageItems[i],
                        index: i,
                        context: context,
                        selectRow: (value) {},
                        isSelected: false,
                      )
                  ],
                  showColumnHeadersAtFooter: true,
                  data: data,
                  columns: [
                    CustomTableColumn(
                        title: 'ID',
                        // width: 120,
                        cellBuilder: (attendance) => Text(attendance.id ?? '')),
                    CustomTableColumn(
                        title: 'Assistant ID',
                        cellBuilder: (attendance) =>
                            Text(attendance.assistantId ?? '')),
                    CustomTableColumn(
                        title: 'Assistant Name',
                        cellBuilder: (attendance) =>
                            Text(attendance.assistantName ?? '')),
                    CustomTableColumn(
                        title: 'Action',
                        cellBuilder: (attendance) => Row(
                              children: [
                                Icon(
                                  attendance.action!
                                          .toLowerCase()
                                          .contains('login')
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: attendance.action!
                                          .toLowerCase()
                                          .contains('login')
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  attendance.action ?? '',
                                  style: TextStyle(
                                    color: attendance.action!
                                            .toLowerCase()
                                            .contains('login')
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            )),
                    CustomTableColumn(
                        title: 'Date',
                        cellBuilder: (attendance) =>
                            Text(attendance.date ?? '')),
                    CustomTableColumn(
                        title: 'Time',
                        cellBuilder: (attendance) =>
                            Text(attendance.time ?? '')),
                  ]);
            }, error: (error, stack) {
              return const Center(child: Text('Something went wrong'));
            }, loading: () {
              return const Center(child: CircularProgressIndicator());
            }),
          ),
        ]));
  }
}
