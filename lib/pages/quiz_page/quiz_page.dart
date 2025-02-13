import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english/common/style/app_colors.dart';
import 'package:english/common/style/app_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class QuizPage extends StatefulWidget {
  final String? fileId;

  QuizPage({this.fileId});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> allWords = [];
  int currentQuestionIndex = 0;
  List<String> answerOptions = [];
  String? correctAnswer;
  String? selectedAnswer;
  bool showCheckButton = false;
  bool isAnswerChecked = false;
  int correctCount = 0;
  List<Map<String, dynamic>> userResults = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QuerySnapshot filesSnapshot;

    if (widget.fileId == null) {
      // 📌 Загружаем только файлы текущего пользователя
      filesSnapshot = await FirebaseFirestore.instance
          .collection('files')
          .where('uid', isEqualTo: user.uid) // 🔥 Фильтрация по userId
          .get();
    } else {
      filesSnapshot = await FirebaseFirestore.instance
          .collection('files')
          .where(FieldPath.documentId, isEqualTo: widget.fileId)
          .where('uid', isEqualTo: user.uid) // 🔥 Фильтрация по userId
          .get();
    }

    List<Map<String, dynamic>> wordsList = [];

    for (var file in filesSnapshot.docs) {
      var wordsSnapshot = await file.reference.collection('words').get();
      for (var word in wordsSnapshot.docs) {
        wordsList.add({
          'rule': word['rule'],
          'comment': word['comment'],
        });
      }
    }

    if (wordsList.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Недостаточно данных для викторины")),
      );
      return;
    }

    setState(() {
      allWords = wordsList;
      nextQuestion();
    });
  }

  /// 📌 Генерируем следующий вопрос (по порядку)
  void nextQuestion() {
    if (currentQuestionIndex >= allWords.length) {
      saveResultsToFirebase();
      return;
    }

    correctAnswer = allWords[currentQuestionIndex]['comment'];

    List<String> options = [correctAnswer!];
    for (var word in allWords) {
      if (options.length >= 4) break;
      if (word['comment'] != correctAnswer) {
        options.add(word['comment']);
      }
    }
    options.shuffle();

    setState(() {
      answerOptions = options;
      selectedAnswer = null;
      showCheckButton = false;
      isAnswerChecked = false;
    });
  }

  /// 📌 Проверяем ответ
  void checkAnswer() {
    if (selectedAnswer == null) return;

    bool isCorrect = selectedAnswer == correctAnswer;
    if (isCorrect) correctCount++;

    userResults.add({
      'rule': allWords[currentQuestionIndex]['rule'],
      'correct': correctAnswer,
      'selected': selectedAnswer,
      'isCorrect': isCorrect,
    });

    setState(() {
      isAnswerChecked = true;
      showCheckButton = false;
    });
  }

  /// 📌 Сохраняем результаты в Firebase
  void saveResultsToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('user_results')
        .doc(user.uid)
        .set({
      'correctCount': correctCount,
      'total': allWords.length,
      'results': userResults,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {});
  }

  /// 📌 Перезапускаем тест
  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      correctCount = 0;
      userResults.clear();
      nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (allWords.isEmpty) {
      return Scaffold(
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
            "Loading...",
            style: AppStyle.fontStyle
                .copyWith(fontSize: 20, color: AppColors.appBarTextColor),
          ),
        ),
        body: Center(
            child: CircularProgressIndicator(
          color: AppColors.darkGreenColor,
        )),
      );
    }

    return Scaffold(
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
          "Quiz",
          style: AppStyle.fontStyle
              .copyWith(fontSize: 20, color: AppColors.appBarTextColor),
        ),
      ),
      body: currentQuestionIndex >= allWords.length
          ? buildResultsScreen()
          : buildQuestionScreen(),
    );
  }

  /// 📌 Экран вопросов
  Widget buildQuestionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            allWords[currentQuestionIndex]['rule'],
            style: AppStyle.fontStyle
                .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Card(
            color: AppColors.foregroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: answerOptions.map((answer) {
                  Color answerColor = Colors.white;
                  if (isAnswerChecked) {
                    if (answer == correctAnswer) {
                      answerColor = Colors.green.withOpacity(0.5);
                    } else if (answer == selectedAnswer) {
                      answerColor = Colors.red.withOpacity(0.5);
                    }
                  }

                  return RadioListTile<String>(
                    value: answer,
                    groupValue: selectedAnswer,
                    title: Text(answer),
                    activeColor: AppColors.buttonColor,
                    tileColor: answerColor,
                    onChanged: isAnswerChecked
                        ? null
                        : (value) {
                            setState(() {
                              selectedAnswer = value;
                              showCheckButton = true;
                            });
                          },
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isAnswerChecked
                ? () {
                    setState(() {
                      currentQuestionIndex++;
                      nextQuestion();
                    });
                  }
                : checkAnswer,
            child: Text(isAnswerChecked ? "NEXT" : "CHECK",
                style: AppStyle.fontStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foregroundColor)),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: isAnswerChecked ? Colors.blue : Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResultsScreen() {
    return Center(
      child: Container(
        width: double.infinity,
        color: AppColors.backgroundColor,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dividerColor),
            color: AppColors.foregroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "F I N I S H E D",
                style: AppStyle.fontStyle.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fileTextColor),
              ),
              SizedBox(height: 10),
              Text(
                "$correctCount / ${allWords.length}",
                style: AppStyle.fontStyle.copyWith(
                    color: AppColors.fileTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: userResults.map((entry) {
                    return Card(
                      color: AppColors.backgroundColor,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['rule'],
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "You select: ${entry['selected']}",
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            Text(
                              "Correct answer: ${entry['correct']}",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: restartQuiz,
                child: Text("R E S T A R T",
                    style: AppStyle.fontStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foregroundColor)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
