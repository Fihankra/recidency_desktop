import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residency_desktop/database/connection.dart';
import '../../../config/router/provider/theme_provider.dart';
import '../../../config/theme/theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../generated/assets.dart';
import '../provider/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool obSecureText = true;

  final _idController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: '123456789');

  @override
  Widget build(BuildContext context) {
    var dbConnection = ref.watch(serverFuture);
    return Center(
      child: Card(
        elevation: 5,
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: dbConnection.when(
              loading: () => Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 15),
                      Text(
                        'Connecting to Server, Make sure network cable is connected',
                        style: getTextStyle(),
                      ),
                    ],
                  )),
              error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Unable to connect to database',
                          style: getTextStyle(),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            var refresh = ref.refresh(serverFuture);
                            refresh.whenData((value) => null);
                          },
                          child: Text(
                            'Retry',
                            style: getTextStyle(),
                          ),
                        ),
                      ],
                    ),
                  ),
              data: (data) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 600,
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            // id field
                            CustomTextFields(
                              label: 'Login ID',
                              prefixIcon: Icons.person,
                              controller: _idController,
                              onSaved: (value) {
                                ref.read(authProvider.notifier).setId(value!);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your ID';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // password field
                            CustomTextFields(
                              label: 'Password',
                              controller: _passwordController,
                              onSaved: (value) {
                                ref
                                    .read(authProvider.notifier)
                                    .setPassword(value!);
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
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            // login button
                            CustomButton(
                                text: 'Login',
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    ref
                                        .read(authProvider.notifier)
                                        .login(context: context, ref: ref);
                                  }
                                }),
                            const SizedBox(height: 20),
                            // forgot password
                            TextButton(
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                                padding: const EdgeInsets.all(0),
                              ),
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: getTextStyle(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
