import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_columns_model.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_rows_model.dart';
import 'package:residency_desktop/core/widgets/table/widgets/custom_table.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/keyFlow/provider/key_flow_provider.dart';

class KeyFlowPage extends ConsumerStatefulWidget {
  const KeyFlowPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _KeyFlowPageState();
}

class _KeyFlowPageState extends ConsumerState<KeyFlowPage> {
  @override
  Widget build(BuildContext context) {
    var keyLogData = ref.watch(keyLogProvider);
    var me = ref.watch(myselfProvider);
    var keyLogNotifier = ref.read(keyLogProvider.notifier);
    var tableTextStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontFamily: 'openSans', fontSize: 14, fontWeight: FontWeight.w500);
    return Container(
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          const PageHeaders(
            title: 'Key Logs',
            subTitle: 'All the key activities within the hall',
            hasBackButton: false,
            hasExtraButton: false,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: CustomTable<KeyLogModel>(
                  header: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                                          color: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .color!,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                      children: [
                                    TextSpan(
                                      text: ref.watch(keyLogFilter),
                                      style: getTextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .color!,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ])),

                              const Spacer(),
                              //close if there is filter
                              if (ref.watch(keyLogFilter) != 'All')
                                InkWell(
                                  onTap: () {
                                    keyLogNotifier.init();
                                    ref.read(keyLogFilter.notifier).state =
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
                                      keyLogNotifier.filterByDate(value, ref);
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
                              hintText: 'Search for key logs',
                              suffixIcon: const Icon(Icons.search),
                              onChanged: (query) {
                                keyLogNotifier.search(query);
                              },
                            ),
                          ),
                          const SizedBox(width: 25),
                          if (me.role == Role.hallAdmin)
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
                                          keyLogNotifier.exportKeyLogs(
                                            dataLength: 'all',
                                            format: 'pdf',
                                          );
                                        } else {
                                          keyLogNotifier.exportKeyLogs(
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
                                          keyLogNotifier.exportKeyLogs(
                                            dataLength: 'all',
                                            format: 'xlsx',
                                          );
                                        } else {
                                          keyLogNotifier.exportKeyLogs(
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
                  currentIndex: keyLogData.currentPageItems.isNotEmpty
                      ? keyLogData.items
                              .indexOf(keyLogData.currentPageItems[0]) +
                          1
                      : 0,
                  lastIndex: keyLogData.pageSize * (keyLogData.currentPage + 1),
                  pageSize: keyLogData.pageSize,
                  onPageSizeChanged: (value) {
                    keyLogNotifier.onPageSizeChange(value!);
                  },
                  onPreviousPage: keyLogData.hasPreviousPage
                      ? () {
                          keyLogNotifier.previousPage();
                        }
                      : null,
                  onNextPage: keyLogData.hasNextPage
                      ? () {
                          keyLogNotifier.nextPage();
                        }
                      : null,
                  rows: [
                    for (int i = 0; i < keyLogData.currentPageItems.length; i++)
                      CustomTableRow(
                        item: keyLogData.currentPageItems[i],
                        index: i,
                        context: context,
                        selectRow: (value) {},
                        isSelected: false,
                      )
                  ],
                  showColumnHeadersAtFooter: true,
                  data: keyLogData.items,
                  columns: [
                    //id
                    CustomTableColumn(
                        title: 'ID',
                        width: 120,
                        cellBuilder: (item) => Text(
                              item.id ?? '',
                              style: tableTextStyle,
                            )),
                    CustomTableColumn(
                        title: 'Student Name',
                        cellBuilder: (item) => Text(
                              item.studentName ?? '',
                              style: tableTextStyle,
                            )),
                    CustomTableColumn(
                        width: 100,
                        title: 'Room No.',
                        isNumeric: true,
                        cellBuilder: (item) => Text(
                              item.roomNumber ?? '',
                              style: tableTextStyle,
                            )),
                    CustomTableColumn(
                        title: 'Activity',
                        width: 200,
                        cellBuilder: (item) => Row(
                              children: [
                                Icon(
                                  item.activity!.toLowerCase().contains('in')
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: item.activity!
                                          .toLowerCase()
                                          .contains('in')
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item.activity!.toLowerCase().contains('in')
                                      ? 'Returning'
                                      : 'Collecting',
                                  style: TextStyle(
                                    color: item.activity!
                                            .toLowerCase()
                                            .contains('in')
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            )),
                    CustomTableColumn(
                        title: 'Assistant',
                        cellBuilder: (item) => Text(
                              item.assistantName ?? '',
                              style: tableTextStyle,
                            )),
                    CustomTableColumn(
                        title: 'Date',
                        cellBuilder: (item) => Text(
                              item.date ?? '',
                              style: tableTextStyle,
                            )),
                    CustomTableColumn(
                        title: 'Time',
                        cellBuilder: (item) => Text(
                              item.time ?? '',
                              style: tableTextStyle,
                            )),
                  ]))
        ]));
  }
}
