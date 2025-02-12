import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english/app/router.dart';
import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:english/pages/add_file_page/add_file_page.dart';
import 'package:english/pages/auth/login_screen.dart';
import 'package:english/pages/words_page/words_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return LoginScreen();
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.go(Routes.loginPage);
            },
            icon: Icon(
              Icons.exit_to_app,
              color: AppColors.iconColor,
            ),
          ),
        ],
        backgroundColor: AppColors.foregroundColor,
        centerTitle: true,
        title: Text(
          'Learning English Quickly',
          style: AppStyle.fontStyle
              .copyWith(fontSize: 20, color: AppColors.appBarTextColor),
        ),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('files')
            .where('uid', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var files = snapshot.data!.docs;
          return Column(
            children: [
              SizedBox(height: 10),
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
                          .where('uid', isEqualTo: user.uid)
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
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Wrap(
                                children: [
                                  ListTile(
                                    leading: SvgPicture.asset(
                                      'assets/icons/edit.svg',
                                      color: AppColors.wordHeaderTextColor,
                                    ),
                                    title: Text(
                                      'Edit File',
                                      style: AppStyle.fontStyle,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddFilePage(
                                            editFileId: file.id,
                                            editFileName: file['name'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: SvgPicture.asset(
                                      'assets/icons/delete.svg',
                                      color: AppColors.iconColor,
                                    ),
                                    title: Text(
                                      'Delete File',
                                      style: AppStyle.fontStyle,
                                    ),
                                    onTap: () {
                                      _showDeleteConfirmationDialog(
                                          context, file.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Card(
                            color: AppColors.foregroundColor,
                            elevation: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    file['name'],
                                    style: AppStyle.fontStyle.copyWith(
                                      color: AppColors.fileTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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

  void _showDeleteConfirmationDialog(BuildContext context, String fileId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Deletion',
            style: AppStyle.fontStyle.copyWith(fontSize: 20),
          ),
          content: Text(
            'Are you sure you want to delete this file? This action cannot be undone.',
            style: AppStyle.fontStyle,
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(context);
              },
              child: Text('Cancel',
                  style: AppStyle.fontStyle.copyWith(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('files')
                    .doc(fileId)
                    .delete();
                context.pop(context);
              },
              child: Text('Delete',
                  style: AppStyle.fontStyle.copyWith(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
