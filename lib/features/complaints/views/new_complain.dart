import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/widgets/components/page_headers.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/features/students/provider/student_provider.dart';

class NewComplain extends ConsumerStatefulWidget {
  const NewComplain({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewComplainState();
}

class _NewComplainState extends ConsumerState<NewComplain> {
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
    var studentsFuture = ref.watch(studentFutureProvider);
    return Card(
      elevation: 5,
      child: Container(
          width: size.width > 900 ? 900 : 800,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: const EdgeInsets.all(15),
          child: studentsFuture.when(
            data: (data) {
              print(data.length);
              return Form(
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
                        TypeAheadField<StudentModel>(
                          suggestionsCallback: (search) =>
                              data.where((student) {
                            final firstNameLower =
                                student.firstname!.toLowerCase();
                            final surnameLower = student.surname!.toLowerCase();
                            final idLower = student.id!.toLowerCase();
                            final searchLower = search.toLowerCase();
                            return firstNameLower.contains(searchLower) ||
                                surnameLower.contains(searchLower) ||
                                idLower.contains(searchLower);
                          }).toList(),
                          builder: (context, controller, focusNode) {
                            return CustomTextFields(
                              controller: controller,
                              label: 'Student Name',
                            );
                          },
                          itemBuilder: (context, student) {
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    FileImage(File(student.image!)),
                              ),
                              title: Text(
                                  '${student.firstname} ${student.surname}'),
                              subtitle: Text(student.id!),
                            );
                          },
                          onSelected: (city) {},
                        )
                      ]));
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, s) => Center(
              child: Text(e.toString()),
            ),
          )),
    );
  }
}
