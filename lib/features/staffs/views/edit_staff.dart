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
import 'package:residency_desktop/core/constants/email_regex.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/features/staffs/data/staff_model.dart';
import 'package:residency_desktop/features/staffs/provider/staff_provider.dart';
import '../../../core/widgets/custom_dialog.dart';

class EditStaffPage extends ConsumerStatefulWidget {
  const EditStaffPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditStaffPageState();
}

class _EditStaffPageState extends ConsumerState<EditStaffPage> {
  final _formKey = GlobalKey<FormState>();
  // controllers
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _assistantIdController = TextEditingController();
  String? gender;

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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var assistant = ref.watch(selectedAssistantProvider);

    if (assistant.id != null) {
      _firstNameController.text = assistant.firstname!;
      _surnameController.text = assistant.surname!;
      _emailController.text = assistant.email!;
      _phoneNumberController.text = assistant.phone!;
      _assistantIdController.text = assistant.id!;
    }

    return Container(
      width: double.infinity,
      height: size.height,
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        PageHeaders(
          title: 'Edit Hall Staff',
          subTitle: 'Please make changes to the hall staff details',
          hasBackButton: true,
          onBackButtonPressed: () {
            context.go(RouterInfo.assistantsRoute.path);
          },
          hasExtraButton: false,
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildForm(assistant),
            ],
          ),
        ))
      ]),
    );
  }

  Widget _buildForm(StaffModel staff) {
    var staffNotifier = ref.read(selectedAssistantProvider.notifier);
    var size = MediaQuery.of(context).size;
    return Card(
      elevation: 5,
      child: Container(
          width: size.width > 900 ? 900 : 800,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                                  label: 'Staff ID',
                                  hintText: 'Enter Staff ID',
                                  prefixIcon: MdiIcons.idCard,
                                  isReadOnly: true,
                                  controller: _assistantIdController,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter stuff ID';
                                    } else if (value.length < 5) {
                                      return 'Enter a valid stuff ID';
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
                                  value: staff.gender,
                                  onSaved: (value) {
                                    staffNotifier.setGender(value!);
                                  },
                                  label: 'Gender',
                                  onChanged: (value) {},
                                  validator: (gender) {
                                    if (gender == null) {
                                      return 'Select Staff gender';
                                    }
                                    return null;
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
                            prefixIcon: Icons.person,
                            controller: _firstNameController,
                            onSaved: (value) {
                              staffNotifier.setFirstName(value!);
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
                            onSaved: (value) {
                              staffNotifier.setSurname(value!);
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
                            prefixIcon: FontAwesomeIcons.usersGear,
                            value: staff.role,
                            validator: (role) {
                              if (role == null || role.toString().isEmpty) {
                                return 'Select stuff role';
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              staffNotifier.setRole(value!);
                            },
                            label: 'Role',
                            onChanged: (value) {},
                            items: const [
                              //male and female
                              DropdownMenuItem(
                                value: Role.hallAdmin,
                                child: Text('Hall Admin'),
                              ),
                              DropdownMenuItem(
                                value: Role.hallAssistant,
                                child: Text('Hall Assistant'),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          CustomTextFields(
                            label: 'Email',
                            hintText: 'Enter Email',
                            controller: _emailController,
                            onSaved: (email) {
                              staffNotifier.setEmail(email!);
                            },
                            prefixIcon: Icons.email,
                            validator: (value) {
                              if (value!.isNotEmpty &&
                                  !emailRegEx.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          CustomTextFields(
                            label: 'Phone Number',
                            hintText: 'Enter Phone Number',
                            
                            max: 10,
                            onSaved: (value) {
                              staffNotifier.setPhone(value!);
                            },
                            controller: _phoneNumberController,
                            isDigitOnly: true,
                            prefixIcon: Icons.phone,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter phone number';
                              } else if (value.length != 10) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 34,
                          ),
                          CustomButton(
                            text: 'Update Staff',
                            icon: MdiIcons.update,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                staffNotifier.updateStaff(
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
                      _buildCamera(staff)
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildCamera(StaffModel assistant) {
    return Container(
        width: 300,
        decoration: BoxDecoration(border: Border.all()),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Saff Picture',
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
              child: ref.watch(staffImageProvider).image != null
                  ? Image.file(
                      File(ref.watch(staffImageProvider).image!.path),
                      fit: BoxFit.cover,
                    )
                  : controller != null &&
                          controller!.value.isInitialized &&
                          isCameraOn
                      ? CameraPreview(controller!)
                      : assistant.image != null && assistant.image!.isNotEmpty
                          ? Image.memory(
                              base64Decode(assistant.image!),
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
            if (ref.watch(staffImageProvider).image != null)
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
            else if (ref.watch(staffImageProvider).image == null && !isCameraOn)
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
    ref.invalidate(staffImageProvider);
    setState(() {
      controller = null;

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
      ref
          .read(staffImageProvider.notifier)
          .setImage(image: image,isCaptured: false);
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
        .read(staffImageProvider.notifier)
        .setImage(image: path, isCaptured: true);
  }
}
