import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/functions/date_time.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_columns_model.dart';
import 'package:residency_desktop/core/widgets/table/data/models/custom_table_rows_model.dart';
import 'package:residency_desktop/core/widgets/table/widgets/custom_table.dart';
import 'package:residency_desktop/features/messages/data/message_model.dart';
import 'package:residency_desktop/features/messages/provider/message_provider.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    var messages = ref.watch(messageProvider);
    var messagesNotifier = ref.watch(messageProvider.notifier);
    var tableTextStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontFamily: 'openSans', fontSize: 14, fontWeight: FontWeight.w500);
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        PageHeaders(
          title: 'Broadcast Messages',
          subTitle: 'List of all broadcast messages',
          hasBackButton: false,
          extraButtonText: 'New Message',
          hasExtraButton: true,
          onExtraButtonPressed: () {
            context.go(RouterInfo.newMessageRoute.path);
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: CustomTable<MessageModel>(
                header:
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(
                    width: 500,
                    child: CustomTextFields(
                      hintText: 'Search for a message',
                      suffixIcon: const Icon(Icons.search),
                      onChanged: (value) {
                        messagesNotifier.search(value);
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
                                messagesNotifier.exportMessages(
                                  dataLength: 'all',
                                  format: 'pdf',
                                );
                              } else {
                                messagesNotifier.exportMessages(
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
                                messagesNotifier.exportMessages(
                                  dataLength: 'all',
                                  format: 'xlsx',
                                );
                              } else {
                                messagesNotifier.exportMessages(
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
                currentIndex: messages.currentPageItems.isNotEmpty
                    ? messages.items.indexOf(messages.currentPageItems[0]) + 1
                    : 0,
                lastIndex: messages.pageSize * (messages.currentPage + 1),
                pageSize: messages.pageSize,
                onPageSizeChanged: (value) {
                  messagesNotifier.onPageSizeChange(value!);
                },
                onPreviousPage: messages.hasPreviousPage
                    ? () {
                        messagesNotifier.previousPage();
                      }
                    : null,
                onNextPage: messages.hasNextPage
                    ? () {
                        messagesNotifier.nextPage();
                      }
                    : null,
                showColumnHeadersAtFooter: true,
                data: messages.items,
                rows: [
              for (int i = 0; i < messages.currentPageItems.length; i++)
                CustomTableRow(
                  item: messages.currentPageItems[i],
                  index: i,
                  context: context,
                  selectRow: (value) {},
                  isSelected: false,
                )
            ],
                columns: [
              CustomTableColumn(
                title: 'ID',
                width: 150,
                cellBuilder: (message) => Text(
                  message.id ?? '',
                  style: tableTextStyle,
                ),
              ),
              CustomTableColumn(
                title: 'Sender ID',
                cellBuilder: (message) => Text(
                  message.senderId ?? '',
                  style: tableTextStyle,
                ),
              ),
              CustomTableColumn(
                title: 'Message',
                cellBuilder: (message) => Text(
                  message.message ?? '',
                  style: tableTextStyle,
                ),
              ),
              CustomTableColumn(
                  title: 'Status',
                  width: 150,
                  cellBuilder: (message) {
                    return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: message.status!.toLowerCase() == 'pending'
                              ? Colors.black45
                              : message.status!.toLowerCase() == 'success'
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(message.status ?? ''));
                  }),
              CustomTableColumn(
                title: 'Total Recipients',
                width: 150,
                cellBuilder: (message) => Text(
                  message.recipients!.length.toString(),
                  style: tableTextStyle,
                ),
              ),
              CustomTableColumn(
                title: 'Accademic Year',
                width: 150,
                cellBuilder: (message) => Text(
                  message.accademicYear ?? '',
                  style: tableTextStyle,
                ),
              ),
              CustomTableColumn(
                title: 'Created At',
                cellBuilder: (message) => Text(
                  DateTimeAction.getDateTime(message.createdAt!),
                  style: tableTextStyle,
                ),
              ),
              //action to mark as deleted
              CustomTableColumn(
                title: 'Action',
                width: 150,
                cellBuilder: (message) => IconButton(
                  onPressed: () {
                    ref.read(selectedMessageProvider.notifier).deleteMessage(ref,message);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
            ])),
      ]),
    );
  }
}
