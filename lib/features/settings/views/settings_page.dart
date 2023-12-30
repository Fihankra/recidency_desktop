import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/provider/theme_provider.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/features/settings/data/settings_model.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _hallNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var settings = ref.watch(settingsFutureProvider);
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(children: [
        const PageHeaders(
          title: 'General Settings',
          subTitle:
              'Settings will be applied to all users of the system with this Hall',
          hasBackButton: false,
        ),
        const SizedBox(
          height: 25,
        ),
        Expanded(
          child: settings.when(
              data: (data) {
                var settings = ref.watch(settingsProvider);
                if (settings.id != null) {
                  _hallNameController.text = settings.hallName!;
                }
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _desktopView(settings),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
              error: (error, stackTrace) => const Center(
                    child: Text('Something went wrong'),
                  )),
        )
      ]),
    );
  }

  Widget _desktopView(SettingsModel data) {
    var size = MediaQuery.of(context).size;
    var theme = ref.watch(themeProvider);
    return LayoutBuilder(builder: (context, constraints) {
      return Card(
        elevation: 3,
        child: SizedBox(
          width: 1000,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 15,
                  runAlignment: WrapAlignment.center,
                  spacing: 15,
                  children: [
                    Container(
                      width: 600,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme == darkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 35),
                      child: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hall Details'.toUpperCase(),
                                style: getTextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              CustomTextFields(
                                label: 'Hall Name',
                                hintText: 'Enter Hall Name',
                                prefixIcon: MdiIcons.homeCity,
                                controller: _hallNameController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Hall Name is required';
                                  }
                                  return null;
                                },
                                onSaved: (name) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .setHallName(name!);
                                },
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              CustomDropDown(
                                prefixIcon: MdiIcons.genderMaleFemale,
                                label: 'Target Gender',
                                value: data.targetGender,
                                onChanged: (gender) {},
                                validator: (gender) {
                                  if (gender == null ||
                                      gender.toString().isEmpty) {
                                    return 'Target gender is required';
                                  }
                                  return null;
                                },
                                onSaved: (gender) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .setTargetGender(gender.toString());
                                },
                                items: ['Male', 'Female', 'Mixed']
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              CustomDropDown(
                                prefixIcon: MdiIcons.calendar,
                                label: 'Academic Year',
                                onChanged: (year) {},
                                value: data.academicYear,
                                validator: (year) {
                                  if (year == null || year.toString().isEmpty) {
                                    return 'Academic year is required';
                                  }
                                  return null;
                                },
                                onSaved: (year) {
                                  ref
                                      .read(settingsProvider.notifier)
                                      .setAcademicYear(year.toString());
                                },
                                items: [
                                  '2021/2022',
                                  '2022/2023',
                                  '2023/2024',
                                  '2024/2025',
                                  '2025/2026',
                                  '2026/2027',
                                  '2027/2028',
                                  '2028/2029',
                                  '2029/2030'
                                ]
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                              ),
                            ]),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: Column(children: [
                        Text('Hall Logo'.toUpperCase(),
                            style: getTextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: theme == darkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              image: data.hallLogo != null
                                  ? DecorationImage(
                                      image: FileImage(File(data.hallLogo!)),
                                      fit: BoxFit.cover)
                                  : null),
                          child: data.hallLogo != null
                              ? null
                              : const Center(
                                  child: Text('Upload Logo'),
                                ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //upload button
                        TextButton.icon(
                            onPressed: () {
                              ref.read(settingsProvider.notifier).pickImage();
                            },
                            icon: Icon(MdiIcons.upload),
                            label: const Text('Upload Logo'))
                      ]),
                    )
                  ],
                ),
                const SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: constraints.maxWidth >= 1200
                      ? size.width * 0.3
                      : constraints.maxWidth > 700 &&
                              constraints.maxWidth < 1200
                          ? size.width * 0.45
                          : size.width * .8,
                  child: CustomButton(
                      text: 'Save Settings',
                      icon: MdiIcons.contentSave,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          ref.read(settingsProvider.notifier).saveSettings(
                              context: context, ref: ref,);
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
