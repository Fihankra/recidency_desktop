import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/departments.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/core/widgets/responsive_ui.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/features/students/provider/student_provider.dart';

import '../../../../core/widgets/custom_dialog.dart';

class EditStudent extends ConsumerStatefulWidget {
  const EditStudent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditStudentState();
}

class _EditStudentState extends ConsumerState<EditStudent> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final idController = TextEditingController();
  final roomController = TextEditingController();

  List<CameraDescription> cameras = [];
  CameraDescription? selectedCamera;
  CameraController? controller;
  bool isCameraOn = false;

  @override
  void initState() {
    initCamera();
    super.initState();
  }

  @override
  void dispose() {
    // disposeCurrentCamera();
    controller?.dispose();
    super.dispose();
  }

  initCamera() async {
    try {
      if (controller != null) {
        await controller!.dispose();
      }
      cameras = await availableCameras();
      selectedCamera = cameras.isNotEmpty ? cameras[0] : null;
      setState(() {});
    } catch (e) {
      CustomDialog.showError(message: 'Camera Error');
    }
  }

  void changeCamera(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    setState(() {
      controller =
          CameraController(cameraDescription, ResolutionPreset.ultraHigh);
      selectedCamera = cameraDescription;
      isCameraOn = false;
    });
  }

  void disposeCurrentCamera() async {
    await controller?.dispose();
    controller = null;
    isCameraOn = false;
    setState(() {});
  }

  void startCamera() async {
    try {
      await controller?.dispose();
      controller = CameraController(
        selectedCamera!,
        ResolutionPreset.max,
        enableAudio: false,
      );
      await controller!.initialize();
      isCameraOn = true;
      setState(() {});
    } catch (e) {
      CustomDialog.showError(
          message: 'Camera error, Remove camera and try again');
    }
  }

  void retakePicture() async {
    if (controller != null) {
      await controller!.dispose();
    }
    setState(() {
      controller = null;
      ref.invalidate(studentImageProvider);
      isCameraOn = false;
    });
  }

  void pickImage() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 240,
        maxHeight: 240,
        preferredCameraDevice: CameraDevice.rear);
    if (image != null) {
      setState(() {
        isCameraOn = false;
      });
      ref
          .read(studentImageProvider.notifier)
          .setImage(image: image, isCaptured: false);
    }
  }

  snapPicture() async {
    if (!isCameraOn) {
      return;
    }
    final path = await controller!.takePicture();
    setState(() {
      isCameraOn = false;
    });
    if (controller != null) {
      await controller!.dispose();
    }
    setState(() {
      controller = null;
    });
    ref
        .read(studentImageProvider.notifier)
        .setImage(image: path, isCaptured: true);
  }

  @override
  Widget build(BuildContext context) {
    var student = ref.watch(selectedStudentProvider);
    if (student.id != null) {
      _firstNameController.text = student.firstname!;
      _surnameController.text = student.surname!;
      _phoneNumberController.text = student.phone!;
      idController.text = student.id!;
      roomController.text = student.room!.replaceAll(RegExp(r'[^0-9]'), '');
    }
    var size = MediaQuery.of(context).size;
    return Container(
        width: double.infinity,
        height: size.height,
        padding: const EdgeInsets.all(15),
        child: Column(children: [
          PageHeaders(
            title: 'Edit Student',
            subTitle: 'Please fill the form below to update student',
            hasBackButton: true,
            onBackButtonPressed: () {
              context.go(RouterInfo.studentsRoute.path);
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
                _buildDesktop(student),
              ],
            ),
          ))
        ]));
  }

  Widget _buildDesktop(StudentModel student) {
    var size = MediaQuery.of(context).size;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 5,
      child: Container(
          width: ResponsiveScreen.isDesktop(context)
              ? size.width * 0.6
              : size.width * .8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
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
                                isReadOnly: true,
                                controller: idController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter student ID';
                                  } else if (value.length < 5) {
                                    return 'Enter a valid student ID';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: 180,
                              child: CustomDropDown(
                                prefixIcon: FontAwesomeIcons.genderless,
                                value: student.gender,
                                onSaved: (value) {
                                  ref
                                      .read(selectedStudentProvider.notifier)
                                      .setGender(value!);
                                },
                                label: 'Gender',
                                onChanged: (value) {},
                                validator: (gender) {
                                  if (gender == null ||
                                      gender.toString().isEmpty) {
                                    return 'Select student gender';
                                  } else {
                                    return null;
                                  }
                                },
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
                          controller: _firstNameController,
                          prefixIcon: Icons.person,
                          onSaved: (name) {
                            ref
                                .read(selectedStudentProvider.notifier)
                                .setFirstName(name!);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter first name';
                            } else if (value.length < 3) {
                              return 'Enter a valid first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomTextFields(
                          label: 'Surname',
                          hintText: 'Enter Surname',
                          controller: _surnameController,
                          prefixIcon: Icons.person,
                          onSaved: (name) {
                            ref
                                .read(selectedStudentProvider.notifier)
                                .setSurname(name!);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter surname';
                            } else if (value.length < 3) {
                              return 'Enter a valid surname';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomDropDown(
                          items: departments
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          label: 'Student Department',
                          hintText: 'Select student department',
                          value: student.department,
                          onChanged: (value) {},
                          onSaved: (department) {
                            ref
                                .read(selectedStudentProvider.notifier)
                                .setDepartment(department!);
                          },
                          prefixIcon: Icons.school,
                          validator: (value) {
                            if (value == null) {
                              return 'Please select student department';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextFields(
                                label: 'Phone Number',
                                hintText: 'Enter Phone Number',
                                controller: _phoneNumberController,
                                isDigitOnly: true,
                                max: 10,
                                prefixIcon: Icons.phone,
                                onSaved: (phone) {
                                  ref
                                      .read(selectedStudentProvider.notifier)
                                      .setPhone(phone!);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter phone number';
                                  } else if (value.length < 10) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: CustomDropDown(
                                items: ['100', '200', '300', '400', 'Graduate']
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                label: 'Student Level',
                                hintText: 'Select student level',
                                value: student.level,
                                onChanged: (value) {},
                                onSaved: (level) {
                                  ref
                                      .read(selectedStudentProvider.notifier)
                                      .setLevel(level!);
                                },
                                prefixIcon: FontAwesomeIcons.arrowTurnUp,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select student level';
                                  }
                                  return null;
                                },
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
                                label: 'Student Block',
                                hintText: 'Select student block',
                                value: student.block,
                                prefixIcon: Icons.home,
                                onChanged: (value) {},
                                onSaved: (block) {
                                  ref
                                      .read(selectedStudentProvider.notifier)
                                      .setBlock(block!);
                                },
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
                                validator: (block) {
                                  if (block == null) {
                                    return 'Please select student block';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            //room
                            Expanded(
                              child: CustomTextFields(
                                label: 'Room Number (Enter only digits)',
                                hintText: 'Enter room number',
                                controller: roomController,
                                prefixIcon: Icons.room,
                                isDigitOnly: true,
                                max: 2,
                                onSaved: (room) {
                                  ref
                                      .read(selectedStudentProvider.notifier)
                                      .setRoom(room!);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter room number';
                                  } else if (value.length > 2) {
                                    return 'Enter a valid room number, only digits allowed';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 34,
                        ),
                        CustomButton(
                          text: 'Update Student',
                          icon: MdiIcons.creation,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              ref
                                  .read(selectedStudentProvider.notifier)
                                  .updateStudent(
                                    context: context,
                                    ref: ref,
                                  );
                            }
                          },
                        )
                      ],
                    )),
                    const SizedBox(
                      width: 15,
                    ),
                    _buildCamera(student),
                  ],
                )
              ],
            ),
          )),
    );
  }

  Widget _buildCamera(StudentModel student) {
    return Container(
        width: 300,
        decoration: BoxDecoration(border: Border.all()),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Student Picture',
              style: getTextStyle(fontSize: 14),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<CameraDescription>(
                  value: selectedCamera,
                  items: cameras
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name.split('<').first),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    changeCamera(value!);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                    onPressed: () async {
                      await initCamera();
                    },
                    icon: const Icon(Icons.refresh))
              ],
            ),
            Container(
              height: 220,
              width: 200,
              decoration: BoxDecoration(
                  border: Border.all(), borderRadius: BorderRadius.circular(5)),
              child: ref.watch(studentImageProvider).image != null
                  ? Image.file(
                      File(ref.watch(studentImageProvider).image!.path),
                      fit: BoxFit.cover,
                    )
                  : controller != null &&
                          controller!.value.isInitialized &&
                          isCameraOn
                      ? CameraPreview(controller!)
                      : student.image != null && student.image!.isNotEmpty
                          ? Image.memory(
                              base64Decode(student.image!),
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Icon(
                                Icons.person,
                                size: 100,
                              ),
                            ),
            ),
            const SizedBox(
              height: 15,
            ),
            if (ref.watch(studentImageProvider).image != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      icon: const Icon(
                        Icons.cancel,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        retakePicture();
                      },
                      label: const Text(
                        'Retake Picture',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            if (isCameraOn)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    icon: Icon(
                      MdiIcons.camera,
                      size: 16,
                    ),
                    onPressed: () async {
                      await snapPicture();
                    },
                    label: const Text('Take Picture', style: TextStyle()),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      icon: const Icon(
                        Icons.cancel,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        retakePicture();
                      },
                      label: const Text(
                        'Stop Camera',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              )
            else if (ref.watch(studentImageProvider).image == null &&
                !isCameraOn)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    icon: const Icon(
                      Icons.file_upload,
                      size: 16,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      pickImage();
                    },
                    label: const Text('From files',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        startCamera();
                      },
                      label: const Text(
                        'From camera',
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              )
          ],
        ));
  }
}
