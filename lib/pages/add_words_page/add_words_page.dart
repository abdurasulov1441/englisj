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
  List<Map<String, TextEditingController>> exampleControllers = [];

  @override
  void initState() {
    super.initState();

    ruleController = TextEditingController(text: widget.initialRule ?? '');
    commentController =
        TextEditingController(text: widget.initialComment ?? '');

    // Defolt 1 misol qo'shish
    if (widget.initialExamples != null && widget.initialExamples!.isNotEmpty) {
      for (var example in widget.initialExamples!) {
        _addExample(
          english: example['english'],
          uzbek: example['uzbek'],
        );
      }
    } else {
      _addExample(); // Agar misollar bo‘lmasa, 1 ta qo‘shiladi
    }
  }

  @override
  void dispose() {
    ruleController.dispose();
    commentController.dispose();
    for (var controller in exampleControllers) {
      controller['english']!.dispose();
      controller['uzbek']!.dispose();
    }
    super.dispose();
  }

  void _addExample({String english = '', String uzbek = ''}) {
    if (exampleControllers.length < 3) {
      setState(() {
        exampleControllers.add({
          'english': TextEditingController(text: english),
          'uzbek': TextEditingController(text: uzbek),
        });
      });
    }
  }

  void _removeExample(int index) {
    if (exampleControllers.length > 1) {
      setState(() {
        exampleControllers[index]['english']!.dispose();
        exampleControllers[index]['uzbek']!.dispose();
        exampleControllers.removeAt(index);
      });
    }
  }

  void saveWord() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, String>> examples = exampleControllers.map((example) {
      return {
        'english': example['english']!.text,
        'uzbek': example['uzbek']!.text,
      };
    }).toList();

    if (widget.wordId == null) {
      await FirebaseFirestore.instance
          .collection('files')
          .doc(widget.fileId)
          .collection('words')
          .add({
        'rule': ruleController.text,
        'comment': commentController.text,
        'examples': examples,
        'uid': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      });
    } else {
      await FirebaseFirestore.instance
          .collection('files')
          .doc(widget.fileId)
          .collection('words')
          .doc(widget.wordId)
          .update({
        'rule': ruleController.text,
        'comment': commentController.text,
        'examples': examples,
      });
    }

    if (context.mounted) {
      context.pop();
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
              context.pop();
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

              // Misollar
              Column(
                children: List.generate(exampleControllers.length, (index) {
                  return Column(
                    children: [
                      _buildExampleContainer(index),
                      SizedBox(height: 10),
                    ],
                  );
                }),
              ),

              // "+" Tugma
              if (exampleControllers.length < 3)
                ElevatedButton.icon(
                  onPressed: _addExample,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Example',
                    style: AppStyle.fontStyle.copyWith(color: Colors.white),
                  ),
                ),

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

  Widget _buildExampleContainer(int index) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Example ${index + 1}',
                style: AppStyle.fontStyle.copyWith(
                  color: AppColors.dividerColor,
                  fontSize: 16,
                ),
              ),
              if (exampleControllers.length > 1)
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeExample(index),
                ),
            ],
          ),
          CustomTextField(
            controller: exampleControllers[index]['english']!,
            hintText: 'English',
          ),
          CustomTextField(
            controller: exampleControllers[index]['uzbek']!,
            hintText: 'Uzbek',
          ),
        ],
      ),
    );
  }
}
