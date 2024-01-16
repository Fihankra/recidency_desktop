import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/features/staffs/data/staff_model.dart';

class ViewStaff extends StatefulWidget {
  const ViewStaff({super.key, required this.staff});
  final StaffModel staff;

  @override
  State<ViewStaff> createState() => _ViewStaffState();
}

class _ViewStaffState extends State<ViewStaff> {
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _assistantIdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _firstNameController.text = widget.staff.firstname!;
    _surnameController.text = widget.staff.surname!;
    _emailController.text = widget.staff.email!;
    _phoneNumberController.text = widget.staff.phone!;
    _assistantIdController.text = widget.staff.id!;
    return _buildDesktop();
  }

  Widget _buildDesktop() {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
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
                      children: [
                        Expanded(
                          child: CustomTextFields(
                            color: Colors.transparent,
                            label: 'Staff ID',
                            hintText: 'Enter Staff ID',
                            prefixIcon: MdiIcons.idCard,
                            isReadOnly: true,
                            controller: _assistantIdController,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 180,
                          child: CustomDropDown(
                            prefixIcon: FontAwesomeIcons.genderless,
                            value: widget.staff.gender,
                            label: 'Gender',
                            color: Colors.transparent,
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
                      color: Colors.transparent,
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
                      color: Colors.transparent,
                      label: 'Surname',
                      hintText: 'Enter Surname',
                      controller: _surnameController,
                      prefixIcon: Icons.person,
                      isReadOnly: true,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    CustomDropDown(
                      prefixIcon: FontAwesomeIcons.usersGear,
                      value: widget.staff.role,
                      color: Colors.transparent,
                      label: 'Role',
                      items: const [
                        //male and female
                        DropdownMenuItem(
                          value: 'Hall Admin',
                          child: Text('Hall Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'Hall Assistant',
                          child: Text('Hall Assistant'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    CustomTextFields(
                      color: Colors.transparent,
                      label: 'Email',
                      hintText: 'Enter Email',
                      controller: _emailController,
                      prefixIcon: Icons.email,
                      isReadOnly: true,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    CustomTextFields(
                      color: Colors.transparent,
                      label: 'Phone Number',
                      hintText: 'Enter Phone Number',
                      controller: _phoneNumberController,
                      isDigitOnly: true,
                      prefixIcon: Icons.phone,
                      isReadOnly: true,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                )),
                const SizedBox(
                  width: 15,
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all()),
                  padding:
                      const EdgeInsets.symmetric(vertical: 45, horizontal: 35),
                  child: Column(
                    children: [
                      Text(
                        'Staff Picture',
                        style: getTextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                          height: 220,
                          width: 200,
                          decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(5)),
                          child: widget.staff.image == null
                              ? const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 100,
                                  ),
                                )
                              : Image.memory(
                                  base64Decode(widget.staff.image!),
                                  fit: BoxFit.cover,
                                )),
                    ],
                  ),
                ),
              ],
            ),

            //close button
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
