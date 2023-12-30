import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/core/provider/navigation_provider.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:residency_desktop/generated/assets.dart';
import 'side_bar_item.dart';

class SideBar extends ConsumerStatefulWidget {
  const SideBar({super.key});

  @override
  ConsumerState<SideBar> createState() => _SideBarState();
}

class _SideBarState extends ConsumerState<SideBar> {
  double sideWidth = 60;

  @override
  Widget build(BuildContext context) {
    var me = ref.watch(myselfProvider);
    var isAdmin = me.role== Role.hallAdmin;
    return Card(
      elevation: 3,
      child: Container(
        width: sideWidth,
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: sideWidth == 60
                ? MainAxisAlignment.center
                : MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  setState(() {
                    if (sideWidth == 200) {
                      sideWidth = 60;
                    } else {
                      sideWidth = 200;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            height: 5,
            thickness: 2,
          ),
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            Assets.imagesLogo,
            width: sideWidth < 200 ? 100 : 150,
          ),
          const SizedBox(
            height: 20,
          ),
          const Divider(
            height: 5,
            thickness: 2,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SideBarItem(
                    title: isAdmin ? 'Dashboard' : 'Home',
                    route: RouterInfo.dashboardRoute,
                    icon: Icons.dashboard,
                    width: sideWidth,
                    onTap: () {
                      if (isAdmin) {
                        _gotoPage(RouterInfo.dashboardRoute);
                      } else {
                        _gotoPage(RouterInfo.homeRoute);
                      }
                    },
                    isSelected: ref.watch(navProvider) ==
                            RouterInfo.dashboardRoute.routeName ||
                        ref.watch(navProvider) ==
                            RouterInfo.homeRoute.routeName,
                  ),
                  if (isAdmin)
                    SideBarItem(
                      title: 'Staffs',
                      route: RouterInfo.assistantsRoute,
                      icon: MdiIcons.accountGroup,
                      width: sideWidth,
                      onTap: () {
                        _gotoPage(RouterInfo.assistantsRoute);
                      },
                      isSelected: ref.watch(navProvider) ==
                          RouterInfo.assistantsRoute.routeName,
                    ),
                  if (isAdmin)
                    SideBarItem(
                        title: 'Students',
                        route: RouterInfo.studentsRoute,
                        icon: MdiIcons.school,
                        width: sideWidth,
                        onTap: () {
                          _gotoPage(RouterInfo.studentsRoute);
                        },
                        isSelected: ref.watch(navProvider) ==
                            RouterInfo.studentsRoute.routeName),
                  if (isAdmin)
                    SideBarItem(
                        title: 'Allocations',
                        route: RouterInfo.homeRoute,
                        icon: FontAwesomeIcons.rectangleList,
                        width: sideWidth,
                        onTap: () {
                          _gotoPage(RouterInfo.homeRoute);
                        },
                        isSelected: ref.watch(navProvider) ==
                            RouterInfo.homeRoute.routeName),

                  SideBarItem(
                    title: 'Key Logs',
                    route: RouterInfo.keyLogsRoute,
                    icon: MdiIcons.keyPlus,
                    width: sideWidth,
                    onTap: () {
                      _gotoPage(RouterInfo.keyLogsRoute);
                    },
                    isSelected: ref.watch(navProvider) ==
                        RouterInfo.keyLogsRoute.routeName,
                  ),
                  SideBarItem(
                    title: 'Complaints',
                    route: RouterInfo.complaintsRoute,
                    icon: FontAwesomeIcons.listCheck,
                    width: sideWidth,
                    onTap: () {
                      _gotoPage(RouterInfo.complaintsRoute);
                    },
                    isSelected: ref.watch(navProvider) ==
                        RouterInfo.complaintsRoute.routeName,
                  ),
                  if (isAdmin)
                    SideBarItem(
                        title: 'Messages',
                        route: RouterInfo.messagesRoute,
                        icon: FontAwesomeIcons.message,
                        width: sideWidth,
                        onTap: () {
                          _gotoPage(RouterInfo.messagesRoute);
                        },
                        isSelected: ref.watch(navProvider) ==
                            RouterInfo.messagesRoute.routeName),
                  if (isAdmin)
                    SideBarItem(
                      title: 'Settings',
                      route: RouterInfo.settingsRoute,
                      icon: Icons.settings,
                      width: sideWidth,
                      onTap: () {
                        _gotoPage(RouterInfo.settingsRoute);
                      },
                      isSelected: ref.watch(navProvider) ==
                          RouterInfo.settingsRoute.routeName,
                    ),
                  //logout
                  SideBarItem(
                    title: 'Logout',
                    icon: Icons.logout,
                    width: sideWidth,
                    onTap: () {
                      CustomDialog.showInfo(
                        message: 'Are you sure you want to logout?',
                        buttonText: 'Logout',
                        onPressed: () {
                          ref.watch(myselfProvider.notifier).logout(context);
                        },
                      );
                    },
                  ),
                ]),
          )),
          const Text(
            '© 2023 Residency',
            style: TextStyle(color: Colors.white, fontSize: 10),
          )
        ]),
        //copy right text
      ),
    );
  }

  _gotoPage(RouterInfo routerInfo) {
    var settings = ref.read(settingsProvider);
    if (routerInfo.routeName == RouterInfo.settingsRoute.routeName ||
        (settings.id != null && settings.academicYear != null)) {
      ref.read(navProvider.notifier).state = routerInfo.routeName;
      context.go(routerInfo.path);
    } else {
      CustomDialog.showInfo(
          message: 'Settings are not set yet, please set them first',
          buttonText: 'Settings',
          onPressed: () {
            ref.read(navProvider.notifier).state =
                RouterInfo.settingsRoute.routeName;
            context.go(RouterInfo.settingsRoute.path);
          });
    }
  }
}
