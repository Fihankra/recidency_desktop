import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:residency_desktop/config/theme/theme.dart';
import 'package:residency_desktop/core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_ui.dart';

class PageHeaders extends StatelessWidget {
  const PageHeaders(
      {super.key,
      this.hasBackButton,
      this.hasExtraButton,
      this.onBackButtonPressed,
      this.onExtraButtonPressed,
      this.title,
      this.subTitle,
      this.hasSecondExtraButton,
      this.onSecondExtraButtonPressed,
      this.secondExtraButtonText,
      this.extraButtonText});
  final bool? hasBackButton, hasExtraButton;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onExtraButtonPressed;
  final String? title, subTitle;
  final String? extraButtonText;
  final bool? hasSecondExtraButton;
  final VoidCallback? onSecondExtraButtonPressed;
  final String? secondExtraButtonText;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Theme.of(context).colorScheme.secondary, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (hasBackButton ?? false)
                  ResponsiveScreen.isMobile(context)
                      ? GestureDetector(
                          onTap: onBackButtonPressed,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                                child: Icon(
                              FontAwesomeIcons.arrowLeft,
                              size: 15,
                              color: Colors.white,
                            )),
                          ),
                        )
                      : CustomButton(
                          text: 'Back',
                          icon: FontAwesomeIcons.arrowLeft,
                          color: Colors.red,
                          onPressed: onBackButtonPressed,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                        ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title != null ? title!.toUpperCase() : "",
                        style: getTextStyle(
                          fontSize: 30,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subTitle ?? "",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          fontSize:
                              ResponsiveScreen.isMobile(context) ? 12 : 14,
                          color: primaryColor,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (hasExtraButton ?? false)
                  ResponsiveScreen.isMobile(context)
                      ? hasSecondExtraButton ?? false
                          ?
                          // pop up menu
                          PopupMenuButton(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                    child: Icon(
                                  Icons.add,
                                  size: 15,
                                  color: Colors.white,
                                )),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'first',
                                  child: Text('$extraButtonText'),
                                ),
                                PopupMenuItem(
                                  value: 'second',
                                  child: Text('$secondExtraButtonText'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'first') {
                                  onExtraButtonPressed!.call();
                                } else {
                                  onSecondExtraButtonPressed!.call();
                                }
                              },
                            )
                          : GestureDetector(
                              onTap: onExtraButtonPressed,
                              child: Tooltip(
                                message: extraButtonText ?? "",
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                      child: Icon(
                                    Icons.add,
                                    size: 15,
                                    color: Colors.white,
                                  )),
                                ),
                              ),
                            )
                      : hasSecondExtraButton ?? false
                          ?
                          //row
                          Row(
                              children: [
                                CustomButton(
                                  text: extraButtonText ?? "",
                                  icon: FontAwesomeIcons.plus,
                                  radius: 5,
                                  onPressed: onExtraButtonPressed,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                ),
                                const SizedBox(width: 10),
                                CustomButton(
                                  text: secondExtraButtonText ?? "",
                                  icon: FontAwesomeIcons.plus,
                                  radius: 5,
                                  onPressed: onSecondExtraButtonPressed,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                ),
                              ],
                            )
                          : CustomButton(
                              text: extraButtonText ?? "",
                              icon: FontAwesomeIcons.plus,
                              radius: 5,
                              onPressed: onExtraButtonPressed,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                            ),
              ]),
        ],
      ),
    );
  }
}
