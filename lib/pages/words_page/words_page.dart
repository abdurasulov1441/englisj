import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:english/pages/add_words_page/add_words_page.dart';
import 'package:english/pages/word_view_page/word_view_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';

class WordsScreen extends StatelessWidget {
  final String fileId;
  final String fileName;

  WordsScreen({required this.fileId, required this.fileName});

  @override
  Widget build(BuildContext context) {
    void _showDeleteConfirmationDialog(
        BuildContext context, String fileId, String wordId) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.foregroundColor,
            title: Text(
              'Confirm Deletion',
              style: AppStyle.fontStyle.copyWith(fontSize: 20),
            ),
            content: Text(
              'Are you sure you want to delete this word? This action cannot be undone.',
              style: AppStyle.fontStyle.copyWith(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                    style: AppStyle.fontStyle.copyWith(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('files')
                      .doc(fileId)
                      .collection('words')
                      .doc(wordId)
                      .delete();
                  Navigator.pop(context);
                },
                child: Text('Delete',
                    style: AppStyle.fontStyle.copyWith(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.foregroundColor,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrow_back.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          fileName,
          style: AppStyle.fontStyle.copyWith(
            fontSize: 20,
            color: AppColors.appBarTextColor,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.buttonColor,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWordScreen(fileId: fileId),
                  ),
                ),
                child: Text(
                  'Add word',
                  style: AppStyle.fontStyle.copyWith(
                    color: AppColors.foregroundColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('files')
                  .doc(fileId)
                  .collection('words')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(
                    'No words added yet.',
                    style: AppStyle.fontStyle,
                  ));
                }

                var words = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    var word = words[index];
                    return Card(
                      color: AppColors.foregroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          word['rule'],
                          style: AppStyle.fontStyle.copyWith(
                            color: AppColors.wordHeaderTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          word['comment'],
                          style: AppStyle.fontStyle.copyWith(
                            color: AppColors.darkGreenColor,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset('assets/icons/edit.svg',
                                  color: AppColors.wordHeaderTextColor),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddWordScreen(
                                      fileId: fileId,
                                      wordId: word.id, // Передаем ID слова
                                      initialRule: word[
                                          'rule'], // Передаем текущие данные
                                      initialComment: word['comment'],
                                      initialExamples:
                                          List<Map<String, dynamic>>.from(
                                              word['examples']),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: SvgPicture.asset('assets/icons/delete.svg',
                                  color: AppColors.iconColor),
                              onPressed: () {
                                _showDeleteConfirmationDialog(
                                    context, fileId, word.id);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordViewPage(
                                rule: word['rule'],
                                comment: word['comment'],
                                examples: List<Map<String, dynamic>>.from(
                                    word['examples']),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
