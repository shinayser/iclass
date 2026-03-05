class ExerciseFormData {
  final String question;
  final List<String> alternatives;
  final int correctIndex;

  const ExerciseFormData({
    required this.question,
    required this.alternatives,
    required this.correctIndex,
  });
}
