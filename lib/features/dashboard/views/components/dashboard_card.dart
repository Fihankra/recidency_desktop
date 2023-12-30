import 'package:flutter/material.dart';
import 'package:residency_desktop/config/theme/theme.dart';

class DashBoardCard extends StatefulWidget {
  const DashBoardCard(
      {super.key,
      this.title,
      this.value,
      this.icon,
      this.color,
      this.isLoading});
  final String? title;

  final String? value;

  final IconData? icon;

  final Color? color;
  final bool? isLoading;

  @override
  State<DashBoardCard> createState() => _DashBoardCardState();
}

class _DashBoardCardState extends State<DashBoardCard> {
  bool _onHover = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      onHover: (value) {
        setState(() {
          _onHover = value;
        });
      },
      child: Container(
        width: 450,
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _onHover ? Colors.white : widget.color,
            borderRadius: BorderRadius.circular(10),
            border:
                _onHover ? Border.all(color: widget.color!, width: 2) : null,
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, offset: Offset(0, 0), blurRadius: 10)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  size: 50,
                  color: _onHover ? widget.color : Colors.white,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  widget.title ?? '',
                  style: getTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _onHover ? Colors.black : Colors.white),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            widget.isLoading ?? false
                ? const CircularProgressIndicator()
                : Text(
                    widget.value ?? '',
                    style: getTextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: _onHover ? Colors.black : Colors.white),
                  ),
          ],
        ),
      ),
    );
  }
}
