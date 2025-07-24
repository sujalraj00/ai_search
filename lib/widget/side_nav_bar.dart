import 'package:ai_search/themes/colors.dart';
import 'package:ai_search/widget/nav_bar_button.dart';
import 'package:flutter/material.dart';

class SideNavBar extends StatefulWidget {
  const SideNavBar({super.key});

  @override
  State<SideNavBar> createState() => _SideNavBarState();
}

class _SideNavBarState extends State<SideNavBar> {
  bool isColapsed = true;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: isColapsed ? 64 : 164,
      color: AppColors.sideNav,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.auto_awesome_mosaic,
            color: Colors.white,
            size: isColapsed ? 30 : 60,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isColapsed
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                NavBarButton(
                  isColapsed: isColapsed,
                  icon: Icons.add,
                  text: "Home",
                ),
                NavBarButton(
                  isColapsed: isColapsed,
                  icon: Icons.search,
                  text: "Search",
                ),
                NavBarButton(
                  isColapsed: isColapsed,
                  icon: Icons.language,
                  text: "Spaces",
                ),
                NavBarButton(
                  isColapsed: isColapsed,
                  icon: Icons.auto_awesome,
                  text: "Discover",
                ),
                NavBarButton(
                  isColapsed: isColapsed,
                  icon: Icons.cloud_outlined,
                  text: "Library",
                ),

                Spacer(),

                const SizedBox(height: 16),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                isColapsed = !isColapsed;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              child: Icon(
                isColapsed
                    ? Icons.keyboard_arrow_right
                    : Icons.keyboard_arrow_left,
                color: AppColors.iconGrey,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
