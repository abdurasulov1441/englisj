import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddFilePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final String? editFileId;
  final String? editFileName;

  AddFilePage({this.editFileId, this.editFileName}) {
    if (editFileName != null) {
      _controller.text = editFileName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.foregroundColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset('assets/icons/arrow_back.svg'),
          ),
        ),
        centerTitle: true,
        title: Text(
          editFileId == null ? 'Add file' : 'Edit file',
          style: AppStyle.fontStyle
              .copyWith(fontSize: 20, color: AppColors.appBarTextColor),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                fillColor: AppColors.foregroundColor,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.dividerColor),
                ),
                hintText: 'Enter file name',
                hintStyle: AppStyle.fontStyle
                    .copyWith(color: AppColors.dividerColor, fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (editFileId == null) {
                    FirebaseFirestore.instance
                        .collection('files')
                        .add({'name': _controller.text});
                  } else {
                    FirebaseFirestore.instance
                        .collection('files')
                        .doc(editFileId)
                        .update({'name': _controller.text});
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.saveButtonColor,
                ),
                child: Text(
                  'S A V E',
                  style: AppStyle.fontStyle
                      .copyWith(color: AppColors.foregroundColor, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
