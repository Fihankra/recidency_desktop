import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/core/provider/navigation_provider.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/core/usecase/user_usecase.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:residency_desktop/utils/application_utils.dart';
import '../data/auth_model.dart';

final authProvider = StateNotifierProvider<AuthProvider, AuthModel>((ref) {
  var db = ref.watch(dbProvider);
  return AuthProvider(db!);
});

class AuthProvider extends StateNotifier<AuthModel> {
  AuthProvider(
    this.db,
  ) : super(AuthModel());
  final Db db;
  void setId(String? id) {
    state = state.copyWith(id: () => id);
  }

  void setPassword(String? password) {
    state = state.copyWith(password: () => password);
  }

  void login({required BuildContext context, required WidgetRef ref}) async {
    CustomDialog.showLoading(message: 'Logging in...');
    var (exception, user) =
        await UserUseCase(db: db).loginUser(state.id!, state.password!);
    if (exception != null) {
      CustomDialog.dismiss();
      CustomDialog.showError(
        message: exception.toString(),
      );
    } else {
      if (user != null) {
        CustomDialog.dismiss();

        ref.read(myselfProvider.notifier).setMyself(user);
        if (AppUtils.comparePassword(user.id!, user.password!)) {
          CustomDialog.showSuccess(
            message: 'You are using default password, please change it',
          );
          context.go(RouterInfo.newPasswordRoute.path);
        } else {
          CustomDialog.showToast(
            message: 'Login Successful',
          );
          var settings = ref.read(settingsProvider);
          if (settings.id != null &&
              settings.academicYear != null &&
              settings.hallName != null &&
              settings.targetGender != null) {
            if (user.role == Role.hallAdmin) {
              context.go(RouterInfo.dashboardRoute.path);
            } else {
              context.go(RouterInfo.homeRoute.path);
            }
          } else {
            ref.read(navProvider.notifier).state =
                RouterInfo.settingsRoute.routeName;
            context.go(RouterInfo.settingsRoute.path);
          }
        }
      } else {
        CustomDialog.dismiss();
        CustomDialog.showError(
          message: 'ID or Password is incorrect',
        );
      }
    }
  }
}
