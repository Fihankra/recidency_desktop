import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/core/widgets/table/widgets/custom_table.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';

import '../../../core/widgets/custom_dialog.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/table/data/models/custom_table_columns_model.dart';
import '../../../core/widgets/table/data/models/custom_table_rows_model.dart';
import '../provider/message_provider.dart';

class NewMessagePage extends ConsumerStatefulWidget {
  const NewMessagePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends ConsumerState<NewMessagePage> {
  final _formKey = GlobalKey<FormState>();
  int index = 0;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        PageHeaders(
          title: 'New Broadcast Message',
          subTitle: 'Please fill the form below to send a new student',
          hasBackButton: true,
          onBackButtonPressed: () {
            context.go(RouterInfo.messagesRoute.path);
          },
          hasExtraButton: false,
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: IndexedStack(
            alignment: Alignment.center,
            index: index,
            children: [_buildDesktop(), _viewSelectedReceipient()],
          ),
        )
      ]),
    );
  }

  Widget _buildDesktop() {
    var size = MediaQuery.of(context).size;
    var receipientsNotifier = ref.read(messageReceipeintProvider(ref).notifier);
    var newMessageNotifier = ref.read(newMessageProvider.notifier);
    var filter = ref.watch(messageReceipeintFilterProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            elevation: 5,
            child: Container(
                width: size.width > 900 ? 900 : 800,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                padding: const EdgeInsets.all(15),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // suggestion box
                          const SizedBox(
                            height: 10,
                          ),
                          CustomTextFields(
                            label: 'Message Sender (11 characters only)',
                            onSaved: (sender) {
                              newMessageNotifier.setSender(sender);
                            },
                            max: 11,
                            onChanged: (value) {
                              //notify user if the sender is more than 11 characters
                              if (value.length > 11) {
                                CustomDialog.showToast(
                                    message:
                                        'Sender must be 11 characters only');
                              }
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter student sender';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          CustomTextFields(
                            label: 'Message to send',
                            maxLines: 5,
                            onSaved: (student) {
                              newMessageNotifier.setMessage(student);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter student';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 30,
                          ),
                          Text('Select Recipients',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomDropDown(
                                    label: 'Filter Recipients',
                                    // value: filter,
                                    items: [
                                      'All',
                                      'By Gender',
                                      'By Level',
                                      'By Block',
                                      'By Room',
                                      'By Name'
                                    ]
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (value) {
                                      ref
                                          .read(selectedFilterProvider.notifier)
                                          .state = null;
                                      if (value.toString() == 'All') {
                                        newMessageNotifier.setRecipients(
                                            ref.watch(
                                                messageReceipeintProvider(ref)),
                                            ref);
                                      }
                                      ref
                                          .read(messageReceipeintFilterProvider
                                              .notifier)
                                          .state = value.toString();
                                    }),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              if (filter != null &&
                                  filter.toLowerCase() != 'all')
                                const Expanded(child: SizedBox()),
                              if (filter != null &&
                                  filter.toLowerCase() == 'by gender')
                                Expanded(
                                  child: CustomDropDown(
                                    label: 'Select Gender',
                                    //value: ref.watch(selectedFilterProvider),
                                    onChanged: (gender) {
                                      receipientsNotifier
                                          .filterByGender(gender.toString());
                                    },
                                    items: ['Male', 'Female']
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                  ),
                                ),
                              if (filter != null &&
                                  filter.toLowerCase() == 'by level')
                                Expanded(
                                  child: CustomDropDown(
                                    label: 'Select Level',
                                    //value: ref.watch(selectedFilterProvider),
                                    onChanged: (level) {
                                      receipientsNotifier
                                          .filterByLevel(level.toString());
                                    },
                                    items: [
                                      '100',
                                      '200',
                                      '300',
                                      '400',
                                      'Graduate'
                                    ]
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                  ),
                                ),
                              if (filter != null &&
                                  filter.toLowerCase() == 'by block')
                                Expanded(
                                  child: CustomDropDown(
                                    label: 'Select Block',
                                    //value: ref.watch(selectedFilterProvider),
                                    onChanged: (block) {
                                      receipientsNotifier
                                          .filterByBlock(block.toString());
                                    },
                                    items: [
                                      'Block A',
                                      'Block B',
                                      'Block C',
                                      'Block D',
                                      'Annex'
                                    ]
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                  ),
                                ),
                              if (filter != null &&
                                  filter.toLowerCase() == 'by name')
                                Expanded(
                                  child: Autocomplete<StudentModel>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<
                                            StudentModel>.empty();
                                      }

                                      return ref
                                          .watch(messageReceipeintProvider(ref))
                                          .where((StudentModel option) {
                                        return option.firstname!
                                                .toLowerCase()
                                                .contains(textEditingValue.text
                                                    .toLowerCase()) ||
                                            option.surname!
                                                .toLowerCase()
                                                .contains(textEditingValue.text
                                                    .toLowerCase()) ||
                                            option.room!.toLowerCase().contains(
                                                textEditingValue.text
                                                    .toLowerCase()) ||
                                            option.phone!
                                                .toLowerCase()
                                                .contains(textEditingValue.text
                                                    .toLowerCase());
                                      });
                                    },
                                    fieldViewBuilder: (BuildContext context,
                                        TextEditingController
                                            textEditingController,
                                        FocusNode focusNode,
                                        VoidCallback onFieldSubmitted) {
                                      return CustomTextFields(
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        label: 'Search Student',
                                        onSaved: (student) {},
                                        onSubmitted: (value) {
                                          onFieldSubmitted();
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter student name';
                                          }
                                          return null;
                                        },
                                      );
                                    },
                                    optionsViewBuilder: (BuildContext context,
                                        AutocompleteOnSelected<StudentModel>
                                            onSelected,
                                        Iterable<StudentModel> options) {
                                      return Align(
                                        alignment: Alignment.topLeft,
                                        child: Material(
                                          elevation: 4.0,
                                          child: SizedBox(
                                            height: 500.0,
                                            width: 400,
                                            child: ListView.separated(
                                                separatorBuilder:
                                                    (context, index) =>
                                                        const Divider(
                                                          color: Colors.grey,
                                                        ),
                                                itemCount: options.length,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                itemBuilder: (context, index) {
                                                  var option =
                                                      options.elementAt(index);
                                                  return GestureDetector(
                                                    onTap: () {
                                                      onSelected(option);
                                                    },
                                                    child: ListTile(
                                                      leading: CircleAvatar(
                                                        radius: 20,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        backgroundImage: option
                                                                        .image !=
                                                                    null &&
                                                                option.image!
                                                                    .isNotEmpty
                                                            ? MemoryImage(
                                                                base64Decode(
                                                                    option
                                                                        .image!))
                                                            : null,
                                                      ),
                                                      title: Text(
                                                          '${option.firstname!} ${option.surname!}',
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      subtitle: Text(
                                                          'Room: ${option.room!}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      14)),
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ),
                                      );
                                    },
                                    optionsMaxHeight: 200,
                                    displayStringForOption: (StudentModel
                                            option) =>
                                        '${option.firstname!} ${option.surname!}',
                                    onSelected: (StudentModel value) {
                                      receipientsNotifier
                                          .filterByStudent(value);
                                    },
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          //show item count with view button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Total Recipients: ${ref.watch(newMessageProvider).recipients != null ? ref.watch(newMessageProvider).recipients!.length : 0}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    var receipients = ref
                                        .watch(newMessageProvider)
                                        .recipients;
                                    if (receipients != null &&
                                        receipients.isNotEmpty) {
                                      List<StudentModel> data = [];
                                      for (var item in receipients) {
                                        data.add(StudentModel.fromMap(item));
                                      }
                                      setState(() {
                                        index = 1;
                                      });
                                    } else {
                                      CustomDialog.showError(
                                          message: 'No recipients selected');
                                    }
                                  },
                                  child: const Text('View Recipients'))
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          CustomButton(
                              icon: Icons.send,
                              text: 'Send Message',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  CustomDialog.showInfo(
                                      message:
                                          'Are you sure you want to send this message? This action is not reversable',
                                      buttonText: 'Send',
                                      onPressed: () {
                                        ref
                                            .read(newMessageProvider.notifier)
                                            .send(ref, context, _formKey);
                                      });
                                }
                              })
                        ]))),
          ),
        ],
      ),
    );
  }

  Widget _viewSelectedReceipient() {
    var receipients = ref.watch(selectedReceipientProvider);
    var tableTextStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontFamily: 'openSans', fontSize: 14, fontWeight: FontWeight.w500);
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Card(
        elevation: 5,
        child: SizedBox(
          width: size.width - 100,
          height: size.height,
          child: Column(
            children: [
              Expanded(
                child: CustomTable<StudentModel>(
                    header: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: Row(children: [
                        //close buttonh
                        IconButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                            onPressed: () {
                              setState(() {
                                index = 0;
                              });
                            },
                            icon: const Icon(Icons.close)),
                        const Spacer(),
                        SizedBox(
                          width: size.width > 1000 ? 500 : 400,
                          child: CustomTextFields(
                            label: 'Search Recipients',
                            onChanged: (value) {
                              ref
                                  .read(newMessageProvider.notifier)
                                  .search(value, ref);
                            },
                          ),
                        ),
                      ]),
                    ),
                    data: receipients,
                    rows: [
                      for (int i = 0; i < receipients.length; i++)
                        CustomTableRow(
                          item: receipients[i],
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
                        cellBuilder: (student) => Text(
                          student.id ?? '',
                          style: tableTextStyle,
                        ),
                      ),
                      CustomTableColumn(
                        title: 'Name',
                        cellBuilder: (student) => Text(
                          '${student.firstname} ${student.surname}',
                          style: tableTextStyle,
                        ),
                      ),
                      CustomTableColumn(
                        width: 150,
                        title: 'Gender',
                        cellBuilder: (student) => Text(
                          student.gender ?? '',
                          style: tableTextStyle,
                        ),
                      ),
                      CustomTableColumn(
                        title: 'Phone Number',
                        cellBuilder: (student) => Text(
                          student.phone ?? '',
                          style: tableTextStyle,
                        ),
                      ),
                      CustomTableColumn(
                        title: 'Level',
                        width: 150,
                        cellBuilder: (student) => Text(
                          student.level ?? '',
                          style: tableTextStyle,
                        ),
                      ),
                      CustomTableColumn(
                        title: 'Block',
                        width: 150,
                        cellBuilder: (student) => Text(
                          student.block ?? '',
                          style: tableTextStyle,
                        ),
                      ),
                      CustomTableColumn(
                        title: 'Room',
                        cellBuilder: (student) => Text(
                          student.room ?? '',
                          style: tableTextStyle,
                        ),
                      ),
                      CustomTableColumn(
                        title: 'Action',
                        cellBuilder: (student) => IconButton(
                            onPressed: () {
                              ref
                                  .read(newMessageProvider.notifier)
                                  .deleteRecipient(student, ref);
                            },
                            icon: const Icon(Icons.delete)),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
