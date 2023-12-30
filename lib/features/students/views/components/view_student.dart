import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/departments.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import '../../../../../../core/widgets/custom_input.dart';

class ViewStudent extends ConsumerStatefulWidget {
  const ViewStudent({super.key, required this.student});
  final StudentModel student;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewStudentState();
}

class _ViewStudentState extends ConsumerState<ViewStudent> {
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final idController = TextEditingController();
  final roomController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _firstNameController.text = widget.student.firstname!;
    _surnameController.text = widget.student.surname!;
    _phoneNumberController.text = widget.student.phone!;
    idController.text = widget.student.id!;
    roomController.text = widget.student.room!;
    return _buildDesktop();
  }

  Widget _buildDesktop() {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextFields(
                            label: 'Student ID',
                            hintText: 'Enter student ID',
                            prefixIcon: MdiIcons.idCard,
                            controller: idController,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 180,
                          child: CustomDropDown(
                            prefixIcon: FontAwesomeIcons.genderless,
                            label: 'Gender',
                            value: widget.student.gender,
                            items: const [
                              //male and female
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    CustomTextFields(
                      label: 'First Name',
                      hintText: 'Enter First Name',
                      prefixIcon: Icons.person,
                      controller: _firstNameController,
                      isReadOnly: true,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    CustomTextFields(
                      label: 'Surname',
                      hintText: 'Enter Surname',
                      prefixIcon: Icons.person,
                      isReadOnly: true,
                      controller: _surnameController,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    CustomDropDown(
                      value: widget.student.department,
                      items: departments
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      label: 'Student Department',
                      hintText: 'Select student department',
                      prefixIcon: Icons.school,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextFields(
                            color: Colors.transparent,
                            label: 'Phone Number',
                            controller: _phoneNumberController,
                            hintText: 'Enter Phone Number',
                            prefixIcon: Icons.phone,
                            isDigitOnly: true,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: CustomDropDown(
                            color: Colors.transparent,
                            items: ['100', '200', '300', '400', 'Graduate']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            label: 'Student Level',
                            value: widget.student.level,
                            prefixIcon: FontAwesomeIcons.arrowTurnUp,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropDown(
                            color: Colors.transparent,
                            label: 'Student Block',
                            hintText: 'Select student block',
                            value: widget.student.block,
                            prefixIcon: Icons.home,
                            items: [
                              'Block A',
                              'Block B',
                              'Block C',
                              'Block D',
                              'Annex'
                            ]
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        //room
                        Expanded(
                          child: CustomTextFields(
                            color: Colors.transparent,
                            isReadOnly: true,
                            controller: roomController,
                            label: 'Room Number (Enter only digits)',
                            hintText: 'Enter room number',
                            prefixIcon: Icons.room,
                            isDigitOnly: true,
                            max: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
                const SizedBox(
                  width: 15,
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 35),
                  child: Column(
                    children: [
                      Text(
                        'Student Picture'.toUpperCase(),
                        style: getTextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 220,
                        width: 200,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(5)),
                        child: widget.student.image != null &&
                                widget.student.image!.isNotEmpty
                            ? Image.file(
                                File(widget.student.image!),
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 100,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                      text: 'Close',
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      icon: Icons.close,
                      onPressed: () {
                        CustomDialog.dismiss();
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
