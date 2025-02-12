import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:english/pages/add_words_page/my_custom_textfield.dart';
import 'package:english/pages/word_view_page/word_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddWordScreen extends StatelessWidget {
  final String fileId;
  final TextEditingController ruleController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController example1EnController = TextEditingController();
  final TextEditingController example1UzController = TextEditingController();
  final TextEditingController example2EnController = TextEditingController();
  final TextEditingController example2UzController = TextEditingController();
  final TextEditingController example3EnController = TextEditingController();
  final TextEditingController example3UzController = TextEditingController();

  AddWordScreen({required this.fileId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(controller: ruleController, hintText: 'Rule'),
              CustomTextField(
                  controller: commentController, hintText: 'Comment'),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.foregroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'First Example',
                      style: AppStyle.fontStyle.copyWith(
                        color: AppColors.dividerColor,
                        fontSize: 16,
                      ),
                    ),
                    CustomTextField(
                        controller: example1EnController, hintText: 'English'),
                    CustomTextField(
                        controller: example1UzController, hintText: 'Uzbek'),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.foregroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Second Example',
                      style: AppStyle.fontStyle.copyWith(
                        color: AppColors.dividerColor,
                        fontSize: 16,
                      ),
                    ),
                    CustomTextField(
                        controller: example2EnController, hintText: 'English'),
                    CustomTextField(
                        controller: example2UzController, hintText: 'Uzbek'),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.foregroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.dividerColor),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Third Example ',
                      style: AppStyle.fontStyle.copyWith(
                        color: AppColors.dividerColor,
                        fontSize: 16,
                      ),
                    ),
                    CustomTextField(
                        controller: example3EnController, hintText: 'English'),
                    CustomTextField(
                        controller: example3UzController, hintText: 'Uzbek'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      DocumentReference newWordRef = await FirebaseFirestore
                          .instance
                          .collection('files')
                          .doc(fileId)
                          .collection('words')
                          .add({
                        'rule': ruleController.text,
                        'comment': commentController.text,
                        'examples': [
                          {
                            'english': example1EnController.text,
                            'uzbek': example1UzController.text
                          },
                          {
                            'english': example2EnController.text,
                            'uzbek': example2UzController.text
                          },
                          {
                            'english': example3EnController.text,
                            'uzbek': example3UzController.text
                          },
                        ]
                      });
                      print(newWordRef.id);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WordViewPage(
                            rule: ruleController.text,
                            comment: commentController.text,
                            examples: [
                              {
                                'english': example1EnController.text,
                                'uzbek': example1UzController.text
                              },
                              {
                                'english': example2EnController.text,
                                'uzbek': example2UzController.text
                              },
                              {
                                'english': example3EnController.text,
                                'uzbek': example3UzController.text
                              },
                            ],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: AppColors.saveButtonColor),
                    child: Text(
                      'S A V E',
                      style: AppStyle.fontStyle.copyWith(
                          color: AppColors.foregroundColor, fontSize: 20),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
