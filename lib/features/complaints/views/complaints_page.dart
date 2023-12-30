import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/core/functions/date_time.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_columns_model.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_rows_model.dart';
import 'package:residency_desktop/core/widgets/table/widgets/custom_table.dart';
import 'package:residency_desktop/features/complaints/data/complaints.model.dart';
import 'package:residency_desktop/features/complaints/provider/complaints_provider.dart';
import 'package:residency_desktop/features/complaints/views/view_compliants.dart';

import '../../auth/provider/mysefl_provider.dart';

class ComplaintsPage extends ConsumerStatefulWidget {
  const ComplaintsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends ConsumerState<ComplaintsPage> {
  @override
  Widget build(BuildContext context) {
    var complaints = ref.watch(complaintsFutureProvider);
    var me = ref.watch(myselfProvider);
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        PageHeaders(
            title: 'Student\'s Complaints',
            subTitle: 'View all complaints from students',
            hasBackButton: false,
            hasExtraButton: me.role != Role.hallAdmin,
            extraButtonText: 'New Complaint',
            onExtraButtonPressed: () {
              context.go(RouterInfo.newComplaintRoute.path);
            }),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: complaints.when(
            data: (data) {
              data.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
              var complaintsData = ref.watch(complaintsProvider(data));
              var complaintsNotifier =
                  ref.read(complaintsProvider(data).notifier);
              return CustomTable<ComplaintsModel>(
                  header:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    SizedBox(
                      width: 500,
                      child: CustomTextFields(
                        hintText: 'Search for complaint',
                        suffixIcon: const Icon(Icons.close),
                        onChanged: (value) {
                          complaintsNotifier.search(value);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
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
                                  complaintsNotifier
                                      .exportComplaints(
                                        dataLength: 'all',
                                        format: 'pdf',
                                      );
                                } else {
                                    complaintsNotifier.exportComplaints(
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
                                   complaintsNotifier.exportComplaints(
                                        dataLength: 'all',
                                        format: 'xlsx',
                                      );
                                } else {
                                   complaintsNotifier.exportComplaints(
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
                  currentIndex: complaintsData.currentPageItems.isNotEmpty
                      ? data.indexOf(complaintsData.currentPageItems[0]) + 1
                      : 0,
                  lastIndex: complaintsData.pageSize *
                      (complaintsData.currentPage + 1),
                  pageSize: complaintsData.pageSize,
                  onPageSizeChanged: (value) {
                    complaintsNotifier.onPageSizeChange(value!);
                  },
                  onPreviousPage: complaintsData.hasPreviousPage
                      ? () {
                          complaintsNotifier.previousPage();
                        }
                      : null,
                  onNextPage: complaintsData.hasNextPage
                      ? () {
                          complaintsNotifier.nextPage();
                        }
                      : null,
                  rows: [
                    for (int i = 0;
                        i < complaintsData.currentPageItems.length;
                        i++)
                      CustomTableRow(
                        item: complaintsData.currentPageItems[i],
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
                      width: 150,
                      cellBuilder: (complaint) {
                        return Text(complaint.id.toString());
                      },
                    ),
                    CustomTableColumn(
                      title: 'Title',
                      cellBuilder: (complaint) {
                        return Text(complaint.title ?? '');
                      },
                    ),
                    CustomTableColumn(
                      title: 'Description',
                      cellBuilder: (complaint) {
                        return Text(complaint.description ?? '');
                      },
                    ),
                    CustomTableColumn(
                      title: 'Student Name',
                      cellBuilder: (complaint) {
                        return Text(complaint.studentName ?? '');
                      },
                    ),
                    CustomTableColumn(
                      title: 'Phone',
                      cellBuilder: (complaint) {
                        return Text(complaint.studentPhone ?? '');
                      },
                    ),
                    CustomTableColumn(
                      title: 'Room',
                      width: 50,
                      cellBuilder: (complaint) {
                        return Text(complaint.roomNumber.toString());
                      },
                    ),
                    CustomTableColumn(
                      title: 'Type',
                      width: 100,
                      cellBuilder: (complaint) {
                        return Text(complaint.type ?? '');
                      },
                    ),
                    CustomTableColumn(
                      title: 'Severity',
                      width: 100,
                      cellBuilder: (complaint) {
                        return Text(complaint.severity ?? '');
                      },
                    ),
                    CustomTableColumn(
                      title: 'Status',
                      width: 100,
                      cellBuilder: (complaint) {
                        return Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color:
                                  complaint.status!.toLowerCase() == 'pending'
                                      ? Colors.black45
                                      : complaint.status!.toLowerCase() ==
                                              'in progress'
                                          ? Colors.yellow
                                          : complaint.status!.toLowerCase() ==
                                                  'resolved'
                                              ? Colors.green
                                              : Colors.red,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(complaint.status ?? ''));
                      },
                    ),
                    CustomTableColumn(
                      title: 'Created At',
                      width: 200,
                      cellBuilder: (complaint) {
                        return Text(
                            DateTimeAction.getDateTime(complaint.createdAt!));
                      },
                    ),
                    //actions
                    CustomTableColumn(
                      title: 'Actions',
                      width: 100,
                      cellBuilder: (complaint) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //view Complaint
                            IconButton(
                              onPressed: () {
                                CustomDialog.showCustom(
                                    ui: ViewComplaints(
                                  complaint: complaint,
                                ));
                              },
                              icon: const Icon(
                                Icons.remove_red_eye,
                              ),
                            ),
                            //dropdown for status change
                            if (complaint.status!.toLowerCase() != 'resolved')
                              PopupMenuButton(
                                color: Colors.white,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    child: Text('Mark as :'),
                                  ),
                                  if (complaint.status!.toLowerCase() !=
                                      'pending')
                                    const PopupMenuItem(
                                      value: 'pending',
                                      child: Row(
                                        children: [
                                          Icon(Icons.pending_actions),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('Pending'),
                                        ],
                                      ),
                                    ),
                                  if (complaint.status!.toLowerCase() !=
                                      'in progress')
                                    const PopupMenuItem(
                                      value: 'in progress',
                                      child: Row(
                                        children: [
                                          Icon(FontAwesomeIcons.listCheck),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('In Progress'),
                                        ],
                                      ),
                                    ),
                                  if (complaint.status!.toLowerCase() !=
                                      'resolved')
                                    const PopupMenuItem(
                                      value: 'resolved',
                                      child: Row(
                                        children: [
                                          Icon(Icons.check),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('Resolved'),
                                        ],
                                      ),
                                    ),
                                  if (complaint.status!.toLowerCase() !=
                                      'rejected')
                                    const PopupMenuItem(
                                      value: 'rejected',
                                      child: Row(
                                        children: [
                                          Icon(Icons.close),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text('Rejected'),
                                        ],
                                      ),
                                    ),
                                ],
                                onSelected: (value) {
                                  complaintsNotifier.updateStatus(
                                      context: context,
                                      complaint: complaint,
                                      status: value.toString());
                                },
                                child: const Icon(
                                  Icons.more_vert,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ]);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => const Center(
              child: Text('Something went wrong'),
            ),
          ),
        ),
      ]),
    );
  }
}
