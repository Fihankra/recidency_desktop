import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_columns_model.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_rows_model.dart';
import 'package:residency_desktop/core/widgets/table/widgets/custom_table.dart';
import 'package:residency_desktop/features/dashboard/data/attendance_model.dart';
import 'package:residency_desktop/features/dashboard/provider/attendance_provider.dart';
import 'package:residency_desktop/features/dashboard/views/components/dashboard_card.dart';

import '../../container/provider/main_provider.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    var attendancesData = ref.watch(attendanceFutureProvider);
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          const PageHeaders(
            title: 'Dashboard',
            subTitle: 'List of all Residential Students',
            hasBackButton: false,
            hasExtraButton: false,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: Text('System Statics'.toUpperCase(),
                        style: getTextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25)),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        children: [
                          DashBoardCard(
                            title: 'Students',
                            value: ref
                                .watch(studentDataProvider)
                                .length
                                .toString(),
                            icon: MdiIcons.school,
                            color: Colors.blue,
                          ),
                          DashBoardCard(
                            title: 'Assistants',
                            value:
                                ref.watch(staffDataProvider).length.toString(),
                            icon: MdiIcons.accountGroup,
                            color: Colors.green,
                          ),
                        
                               DashBoardCard(
                                title: 'Complaints',
                                value: ref
                                    .watch(complaintDataProvider)
                                    .length
                                    .toString(),
                                icon: FontAwesomeIcons.listCheck,
                                color: Colors.red,
                              )
                          
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // attendence table
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text('Today Attendance'.toUpperCase(),
                              style: getTextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        TextButton(
                            onPressed: () {
                              context.go(RouterInfo.attendanceRoute.path);
                            },
                            child: Text(
                              'View All',
                              style: getTextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: 15),
                            ))
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: attendancesData.when(data: (data) {
                        var todayAttendance =
                            ref.watch(todayAttendanceProvider(data));
                        //limit to 10
                        todayAttendance = todayAttendance.length > 10
                            ? todayAttendance.sublist(0, 10)
                            : todayAttendance;
                        return SizedBox(
                          height: 500,
                          child: CustomTable<AttendanceModel>(
                              data: todayAttendance,
                              pageSize: 10,
                              rows: [
                                for (int i = 0; i < todayAttendance.length; i++)
                                  CustomTableRow<AttendanceModel>(
                                      context: context,
                                      index: i,
                                      item: todayAttendance[i])
                              ],
                              columns: [
                                CustomTableColumn(
                                    title: 'ID',
                                    width: 120,
                                    cellBuilder: (attendance) =>
                                        Text(attendance.id ?? '')),
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
                              ]),
                        );
                      }, error: (error, stack) {
                        return const Center(
                          child: Text('Something went wrong'),
                        );
                      }, loading: () {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),
          )
        ]));
  }
}
