import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddFilePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset('assets/icons/arrow_back.svg')),
          ),
          centerTitle: true,
          title: Text(
            'Add file',
            style: AppStyle.fontStyle
                .copyWith(fontSize: 20, color: AppColors.appBarTextColor),
          )),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  fillColor: AppColors.foregroundColor,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.dividerColor)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  hintText: 'file name enter',
                  hintStyle: AppStyle.fontStyle
                      .copyWith(color: AppColors.dividerColor, fontSize: 16)),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('files')
                      .add({'name': _controller.text});
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.saveButtonColor),
                child: Text('S A V E',
                    style: AppStyle.fontStyle.copyWith(
                        color: AppColors.foregroundColor, fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
