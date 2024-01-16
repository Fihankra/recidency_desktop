import 'dart:convert';
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
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_rows_model.dart';
import 'package:residency_desktop/core/widgets/table/widgets/custom_table.dart';
import 'package:residency_desktop/features/staffs/data/staff_model.dart';
import 'package:residency_desktop/features/staffs/provider/staff_provider.dart';
import 'package:residency_desktop/features/staffs/views/components/view_staff.dart';
import '../../../../../core/widgets/table/data/models/custom_table_columns_model.dart';

class StaffListPage extends ConsumerStatefulWidget {
  const StaffListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StaffListPageState();
}

class _StaffListPageState extends ConsumerState<StaffListPage> {
  @override
  @override
  Widget build(BuildContext context) {
     var staffData = ref.watch(staffProvider);
          var staffNotifier = ref.watch(staffProvider.notifier);
          var tableTextStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontFamily: 'openSans',
              fontSize: 14,
              fontWeight: FontWeight.w500);
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        PageHeaders(
          title: 'Hall Staffs',
          subTitle: 'List of all hall staffs',
          hasBackButton: false,
          extraButtonText: 'New Staff',
          hasExtraButton: true,
          hasSecondExtraButton: false,
          secondExtraButtonText: 'Import From Year',
          onExtraButtonPressed: () {
            context.go(RouterInfo.newAssistantRoute.path);
          },
        ),
        const SizedBox(
          height: 10,
        ),
    
         
        Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomTable<StaffModel>(
                    currentIndex: staffData.currentPageItems.isNotEmpty
                        ? staffData.items.indexOf(staffData.currentPageItems[0]) + 1
                        : 0,
                    lastIndex: staffData.pageSize *
                        (ref.watch(staffProvider).currentPage + 1),
                    pageSize: staffData.pageSize,
                    onPageSizeChanged: (value) {
                      staffNotifier.onPageSizeChange(value!);
                    },
                    onPreviousPage: staffData.hasPreviousPage
                        ? () {
                            staffNotifier.previousPage();
                          }
                        : null,
                    onNextPage: staffData.hasNextPage
                        ? () {
                            staffNotifier.nextPage();
                          }
                        : null,
                    rows: [
                      for (int i = 0;
                          i < staffData.currentPageItems.length;
                          i++)
                        CustomTableRow(
                          item: staffData.currentPageItems[i],
                          context: context,
                          index: i,
                          selectRow: (value) {},
                          isSelected: false,
                        )
                    ],
                    showColumnHeadersAtFooter: true,
                    columns: [
                      CustomTableColumn(
                        title: 'Image',
                        width: 60,
                        cellBuilder: (assistant) {
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: assistant.image != null
                                ? MemoryImage(base64Decode(assistant.image!))
                                : null,
                          );
                        },
                      ),
                      CustomTableColumn(
                        title: 'Staff ID',
                        width: 150,
                        cellBuilder: (assistant) {
                          return Text(assistant.id ?? '',
                              style: tableTextStyle);
                        },
                      ),
                      CustomTableColumn(
                        title: 'Firstname',
                        cellBuilder: (assistant) {
                          return Text(assistant.firstname ?? '',
                              style: tableTextStyle);
                        },
                      ),
                      CustomTableColumn(
                        title: 'Surname',
                        cellBuilder: (assistant) {
                          return Text(assistant.surname ?? '',
                              style: tableTextStyle);
                        },
                      ),
                      CustomTableColumn(
                        title: 'Gender',
                        width: 100,
                        cellBuilder: (assistant) {
                          return Text(assistant.gender ?? '',
                              style: tableTextStyle);
                        },
                      ),
                      CustomTableColumn(
                        title: 'Role',
                        width: 100,
                        cellBuilder: (assistant) {
                          return Text(assistant.role ?? '',
                              style: tableTextStyle);
                        },
                      ),
                      CustomTableColumn(
                        title: 'Email',
                        cellBuilder: (assistant) {
                          return Text(assistant.email ?? '',
                              style: tableTextStyle);
                        },
                      ),
                      CustomTableColumn(
                        title: 'Phone',
                        cellBuilder: (assistant) {
                          return Text(assistant.phone ?? '',
                              style: tableTextStyle);
                        },
                      ),
                      //actions
                      CustomTableColumn(
                        title: 'Actions',
                        width: 200,
                        cellBuilder: (assistant) {
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(selectedAssistantProvider.notifier)
                                      .setSelectedStaff(assistant);
                                  context.go(
                                    RouterInfo.editAssistantRoute.path,
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
                                      ui: ViewStaff(
                                    staff: assistant,
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
                                          'Are you sure you want to delete this staff?',
                                      buttonText: 'Delete',
                                      onPressed: () {
                                        ref
                                            .read(selectedAssistantProvider
                                                .notifier)
                                            .deleteStaff(assistant, ref);
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
                    data: staffData.items,
                    header: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          //search
                          SizedBox(
                            width: 500,
                            child: CustomTextFields(
                              hintText: 'Search Staffs',
                              suffixIcon: const Icon(Icons.search),
                              onChanged: (value) {
                                staffNotifier.searchStaff(value);
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
                                        staffNotifier.exportStaff(
                                          dataLength: 'all',
                                          format: 'pdf',
                                        );
                                      } else {
                                        staffNotifier.exportStaff(
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
                                        staffNotifier.exportStaff(
                                          dataLength: 'all',
                                          format: 'xlsx',
                                        );
                                      } else {
                                        staffNotifier.exportStaff(
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
          )
        
      ]),
    );
  }
}
