import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:english/pages/add_file_page/add_file_page.dart';
import 'package:english/pages/words_page/words_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Learning English Quickly',
            style: AppStyle.fontStyle
                .copyWith(fontSize: 20, color: AppColors.appBarTextColor),
          )),
      body: StreamBuilder(
        stream: _firestore.collection('files').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var files = snapshot.data!.docs;
          return Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
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
                          builder: (context) => AddFilePage(),
                        ),
                      ),
                      child: Text(
                        'Add File',
                        style: AppStyle.fontStyle
                            .copyWith(color: AppColors.foregroundColor),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    var file = files[index];
                    return StreamBuilder(
                      stream: _firestore
                          .collection('files')
                          .doc(file.id)
                          .collection('words')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> wordSnapshot) {
                        int wordCount = 0;
                        if (wordSnapshot.hasData) {
                          wordCount = wordSnapshot.data!.docs.length;
                        }
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordsScreen(
                                fileId: file.id,
                                fileName: file['name'],
                              ),
                            ),
                          ),
                          child: Card(
                            elevation: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(file['name'],
                                    style: AppStyle.fontStyle.copyWith(
                                        color: AppColors.fileTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text(
                                  wordCount.toString(),
                                  style: AppStyle.fontStyle.copyWith(
                                      fontSize: 25, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
