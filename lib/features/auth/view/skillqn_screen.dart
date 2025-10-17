import 'package:codeup/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class SkillqnScreen extends StatefulWidget {
  const SkillqnScreen({super.key});
  @override
  State<SkillqnScreen> createState() => _SkillqnScreenState();
}

class _SkillqnScreenState extends State<SkillqnScreen> {
  int currentQuestionIndex = 0;
  int? selectedIndex;
  int score = 0;
  bool quizFinished = false;

  List<Question> questions = [
    Question(
      questionText: "What comes next in the sequence? 2,4,8,16,..",
      options: ["20", "24", "32", "34"],
      correctAnswerIndex: 2,
    ),
    Question(
      questionText: "I am an odd number.Remove one letter and I became even.Which number am I?",
      options: ["Eleven", "Seven", "Nine", "Thirteen"],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: "Which of the following is odd one out?",
      options: ["Triangle","Square","Pentagon","Sphere"],
      correctAnswerIndex: 3,
    ),
    Question(
      questionText: "If A×B=35 and A=7,what is the value of B?",
      options: ["4", "5", "6", "7"],
      correctAnswerIndex:1,
    ),
    Question(
     questionText: "If a mirror image of a clock shows 4:30,what is the actual time?",
     options: ["7:30", "8:30", "7:00", "8:00"], 
     correctAnswerIndex: 0,
    ),
    Question(
      questionText: "Find the missing number in the sequence 1,4,9,16,...35",
      options: ["20","25","28","30"],
      correctAnswerIndex: 1,
    ),
    Question(
    questionText:"The average (arithmetic mean) weight of three students is 50 kg. If the first student weighs 45 kg and the second weighs 55 kg, what is the weight of the third student?",
    options: ["40kg","50kg","55kg","60kg"],
    correctAnswerIndex: 1,
    ),
    Question(
       questionText: "In a row of five objects (X, Y, Z, W, V):Y is immediately to the right of X. Z is to the left of X.​V is to the right of W. W is not next to Z.​Which object is in the exact middle position?",
       options: ["X","Y","W","Z"], 
       correctAnswerIndex: 3,
       ),
    Question(
        questionText: "Mary is twice as old as her brother, who is 4 years older than their sister. If their sister is 10 years old, how old is Mary?" ,
        options: ["14","20","24","28"],
        correctAnswerIndex: 3,
        ),
    Question(
       questionText: "If 5 workers can build 5 machines in 5 minutes, how many workers are needed to build 100 machines in 100 minutes?",
       options: ["1","5","20","100"],
       correctAnswerIndex: 1,
       ),
  ];

  void goToNextQuestion() {
    setState(() {
      if (selectedIndex == questions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      }

      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedIndex = null;
      } else {
        quizFinished = true;
      }
    });
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedIndex = null;
      score = 0;
      quizFinished = false;
    });
  }

  String getLevel() {
    if (score >= 9) {
      return "Hard";
    } else if (score >= 5 && score <= 8) {
      return "Medium";
    } else {
      return "Basic";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quizFinished) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text("Quiz Result"),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "🎉 Quiz Finished!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your IQ Level:",
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text(
                    getLevel(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 28,
                      ),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    label: Text(
                      "LETS GO!",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    var currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Skill Quiz"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: Padding(
          key: ValueKey<int>(currentQuestionIndex),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    currentQuestion.questionText,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    final option = currentQuestion.options[index];
                    final isSelected = selectedIndex == index;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: isSelected
                              ? Colors.blueAccent
                              : Colors.white,
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.black87,
                          side: BorderSide(color: Colors.blueAccent, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Text(option, style: TextStyle(fontSize: 18)),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                onPressed: selectedIndex != null ? goToNextQuestion : null,
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Question ${currentQuestionIndex + 1} of ${questions.length}",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
