import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/features/messages/views/messages_page.dart';
import 'package:residency_desktop/features/messages/views/new_message.dart';
import 'package:residency_desktop/features/staffs/views/staff_list.dart';
import 'package:residency_desktop/features/staffs/views/edit_staff.dart';
import 'package:residency_desktop/features/staffs/views/new_staff.dart';
import 'package:residency_desktop/features/auth/views/new_password.dart';
import 'package:residency_desktop/features/complaints/views/complaints_page.dart';
import 'package:residency_desktop/features/container/auth_container.dart';
import 'package:residency_desktop/features/container/home_container.dart';
import 'package:residency_desktop/features/dashboard/views/admin_dashboard.dart';
import 'package:residency_desktop/features/dashboard/views/attendance.dart';
import 'package:residency_desktop/features/home/views/home_page.dart';
import 'package:residency_desktop/features/keyFlow/views/key_flow_page.dart';
import 'package:residency_desktop/features/settings/views/settings_page.dart';
import 'package:residency_desktop/features/students/views/components/students_list.dart';
import 'package:residency_desktop/features/students/views/components/edit_student.dart';
import 'package:residency_desktop/features/students/views/components/new_student.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/complaints/views/new_complain.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final navKey = GlobalKey<NavigatorState>();
final router = GoRouter(
    initialLocation: RouterInfo.authRoute.path,
    navigatorKey: rootNavigatorKey,
    errorBuilder: (context, state) {
      return Consumer(
        builder: (_, WidgetRef ref, __) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Page not found',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: CustomButton(
                        text: 'Go to Login',
                        onPressed: () {
                          // ref.read(adminNavProvider.notifier).state =
                          //     RouterInfo.dashboardRout.name;
                          context.go(RouterInfo.authRoute.path);
                        }),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (state, context) => RouterInfo.authRoute.path,
      ),
      StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, navigationShell) => NoTransitionPage(
                child: AuthContainerPage(
                  key: state.pageKey,
                  child: navigationShell,
                ),
              ),
          branches: [
            StatefulShellBranch(
                initialLocation: RouterInfo.authRoute.path,
                navigatorKey: navKey,
                routes: [
                  GoRoute(
                    path: RouterInfo.authRoute.path,
                    name: RouterInfo.authRoute.routeName,
                    pageBuilder: (context, state) => NoTransitionPage(
                        child: LoginPage(
                      key: state.pageKey,
                    )),
                  ),
                  GoRoute(
                    path: RouterInfo.newPasswordRoute.path,
                    name: RouterInfo.newPasswordRoute.routeName,
                    pageBuilder: (context, state) => NoTransitionPage(
                        child: NewPassword(
                      key: state.pageKey,
                    )),
                  ),
                ]),
          ]),
      StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, navigationShell) => NoTransitionPage(
                child: HomeContainer(
                  key: state.pageKey,
                  child: navigationShell,
                ),
              ),
          branches: [
            StatefulShellBranch(
                initialLocation: RouterInfo.dashboardRoute.path,
                routes: [
                  GoRoute(
                    path: RouterInfo.dashboardRoute.path,
                    name: RouterInfo.dashboardRoute.routeName,
                    pageBuilder: (context, state) => NoTransitionPage(
                        child: AdminDashboard(
                      key: state.pageKey,
                    )),
                  ),
                  GoRoute(
                      path: RouterInfo.settingsRoute.path,
                      name: RouterInfo.settingsRoute.routeName,
                      pageBuilder: (context, state) {
                        return const NoTransitionPage(
                          child: SettingsPage(),
                        );
                      }),
                  //complaints
                  GoRoute(
                      path: RouterInfo.complaintsRoute.path,
                      name: RouterInfo.complaintsRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: ComplaintsPage(
                            key: state.pageKey,
                          ),
                        );
                      }),

                  //key flow
                  GoRoute(
                      path: RouterInfo.keyLogsRoute.path,
                      name: RouterInfo.keyLogsRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: KeyFlowPage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  //attendance
                  GoRoute(
                      path: RouterInfo.attendanceRoute.path,
                      name: RouterInfo.attendanceRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: AttendancePage(
                            key: state.pageKey,
                          ),
                        );
                      }),

                  //assistant
                  GoRoute(
                      path: RouterInfo.assistantsRoute.path,
                      name: RouterInfo.assistantsRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: StaffListPage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  //new assistant
                  GoRoute(
                      path: RouterInfo.newAssistantRoute.path,
                      name: RouterInfo.newAssistantRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: NewStaffPage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  //edit assistant
                  GoRoute(
                      path: RouterInfo.editAssistantRoute.path,
                      name: RouterInfo.editAssistantRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: EditStaffPage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  //students
                  GoRoute(
                      path: RouterInfo.studentsRoute.path,
                      name: RouterInfo.studentsRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: StudentList(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  //new student
                  GoRoute(
                      path: RouterInfo.newStudentRoute.path,
                      name: RouterInfo.newStudentRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: NewStudent(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  //edit student
                  GoRoute(
                      path: RouterInfo.editStudentRoute.path,
                      name: RouterInfo.editStudentRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: EditStudent(
                            key: state.pageKey,
                          ),
                        );
                      }),

                  //assistant routes
                  GoRoute(
                      path: RouterInfo.homeRoute.path,
                      name: RouterInfo.homeRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: HomePage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                       GoRoute(
                      path: RouterInfo.allocationRoute.path,
                      name: RouterInfo.allocationRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: HomePage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                  //new complaint route
                  GoRoute(
                      path: RouterInfo.newComplaintRoute.path,
                      name: RouterInfo.newComplaintRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: NewComplain(
                            key: state.pageKey,
                          ),
                        );
                      }),
                       GoRoute(
                      path: RouterInfo.messagesRoute.path,
                      name: RouterInfo.messagesRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: MessagesPage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                       GoRoute(
                      path: RouterInfo.newMessageRoute.path,
                      name: RouterInfo.newMessageRoute.routeName,
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: NewMessagePage(
                            key: state.pageKey,
                          ),
                        );
                      }),
                       
                ]),
          ]),
    ]);
