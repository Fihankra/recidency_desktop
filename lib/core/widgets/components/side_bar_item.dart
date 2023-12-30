import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residency_desktop/config/router/provider/theme_provider.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/config/theme/theme.dart';

class SideBarItem extends ConsumerStatefulWidget {
  const SideBarItem(
      {super.key,
      this.route,
      required this.icon,
      required this.title,
      this.onTap,
      this.isSelected = false,
      required this.width});

  final RouterInfo? route;
  final IconData icon;
  final String title;
  final Function()? onTap;
  final bool? isSelected;
  final double width;

  @override
  ConsumerState<SideBarItem> createState() => _SideBarItemState();
}

class _SideBarItemState extends ConsumerState<SideBarItem> {
  bool onHover = false;
  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    return InkWell(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!.call();
          }
        },
        onHover: (value) {
          setState(() {
            onHover = value;
          });
        },
        child: Container(
          height: 50,
          alignment: Alignment.center,
          color: widget.isSelected ?? false
              ? theme == darkMode
                  ? Colors.white
                  : Theme.of(context).colorScheme.background
              : onHover
                  ? secondaryColor
                  : Colors.transparent,
          child: widget.width > 60
              ? Row(
                  children: [
                    const SizedBox(width: 5),
                    Icon(
                      widget.icon,
                      size: widget.isSelected ?? false ? 29 : 25,
                      color: widget.isSelected ?? false
                          ? primaryColor
                          : onHover
                              ? Colors.white
                              : null,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      widget.title,
                      style: TextStyle(
                          color: widget.isSelected ?? false
                              ? primaryColor
                              : onHover
                                  ? Colors.white
                                  : null,
                          fontSize: widget.isSelected ?? false ? 18 : 16,
                          fontWeight: widget.isSelected ?? false
                              ? FontWeight.w700
                              : FontWeight.w400),
                    )
                  ],
                )
              : Icon(
                  widget.icon,
                  size: widget.isSelected ?? false ? 29 : 25,
                  color: widget.isSelected ?? false
                      ? primaryColor
                      : onHover
                          ? Colors.white
                          : null,
                ),
        ));
  }
}
