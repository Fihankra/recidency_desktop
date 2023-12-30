import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/provider/theme_provider.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/constants/security_questions.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import 'package:residency_desktop/core/widgets/custom_drop_down.dart';
import 'package:residency_desktop/core/widgets/custom_input.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/generated/assets.dart';

class NewPassword extends ConsumerStatefulWidget {
  const NewPassword({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewPasswordState();
}

class _NewPasswordState extends ConsumerState<NewPassword> {
  final _formKey = GlobalKey<FormState>();
  bool obSecureText = true;
  @override
  Widget build(BuildContext context) {
    var meNotifier = ref.read(myselfProvider.notifier);
    return Center(
      child: Card(
        elevation: 5,
        color: Theme.of(context).colorScheme.surface,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 600,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Image.asset(
                              ref.watch(themeProvider) == darkMode
                                  ? Assets.imagesLogoDark
                                  : Assets.imagesLogo,
                              height: 200),
                          const SizedBox(height: 20),

                          CustomTextFields(
                            label: 'New Password',
                            onSaved: (value) {
                              meNotifier.setPassword(value!);
                            },
                            prefixIcon: Icons.lock,
                            obscureText: obSecureText,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obSecureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  obSecureText = !obSecureText;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              }else if(value.length < 8){
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          CustomDropDown(
                            label: 'Security Question 1',
                            prefixIcon: Icons.question_answer,
                            onSaved: (question1) {
                              meNotifier.setSecurityQuestion1(question1!);
                            },
                            onChanged: (value) {},
                            items: securityQuestions
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                          const SizedBox(height: 30),
                          CustomTextFields(
                            label: 'Security Answer 1',
                            prefixIcon: Icons.question_answer,
                            onSaved: (value) {
                              meNotifier.setSecurityAnswer1(value!.toString());
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide an answer';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          CustomDropDown(
                            label: 'Security Question 2',
                            prefixIcon: Icons.question_answer,
                            onSaved: (question2) {
                              meNotifier.setSecurityQuestion2(question2!);
                            },
                            onChanged: (value) {},
                            items: securityQuestions
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                          const SizedBox(height: 30),
                          CustomTextFields(
                            label: 'Security Answer 2',
                            prefixIcon: Icons.question_answer,
                            onSaved: (value) {
                              meNotifier.setSecurityAnswer2(value!.toString());
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide an answer';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          CustomButton(
                              text: 'Update Password',
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  meNotifier.updatePassword(
                                      context: context, ref: ref);
                                }
                              }),
                          const SizedBox(height: 20),
                          // forgot password
                          TextButton(
                            style: TextButton.styleFrom(
                              splashFactory: NoSplash.splashFactory,
                              padding: const EdgeInsets.all(0),
                            ),
                            onPressed: () {
                              context.go(RouterInfo.authRoute.path);
                            },
                            child: Text(
                              'Back to Login',
                              style: getTextStyle(),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
