import 'package:flutter/material.dart';

import '../question/model/questin_model.dart';

class AddQuestionUnderLevelScreen extends StatefulWidget {
  final QuestionModel? question;
  final String subLevelId;
  final String subLevelName;
  final String mainLevelName;

  const AddQuestionUnderLevelScreen({
    super.key,
    this.question,
    required this.subLevelId,
    required this.subLevelName,
    required this.mainLevelName,
  });

  @override
  State<AddQuestionUnderLevelScreen> createState() =>
      _AddQuestionUnderLevelScreenState();
}

class _AddQuestionUnderLevelScreenState
    extends State<AddQuestionUnderLevelScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final TextEditingController _option1Controller;
  late final TextEditingController _option2Controller;
  late final TextEditingController _option3Controller;
  late final TextEditingController _option4Controller;
  late final TextEditingController _orderController;
  late int _selectedCorrectAnswer;

  @override
  void initState() {
    super.initState();
    
    // Initialize all controllers
    _questionController = TextEditingController(
      text: widget.question?.question ?? '',
    );
    
    _option1Controller = TextEditingController(
      text: (widget.question?.options != null && widget.question!.options.isNotEmpty)
          ? widget.question!.options[0]
          : '',
    );
    
    _option2Controller = TextEditingController(
      text: (widget.question?.options != null && widget.question!.options.length > 1)
          ? widget.question!.options[1]
          : '',
    );
    
    _option3Controller = TextEditingController(
      text: (widget.question?.options != null && widget.question!.options.length > 2)
          ? widget.question!.options[2]
          : '',
    );
    
    _option4Controller = TextEditingController(
      text: (widget.question?.options != null && widget.question!.options.length > 3)
          ? widget.question!.options[3]
          : '',
    );
    
    _orderController = TextEditingController(
      text: widget.question?.order.toString() ?? '1',
    );
    
    _selectedCorrectAnswer = widget.question?.correctAnswer ?? 0;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final questionModel = QuestionModel(
        id: widget.question?.id ?? '',
        question: _questionController.text.trim(),
        options: [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        correctAnswer: _selectedCorrectAnswer,
        order: int.tryParse(_orderController.text) ?? 1,
        subLevelId: widget.subLevelId,
      );

      Navigator.pop(context, questionModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.question != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Question' : 'Add Question',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '${widget.mainLevelName} - ${widget.subLevelName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.check, color: Colors.white),
            label: Text(
              isEditing ? 'Update' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Question Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.quiz, color: Colors.indigo[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Question',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: 'Enter your question here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a question';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: Colors.indigo[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Answer Options',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the circle to mark the correct answer',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    _buildOptionField(_option1Controller, 'A', 0),
                    const SizedBox(height: 12),
                    _buildOptionField(_option2Controller, 'B', 1),
                    const SizedBox(height: 12),
                    _buildOptionField(_option3Controller, 'C', 2),
                    const SizedBox(height: 12),
                    _buildOptionField(_option4Controller, 'D', 3),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Question Order Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered,
                          color: Colors.indigo[700],
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Question Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderController,
                      decoration: InputDecoration(
                        hintText: 'Enter order number (1, 2, 3...)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.looks_one),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter order number';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(
    TextEditingController controller,
    String label,
    int optionIndex,
  ) {
    final isSelected = _selectedCorrectAnswer == optionIndex;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? Colors.green.withValues(alpha: 0.05)
            : Colors.grey[50],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _selectedCorrectAnswer = optionIndex;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Option $label',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}