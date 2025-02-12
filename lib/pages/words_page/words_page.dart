import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:english/pages/add_words_page/add_words_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';

class WordsScreen extends StatelessWidget {
  final String fileId;
  final String fileName;

  WordsScreen({required this.fileId, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  return Center(child: Text('No words added yet.'));
                }

                var words = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    var word = words[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          word['rule'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        subtitle: Text(
                          word['comment'],
                          style: TextStyle(color: Colors.green),
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

class WordViewPage extends StatelessWidget {
  final String rule;
  final String comment;
  final List<Map<String, dynamic>> examples;

  WordViewPage({
    required this.rule,
    required this.comment,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrow_back.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Word Details',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 20,
            color: AppColors.appBarTextColor,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rule:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(rule, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              'Comment:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(comment, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              'Examples:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...examples.map((example) => Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EN: ${example['english']}',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                      Text(
                        'UZ: ${example['uzbek']}',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
