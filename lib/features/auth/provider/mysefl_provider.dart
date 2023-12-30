import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';
import 'package:residency_desktop/features/core/usecase/user_usecase.dart';
import 'package:residency_desktop/utils/application_utils.dart';

final myselfProvider = StateNotifierProvider<Myself, UserModel>((ref) {
  var db = ref.watch(dbProvider);
  return Myself(db!);
});

class Myself extends StateNotifier<UserModel> {
  Myself(this.db) : super(UserModel());
  final Db db;

  void setMyself(UserModel user) {
    state = user;
  }

  void setPassword(String s) {
    state = state.copyWith(password: () => s);
  }

  void setSecurityQuestion1(param0) {
    state = state.copyWith(question1: () => param0.toString());
  }

  void setSecurityAnswer1(String string) {
    state = state.copyWith(answer1: () => string);
  }

  void setSecurityQuestion2(param0) {
    state = state.copyWith(question2: () => param0.toString());
  }

  void setSecurityAnswer2(String string) {
    state = state.copyWith(answer2: () => string);
  }

  void updatePassword(
      {required BuildContext context, required WidgetRef ref}) async {
    CustomDialog.showLoading(message: 'Updating Password...');
    state =
        state.copyWith(password: () => AppUtils.hashPassword(state.password!));
    var (exception, user) =
        await UserUseCase(db: db).updateUser(state.toUpdatePassword());
    if (exception != null) {
      CustomDialog.dismiss();
      CustomDialog.showError(
        message: exception.toString(),
      );
    } else {
      if (user != null) {
        CustomDialog.dismiss();
        CustomDialog.showToast(
          message: 'Password Updated Successfully',
        );
        ref.read(myselfProvider.notifier).setMyself(user);
        context.go(RouterInfo.authRoute.path);
      } else {
        CustomDialog.dismiss();
        CustomDialog.showError(
          message: 'Something went wrong',
        );
      }
    }
  }

  void logout(BuildContext context) {
    CustomDialog.dismiss();
    CustomDialog.showLoading(message: 'Logging out...');
    //remove user from state
    state = UserModel();
    CustomDialog.dismiss();
    context.go(RouterInfo.authRoute.path);

    CustomDialog.showToast(message: 'Logged out successfully');
  }
}
