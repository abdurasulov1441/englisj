import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WordViewPage extends StatelessWidget {
  final String rule;
  final String comment;
  final List<Map<String, dynamic>> examples;

  const WordViewPage({
    super.key,
    required this.rule,
    required this.comment,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.foregroundColor,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrow_back.svg'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.foregroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rule,
                  style: AppStyle.fontStyle.copyWith(
                      color: AppColors.darkGreenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              SizedBox(height: 10),
              Text(comment,
                  style: AppStyle.fontStyle
                      .copyWith(fontSize: 16, color: AppColors.orange)),
              SizedBox(height: 50),
              ...examples.map((example) => Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Example ${examples.indexOf(example) + 1}',
                            style: AppStyle.fontStyle.copyWith(
                                color: AppColors.dividerColor, fontSize: 16)),
                        Row(
                          children: [
                            Text(
                              '${example['english']}',
                              style: AppStyle.fontStyle.copyWith(
                                fontSize: 16,
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${example['uzbek']}',
                                style: AppStyle.fontStyle.copyWith(
                                  fontSize: 16,
                                  color: AppColors.greenTextColor,
                                )),
                          ],
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
