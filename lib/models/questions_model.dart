enum QuestionType { text, number, radio, checkBox, dropDown }

class Question {
  final String key;
  final String label;
  final QuestionType type;
  final List<String>? options;
  final String? hint;
  final bool required;

  Question({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.hint,
    this.required = true,
  });
}
