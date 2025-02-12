import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  CustomTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          fillColor: AppColors.foregroundColor,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.dividerColor),
          ),
          hintText: hintText,
          hintStyle: AppStyle.fontStyle
              .copyWith(color: AppColors.dividerColor, fontSize: 16),
        ),
      ),
    );
  }
}
