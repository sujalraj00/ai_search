import 'package:ai_search/themes/colors.dart';
import 'package:flutter/material.dart';

class SearchBarButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final GestureTapCallback onTap;
  final bool isLoading;

  const SearchBarButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<SearchBarButton> createState() => _SearchBarButtonState();
}

class _SearchBarButtonState extends State<SearchBarButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHover = false;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isHover ? AppColors.proButton : Colors.transparent,
        ),
        child: GestureDetector(
          onTap: widget.isLoading ? null : widget.onTap,
          child: Row(
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.iconGrey,
                    ),
                  ),
                )
              else
                Icon(widget.icon, color: AppColors.iconGrey),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  color:
                      widget.isLoading
                          ? AppColors.textGrey.withValues(alpha: 0.6)
                          : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
