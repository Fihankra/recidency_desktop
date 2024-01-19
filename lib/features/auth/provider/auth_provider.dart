import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/core/provider/navigation_provider.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/container/provider/main_provider.dart';
import 'package:residency_desktop/features/core/usecase/user_usecase.dart';
import 'package:residency_desktop/features/dashboard/usecase/attendance_usecase.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:residency_desktop/utils/application_utils.dart';
import '../../dashboard/data/attendance_model.dart';
import '../data/auth_model.dart';

final authProvider = StateNotifierProvider<AuthProvider, AuthModel>((ref) {
  var dio = ref.watch(serverProvider);
  return AuthProvider(dio);
});

class AuthProvider extends StateNotifier<AuthModel> {
  AuthProvider(
    this.dio,
  ) : super(AuthModel());
  final Dio? dio;
  void setId(String? id) {
    state = state.copyWith(id: () => id);
  }

  void setPassword(String? password) {
    state = state.copyWith(password: () => password);
  }

  void login({required BuildContext context, required WidgetRef ref}) async {
    CustomDialog.showLoading(message: 'Logging in...');
    if (dio == null) {
      ref.invalidate(serverFuture);
      var server = ref.watch(serverFuture);
      server.when(
          data: (value) {
            var server = ref.watch(serverProvider);
            CustomDialog.dismiss();
            if (server == null) {
              CustomDialog.showError(
                  message:
                      'Unable to connect to server. Contact system administrator');
            } else {
              CustomDialog.showSuccess(message: 'Server refreshed, try again');
            }
          },
          loading: () {},
          error: (error, stackTrace) {
            CustomDialog.dismiss();
            CustomDialog.showError(
                message:
                    'Unable to connect to server, please check your network connection (Cable). Contact your system administrator if problem persist');
          });

      return;
    }
    var (exception, user) =
        await UserUseCase(dio: dio!).loginUser(state.id!, state.password!);
    if (exception != null) {
      CustomDialog.dismiss();
      CustomDialog.showError(
        message: exception.toString().contains('Dio')
            ? 'Unable to connect to server, please check your network connection (Cable). Contact your system administrator if problem persist'
            : exception.toString(),
      );
    } else {
      if (user != null) {
        CustomDialog.dismiss();

        ref.read(myselfProvider.notifier).setMyself(user);
        if (state.id == state.password) {
          CustomDialog.showSuccess(
            message: 'You are using default password, please change it',
          );
          context.go(RouterInfo.newPasswordRoute.path);
        } else {
          var settings = ref.read(settingsProvider);
          if (settings.id != null &&
              settings.academicYear != null &&
              settings.hallName != null &&
              settings.targetGender != null) {
            //mark attendance
            var attendance = await AttendanceUseCase(dio: dio!).saveAttendance(
              AttendanceModel(
                id: AppUtils.getId(),
                action: 'Login',
                assistantId: user.id!,
                assistantName: '${user.firstname} ${user.surname}',
                date: DateFormat('MMM dd, yyyy').format(DateTime.now()),
                time: DateFormat('hh:mm a').format(DateTime.now()),
                academicYear: settings.academicYear!,
                createdAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
            if (attendance != null) {
              ref
                  .read(attendanceDataProvider.notifier)
                  .addAttendance(attendance);
            }
            if (mounted) {
              if (user.role == Role.hallAdmin) {
                context.go(RouterInfo.dashboardRoute.path);
              } else {
                context.go(RouterInfo.homeRoute.path);
              }
            }
          } else {
            ref.read(navProvider.notifier).state =
                RouterInfo.settingsRoute.routeName;
            context.go(RouterInfo.settingsRoute.path);
          }
          CustomDialog.showToast(
            message: 'Login Successful',
          );
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
