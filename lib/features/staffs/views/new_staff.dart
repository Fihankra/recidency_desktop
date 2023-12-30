import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/email_regex.dart';
import 'package:residency_desktop/core/provider/image_provider.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/features/staffs/provider/staff_provider.dart';

class NewStaffPage extends ConsumerStatefulWidget {
  const NewStaffPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewAssistantPageState();
}

class _NewAssistantPageState extends ConsumerState<NewStaffPage> {
  final _formKey = GlobalKey<FormState>();
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
    return Container(
      width: double.infinity,
      height: size.height,
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        PageHeaders(
          title: 'New Hall Staff',
          subTitle: 'Please fill the form below to add a new hall staff',
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
              _buildDesktop(),
            ],
          ),
        ))
      ]),
    );
  }

  Widget _buildCamera() {
    return Container(
        width: 300,
        decoration: BoxDecoration(border: Border.all()),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Staff Picture',
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
              child: ref.watch(imageProvider).image != null
                  ? Image.file(
                      File(ref.watch(imageProvider).image!.path),
                      fit: BoxFit.cover,
                    )
                  : controller != null &&
                          controller!.value.isInitialized &&
                          isCameraOn
                      ? CameraPreview(controller!)
                      : const Center(
                          child: Icon(
                            Icons.person,
                            size: 100,
                          ),
                        ),
            ),
            Text(
              ref.watch(imageProvider).error ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(fontSize: 12, color: Colors.red),
            ),
            const SizedBox(
              height: 15,
            ),
            if (ref.watch(imageProvider).image != null)
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
            else if (ref.watch(imageProvider).image == null && !isCameraOn)
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

  Widget _buildDesktop() {
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
                                label: 'Staff ID',
                                hintText: 'Enter Staff ID',
                                prefixIcon: MdiIcons.idCard,
                                onSaved: (value) {
                                  ref
                                      .read(newStaffProvider.notifier)
                                      .setStaffId(value!);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter stuff ID';
                                  } else if (value.length < 3) {
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
                                validator: (gender) {
                                  if (gender == null ||
                                      gender.toString().isEmpty) {
                                    return 'Select stuff gender';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  ref
                                      .read(newStaffProvider.notifier)
                                      .setGender(value!);
                                },
                                label: 'Gender',
                                onChanged: (value) {},
                                color: Colors.white,
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
                          onSaved: (name) {
                            ref
                                .read(newStaffProvider.notifier)
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
                          prefixIcon: Icons.person,
                          onSaved: (name) {
                            ref
                                .read(newStaffProvider.notifier)
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
                          prefixIcon: FontAwesomeIcons.usersGear,
                          validator: (role) {
                            if (role == null || role.toString().isEmpty) {
                              return 'Select stuff role';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            ref.read(newStaffProvider.notifier).setRole(value!);
                          },
                          label: 'Role',
                          onChanged: (value) {},
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
                          label: 'Email',
                          hintText: 'Enter Email',
                          prefixIcon: Icons.email,
                          onSaved: (email) {
                            ref
                                .read(newStaffProvider.notifier)
                                .setEmail(email!);
                          },
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
                          prefixIcon: Icons.phone,
                          isDigitOnly: true,
                          onSaved: (phone) {
                            ref
                                .read(newStaffProvider.notifier)
                                .setPhone(phone!);
                          },
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
                          text: 'Create Stuff',
                          icon: MdiIcons.creation,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // if (ref.watch(imageProvider).image == null) {
                              //   ref.read(imageProvider.notifier).setError(
                              //       'Please select assistant picture');
                              //   return;
                              // }
                              //save form
                              _formKey.currentState!.save();
                              ref.read(newStaffProvider.notifier).createStaff(
                                  context: context, ref: ref, form: _formKey);
                            }
                          },
                        )
                      ],
                    )),
                    const SizedBox(
                      width: 15,
                    ),
                    _buildCamera()
                  ],
                )
              ],
            ),
          )),
    );
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
      ref.invalidate(imageProvider);
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
          .read(imageProvider.notifier)
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
    ref.read(imageProvider.notifier).setImage(image: path, isCaptured: true);
  }
}
