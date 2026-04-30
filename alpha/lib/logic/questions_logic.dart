class Question {
  final String qString;
  final List<String> options;
  final String answer;

  Question(
      {required this.qString, required this.options, required this.answer}) {
    assert(options.contains(answer) == true);
  }
}
