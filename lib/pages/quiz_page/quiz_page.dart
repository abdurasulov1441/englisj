import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  bool isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  /// 📌 Загружаем вопросы (из всех файлов или одного)
  void loadQuestions() async {
    QuerySnapshot filesSnapshot;

    if (widget.fileId == null) {
      // 📌 Загружаем ВСЕ слова из всех файлов
      filesSnapshot =
          await FirebaseFirestore.instance.collection('files').get();
    } else {
      // 📌 Загружаем ТОЛЬКО из одного файла
      filesSnapshot = await FirebaseFirestore.instance
          .collection('files')
          .where(FieldPath.documentId, isEqualTo: widget.fileId)
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

  /// 📌 Генерируем следующий вопрос
  void nextQuestion() {
    if (allWords.isEmpty) return;

    Random random = Random();
    int questionIndex = random.nextInt(allWords.length);
    correctAnswer = allWords[questionIndex]['comment'];

    List<String> options = [correctAnswer!];

    while (options.length < 4) {
      String randomAnswer =
          allWords[random.nextInt(allWords.length)]['comment'];
      if (!options.contains(randomAnswer)) {
        options.add(randomAnswer);
      }
    }

    options.shuffle();

    setState(() {
      currentQuestionIndex = questionIndex;
      answerOptions = options;
      selectedAnswer = null;
      showCheckButton = false;
      isAnswerCorrect = false;
    });
  }

  /// 📌 Проверяем ответ
  void checkAnswer() {
    if (selectedAnswer == correctAnswer) {
      setState(() {
        isAnswerCorrect = true;
        Future.delayed(Duration(seconds: 1), () => nextQuestion());
      });
    } else {
      setState(() {
        isAnswerCorrect = false;
        showCheckButton = true;
      });
    }
  }

  /// 📌 Перезапускаем тест
  void restartQuiz() {
    setState(() {
      nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (allWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Quiz")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            allWords[currentQuestionIndex]['rule'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ...answerOptions.map((answer) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedAnswer = answer;
                  showCheckButton = true;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: selectedAnswer == answer
                      ? Colors.blueAccent
                      : Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  answer,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          if (showCheckButton)
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text("Проверить"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          if (!isAnswerCorrect && showCheckButton)
            ElevatedButton(
              onPressed: restartQuiz,
              child: Text("Попробовать заново"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
        ],
      ),
    );
  }
}
