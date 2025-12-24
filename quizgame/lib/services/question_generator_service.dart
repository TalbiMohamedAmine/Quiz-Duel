import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class QuestionGeneratorService {
  // Using Gemini API for question generation
  // You should store this in a secure location (e.g., Firebase Remote Config or environment variable)
  static const String _apiKey = 'AIzaSyAX3EcmhRO5eUggJGJax7ac-X0XnKzshSU';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  final Random _random = Random();

  /// Generates questions for the game based on selected categories
  /// Distributes questions randomly across categories to reach totalQuestions
  Future<List<Question>> generateQuestions({
    required List<String> categories,
    required int totalQuestions,
  }) async {
    if (categories.isEmpty) {
      throw Exception('At least one category must be selected');
    }

    // Distribute questions randomly across categories
    final questionDistribution = _distributeQuestionsAcrossCategories(
      categories: categories,
      totalQuestions: totalQuestions,
    );

    final List<Question> allQuestions = [];

    // Generate questions for each category
    for (final entry in questionDistribution.entries) {
      final category = entry.key;
      final count = entry.value;

      if (count > 0) {
        try {
          final questions = await _generateQuestionsForCategory(
            category: category,
            count: count,
          );
          allQuestions.addAll(questions);
        } catch (e) {
          print('Error generating questions for $category: $e');
          // Generate fallback questions if API fails
          allQuestions.addAll(_generateFallbackQuestions(category, count));
        }
      }
    }

    // Shuffle all questions to mix categories
    allQuestions.shuffle(_random);

    return allQuestions;
  }

  /// Distributes total questions randomly across categories
  Map<String, int> _distributeQuestionsAcrossCategories({
    required List<String> categories,
    required int totalQuestions,
  }) {
    final distribution = <String, int>{};
    
    // Initialize all categories with 0
    for (final category in categories) {
      distribution[category] = 0;
    }

    // Randomly assign each question to a category
    for (int i = 0; i < totalQuestions; i++) {
      final randomCategory = categories[_random.nextInt(categories.length)];
      distribution[randomCategory] = distribution[randomCategory]! + 1;
    }

    return distribution;
  }

  /// Generates questions for a specific category using Gemini AI
  Future<List<Question>> _generateQuestionsForCategory({
    required String category,
    required int count,
  }) async {
    final prompt = '''
Generate exactly $count multiple-choice quiz questions about "$category".

Each question must:
- Be interesting and educational
- Have exactly 4 options (A, B, C, D)
- Have only one correct answer
- Be suitable for a general audience
- Vary in difficulty (easy, medium, hard)

Return the response in this exact JSON format:
{
  "questions": [
    {
      "question": "What is the question text?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswerIndex": 0,
      "explanation": "Brief explanation of why this is correct"
    }
  ]
}

Important:
- correctAnswerIndex is 0-based (0 for first option, 1 for second, etc.)
- Generate exactly $count questions
- Make sure questions are factually accurate
- Return only valid JSON, no markdown formatting
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        // Clean up the response - remove markdown code blocks if present
        String cleanedText = text.trim();
        if (cleanedText.startsWith('```json')) {
          cleanedText = cleanedText.substring(7);
        } else if (cleanedText.startsWith('```')) {
          cleanedText = cleanedText.substring(3);
        }
        if (cleanedText.endsWith('```')) {
          cleanedText = cleanedText.substring(0, cleanedText.length - 3);
        }
        cleanedText = cleanedText.trim();

        final jsonData = jsonDecode(cleanedText);
        final questionsList = jsonData['questions'] as List<dynamic>;

        return questionsList.map((q) {
          return Question.fromJson(q as Map<String, dynamic>, category);
        }).toList();
      } else {
        throw Exception('API request failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      rethrow;
    }
  }

  /// Generates fallback questions if AI generation fails
  List<Question> _generateFallbackQuestions(String category, int count) {
    final fallbackQuestions = <Question>[];
    
    for (int i = 0; i < count; i++) {
      fallbackQuestions.add(Question(
        id: 'fallback_${DateTime.now().millisecondsSinceEpoch}_$i',
        questionText: 'Sample question ${i + 1} about $category',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswerIndex: _random.nextInt(4),
        category: category,
        explanation: 'This is a fallback question.',
      ));
    }
    
    return fallbackQuestions;
  }
}
