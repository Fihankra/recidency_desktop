import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';
import 'package:residency_desktop/features/core/usecase/user_usecase.dart';

import '../../../utils/application_utils.dart';
import '../../container/provider/main_provider.dart';
import '../../dashboard/data/attendance_model.dart';
import '../../dashboard/usecase/attendance_usecase.dart';
import '../../settings/provider/settings_provider.dart';

final myselfProvider = StateNotifierProvider<Myself, UserModel>((ref) {
  var dio = ref.watch(serverProvider);
  return Myself(dio!);
});

class Myself extends StateNotifier<UserModel> {
  Myself(this.dio) : super(UserModel());
  final Dio dio;

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
    state = state.copyWith(password: () => state.password!);
    var (exception, user) =
        await UserUseCase(dio: dio).updateUser(state.toUpdatePassword());
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

  void logout(BuildContext context, WidgetRef ref) async {
    CustomDialog.dismiss();
    CustomDialog.showLoading(message: 'Logging out...');
    //remove user from state
    var settings = ref.watch(settingsProvider);
    var attendance = await AttendanceUseCase(dio: dio).saveAttendance(
      AttendanceModel(
        id: AppUtils.getId(),
        action: 'logout',
        assistantId: state.id!,
        assistantName: '${state.firstname} ${state.surname}',
        date: DateFormat('MMM dd, yyyy').format(DateTime.now()),
        time: DateFormat('hh:mm a').format(DateTime.now()),
        academicYear: settings.academicYear!,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (attendance != null) {
      ref.read(attendanceDataProvider.notifier).addAttendance(attendance);
    }
    state = UserModel();
    CustomDialog.dismiss();
    if (mounted) {
      context.go(RouterInfo.authRoute.path);
    }
    CustomDialog.showToast(message: 'Logged out successfully');
  }
}
