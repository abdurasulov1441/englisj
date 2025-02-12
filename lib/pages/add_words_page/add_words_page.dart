import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:english/pages/add_words_page/my_custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AddWordScreen extends StatefulWidget {
  final String fileId;
  final String? wordId;
  final String? initialRule;
  final String? initialComment;
  final List<Map<String, dynamic>>? initialExamples;

  AddWordScreen({
    required this.fileId,
    this.wordId,
    this.initialRule,
    this.initialComment,
    this.initialExamples,
  });

  @override
  _AddWordScreenState createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  late TextEditingController ruleController;
  late TextEditingController commentController;
  late TextEditingController example1EnController;
  late TextEditingController example1UzController;
  late TextEditingController example2EnController;
  late TextEditingController example2UzController;
  late TextEditingController example3EnController;
  late TextEditingController example3UzController;

  @override
  void initState() {
    super.initState();

    ruleController = TextEditingController(text: widget.initialRule ?? '');
    commentController =
        TextEditingController(text: widget.initialComment ?? '');

    example1EnController = TextEditingController(
        text: widget.initialExamples?.isNotEmpty == true
            ? widget.initialExamples![0]['english']
            : '');
    example1UzController = TextEditingController(
        text: widget.initialExamples?.isNotEmpty == true
            ? widget.initialExamples![0]['uzbek']
            : '');

    example2EnController = TextEditingController(
        text:
            widget.initialExamples != null && widget.initialExamples!.length > 1
                ? widget.initialExamples![1]['english']
                : '');
    example2UzController = TextEditingController(
        text:
            widget.initialExamples != null && widget.initialExamples!.length > 1
                ? widget.initialExamples![1]['uzbek']
                : '');

    example3EnController = TextEditingController(
        text:
            widget.initialExamples != null && widget.initialExamples!.length > 2
                ? widget.initialExamples![2]['english']
                : '');
    example3UzController = TextEditingController(
        text:
            widget.initialExamples != null && widget.initialExamples!.length > 2
                ? widget.initialExamples![2]['uzbek']
                : '');
  }

  @override
  void dispose() {
    ruleController.dispose();
    commentController.dispose();
    example1EnController.dispose();
    example1UzController.dispose();
    example2EnController.dispose();
    example2UzController.dispose();
    example3EnController.dispose();
    example3UzController.dispose();
    super.dispose();
  }

  void saveWord() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (widget.wordId == null) {
      await FirebaseFirestore.instance
          .collection('files')
          .doc(widget.fileId)
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
        ],
        'uid': user.uid, // Привязываем слово к пользователю
      });
    } else {
      // Обновляем существующее слово
      await FirebaseFirestore.instance
          .collection('files')
          .doc(widget.fileId)
          .collection('words')
          .doc(widget.wordId)
          .update({
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
        ],
      });
    }

    context.pop(context);
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
              context.pop(context);
            },
            child: SvgPicture.asset('assets/icons/arrow_back.svg'),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.wordId == null ? 'Add Word' : 'Edit Word',
          style: AppStyle.fontStyle
              .copyWith(fontSize: 20, color: AppColors.appBarTextColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(controller: ruleController, hintText: 'Rule'),
              CustomTextField(
                  controller: commentController, hintText: 'Comment'),
              SizedBox(height: 10),
              _buildExampleContainer(
                  'First Example', example1EnController, example1UzController),
              SizedBox(height: 10),
              _buildExampleContainer(
                  'Second Example', example2EnController, example2UzController),
              SizedBox(height: 10),
              _buildExampleContainer(
                  'Third Example', example3EnController, example3UzController),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveWord,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.saveButtonColor,
                  ),
                  child: Text(
                    'S A V E',
                    style: AppStyle.fontStyle.copyWith(
                      color: AppColors.foregroundColor,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleContainer(String title,
      TextEditingController enController, TextEditingController uzController) {
    return Container(
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
            title,
            style: AppStyle.fontStyle.copyWith(
              color: AppColors.dividerColor,
              fontSize: 16,
            ),
          ),
          CustomTextField(controller: enController, hintText: 'English'),
          CustomTextField(controller: uzController, hintText: 'Uzbek'),
        ],
      ),
    );
  }
}
