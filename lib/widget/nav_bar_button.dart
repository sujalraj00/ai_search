// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ai_search/themes/colors.dart';
import 'package:flutter/material.dart';

class NavBarButton extends StatelessWidget {
  final bool isColapsed;
  final IconData icon;
  final String text;
  const NavBarButton({
    super.key,
    required this.isColapsed,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isColapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Icon(icon, color: AppColors.iconGrey, size: 22),
        ),
        isColapsed
            ? const SizedBox()
            : Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
      ],
    );
  }
}
