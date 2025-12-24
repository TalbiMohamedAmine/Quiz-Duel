import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String? imageUrl;
  final String? explanation;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    this.imageUrl,
    this.explanation,
  });

  factory Question.fromMap(Map<String, dynamic> data, String id) {
    return Question(
      id: id,
      questionText: data['questionText'] as String,
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] as int,
      category: data['category'] as String,
      imageUrl: data['imageUrl'] as String?,
      explanation: data['explanation'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'questionText': questionText,
    'options': options,
    'correctAnswerIndex': correctAnswerIndex,
    'category': category,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (explanation != null) 'explanation': explanation,
  };

  factory Question.fromJson(Map<String, dynamic> json, String category) {
    return Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      questionText: json['question'] as String,
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      category: category,
      explanation: json['explanation'] as String?,
    );
  }
}
