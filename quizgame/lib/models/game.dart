import 'package:cloud_firestore/cloud_firestore.dart';
import 'question.dart';

class PlayerScore {
  final String odbc;
  final String name;
  final String? avatar;
  final int score;
  final int correctAnswers;
  final int totalAnswered;
  final List<int> answerTimes; // Time taken for each answer in seconds

  PlayerScore({
    required this.odbc,
    required this.name,
    this.avatar,
    this.score = 0,
    this.correctAnswers = 0,
    this.totalAnswered = 0,
    this.answerTimes = const [],
  });

  factory PlayerScore.fromMap(Map<String, dynamic> data) {
    return PlayerScore(
      odbc: data['uid'] as String,
      name: data['name'] as String,
      avatar: data['avatar'] as String?,
      score: data['score'] as int? ?? 0,
      correctAnswers: data['correctAnswers'] as int? ?? 0,
      totalAnswered: data['totalAnswered'] as int? ?? 0,
      answerTimes: List<int>.from(data['answerTimes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': odbc,
    'name': name,
    'avatar': avatar,
    'score': score,
    'correctAnswers': correctAnswers,
    'totalAnswered': totalAnswered,
    'answerTimes': answerTimes,
  };

  PlayerScore copyWith({
    int? score,
    int? correctAnswers,
    int? totalAnswered,
    List<int>? answerTimes,
  }) {
    return PlayerScore(
      odbc: odbc,
      name: name,
      avatar: avatar,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      answerTimes: answerTimes ?? this.answerTimes,
    );
  }
}

class RoundAnswer {
  final String odbc;
  final int selectedOption;
  final int timeToAnswer; // in seconds
  final bool isCorrect;

  RoundAnswer({
    required this.odbc,
    required this.selectedOption,
    required this.timeToAnswer,
    required this.isCorrect,
  });

  factory RoundAnswer.fromMap(Map<String, dynamic> data) {
    return RoundAnswer(
      odbc: data['uid'] as String,
      selectedOption: data['selectedOption'] as int,
      timeToAnswer: data['timeToAnswer'] as int,
      isCorrect: data['isCorrect'] as bool,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': odbc,
    'selectedOption': selectedOption,
    'timeToAnswer': timeToAnswer,
    'isCorrect': isCorrect,
  };
}

class Game {
  final String id;
  final String roomId;
  final String hostId;
  final List<Question> questions;
  final int currentRound;
  final int totalRounds;
  final int tourTime;
  final String state; // 'generating', 'countdown', 'playing', 'reviewing', 'results', 'finished'
  final Map<String, PlayerScore> playerScores;
  final Map<int, List<RoundAnswer>> roundAnswers; // Map of round number to answers
  final DateTime? roundStartTime;
  final DateTime createdAt;

  Game({
    required this.id,
    required this.roomId,
    required this.hostId,
    required this.questions,
    this.currentRound = 0,
    required this.totalRounds,
    required this.tourTime,
    this.state = 'generating',
    this.playerScores = const {},
    this.roundAnswers = const {},
    this.roundStartTime,
    required this.createdAt,
  });

  Question? get currentQuestion {
    if (currentRound >= 0 && currentRound < questions.length) {
      return questions[currentRound];
    }
    return null;
  }

  bool get isLastRound => currentRound >= totalRounds - 1;

  factory Game.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Parse questions
    final questionsData = data['questions'] as List<dynamic>? ?? [];
    final questions = questionsData.asMap().entries.map((entry) {
      return Question.fromMap(entry.value as Map<String, dynamic>, 'q_${entry.key}');
    }).toList();

    // Parse player scores
    final scoresData = data['playerScores'] as Map<String, dynamic>? ?? {};
    final playerScores = scoresData.map((key, value) {
      return MapEntry(key, PlayerScore.fromMap(value as Map<String, dynamic>));
    });

    // Parse round answers
    final answersData = data['roundAnswers'] as Map<String, dynamic>? ?? {};
    final roundAnswers = answersData.map((key, value) {
      final answers = (value as List<dynamic>)
          .map((a) => RoundAnswer.fromMap(a as Map<String, dynamic>))
          .toList();
      return MapEntry(int.parse(key), answers);
    });

    return Game(
      id: doc.id,
      roomId: data['roomId'] as String,
      hostId: data['hostId'] as String,
      questions: questions,
      currentRound: data['currentRound'] as int? ?? 0,
      totalRounds: data['totalRounds'] as int,
      tourTime: data['tourTime'] as int,
      state: data['state'] as String? ?? 'generating',
      playerScores: playerScores,
      roundAnswers: roundAnswers,
      roundStartTime: data['roundStartTime'] != null 
          ? (data['roundStartTime'] as Timestamp).toDate() 
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'roomId': roomId,
    'hostId': hostId,
    'questions': questions.map((q) => q.toMap()).toList(),
    'currentRound': currentRound,
    'totalRounds': totalRounds,
    'tourTime': tourTime,
    'state': state,
    'playerScores': playerScores.map((k, v) => MapEntry(k, v.toMap())),
    'roundAnswers': roundAnswers.map((k, v) => MapEntry(k.toString(), v.map((a) => a.toMap()).toList())),
    'roundStartTime': roundStartTime != null ? Timestamp.fromDate(roundStartTime!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Game copyWith({
    List<Question>? questions,
    int? currentRound,
    String? state,
    Map<String, PlayerScore>? playerScores,
    Map<int, List<RoundAnswer>>? roundAnswers,
    DateTime? roundStartTime,
  }) {
    return Game(
      id: id,
      roomId: roomId,
      hostId: hostId,
      questions: questions ?? this.questions,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds,
      tourTime: tourTime,
      state: state ?? this.state,
      playerScores: playerScores ?? this.playerScores,
      roundAnswers: roundAnswers ?? this.roundAnswers,
      roundStartTime: roundStartTime ?? this.roundStartTime,
      createdAt: createdAt,
    );
  }
}
