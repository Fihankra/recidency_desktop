import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/features/complaints/provider/complaints_provider.dart';
import 'package:residency_desktop/features/container/provider/main_provider.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';

import '../../../core/widgets/custom_dialog.dart';

class NewComplain extends ConsumerStatefulWidget {
  const NewComplain({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewComplainState();
}

class _NewComplainState extends ConsumerState<NewComplain> {
  bool isMyRoom = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        PageHeaders(
          title: 'New Students Complaints',
          subTitle: 'Please fill the form below to add a new complaint',
          hasBackButton: true,
          onBackButtonPressed: () {
            context.go(RouterInfo.complaintsRoute.path);
          },
          hasExtraButton: false,
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDesktop(),
            ],
          ),
        ))
      ]),
    );
  }

  Widget _buildDesktop() {
    var size = MediaQuery.of(context).size;
    
    var newComplaintsNotifier = ref.read(newComplaintsProvider.notifier);
    return Card(
      elevation: 5,
      child: Container(
          width: size.width > 900 ? 900 : 800,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(15),
          child:  Form(
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
                        Autocomplete<StudentModel>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<StudentModel>.empty();
                            }

                            return ref.watch(studentDataProvider).where((StudentModel option) {
                              return option.firstname!.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase()) ||
                                  option.surname!.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase()) ||
                                  option.room!.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase()) ||
                                  option.phone!.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase());
                            });
                          },
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
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
                              AutocompleteOnSelected<StudentModel> onSelected,
                              Iterable<StudentModel> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: SizedBox(
                                  height: 500.0,
                                  width: 400,
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                            color: Colors.grey,
                                          ),
                                      itemCount: options.length,
                                      padding: const EdgeInsets.all(8.0),
                                      itemBuilder: (context, index) {
                                        var option = options.elementAt(index);
                                        return GestureDetector(
                                          onTap: () {
                                            onSelected(option);
                                          },
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.grey,
                                              backgroundImage: option.image !=
                                                          null &&
                                                      option.image!.isNotEmpty
                                                  ? MemoryImage(base64Decode(
                                                      option.image!))
                                                  : null,
                                            ),
                                            title: Text(
                                                '${option.firstname!} ${option.surname!}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            subtitle: Text(
                                                'Room: ${option.room!}',
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            );
                          },
                          optionsMaxHeight: 200,
                          displayStringForOption: (StudentModel option) =>
                              '${option.firstname!} ${option.surname!}',
                          onSelected: (StudentModel value) {
                            newComplaintsNotifier.setStudent(value);
                          },
                        ),

                        const SizedBox(
                          height: 24,
                        ),
                        CustomTextFields(
                          label: 'Complaint Title',
                          onSaved: (title) {
                            newComplaintsNotifier.setTitle(title);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter complaint title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomTextFields(
                          label: 'Complaint Description',
                          maxLines: 5,
                          onSaved: (desc) {
                            newComplaintsNotifier.setDescription(desc);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter complaint description';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomDropDown(
                                items: [
                                  'Electrical',
                                  'Plumbing',
                                  'Carpentry',
                                  'Masonry',
                                  'Others'
                                ]
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                label: 'Complaint Type',
                                onChanged: (value) {},
                                onSaved: (value) {
                                  newComplaintsNotifier
                                      .setType(value.toString());
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select complaint type';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: CustomDropDown(
                                items: ['Emergency', 'Normal']
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                label: 'Complaint Severity',
                                onChanged: (value) {},
                                onSaved: (value) {
                                  newComplaintsNotifier
                                      .setSeverity(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),

                        //checkbox to select if complaint is in my room
                        Row(
                          children: [
                            Checkbox(
                              value: isMyRoom,
                              onChanged: (value) {
                                setState(() {
                                  isMyRoom = value!;
                                  if (value) {
                                    newComplaintsNotifier
                                        .setLocation('My Room');
                                  }
                                });
                              },
                            ),
                            const Text('Complaint is in my room'),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (!isMyRoom)
                          CustomTextFields(
                            label: 'Complaint Location',
                            onSaved: (value) {
                              newComplaintsNotifier.setLocation(value);
                            },
                            validator: (value) {
                              if (!isMyRoom && value!.isEmpty) {
                                return 'Please enter complaint location';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomButton(
                            icon: Icons.save,
                            text: 'Submit',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (ref
                                        .watch(newComplaintsProvider)
                                        .studentId ==
                                    null) {
                                  CustomDialog.showError(
                                      message: 'Please select a student');
                                  return;
                                }
                                _formKey.currentState!.save();
                                newComplaintsNotifier.submitComplaint(
                                    ref: ref, form: _formKey, context: context);
                              }
                            })
                      ]))
            
          ));
    
  }
}
