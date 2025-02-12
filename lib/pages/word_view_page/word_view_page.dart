import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WordViewPage extends StatelessWidget {
  final String rule;
  final String comment;
  final List<Map<String, dynamic>> examples;

  WordViewPage(
      {required this.rule, required this.comment, required this.examples});

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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rule:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(rule, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Comment:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(comment, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Examples:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...examples.map((example) => Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EN: ${example['english']}',
                          style: TextStyle(fontSize: 16, color: Colors.blue)),
                      Text('UZ: ${example['uzbek']}',
                          style: TextStyle(fontSize: 16, color: Colors.green)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
