import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? actionButton;

  const CustomAppBar({super.key, required this.title, this.actionButton});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.brown.shade400,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      actions: actionButton != null ? [actionButton!] : [],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
