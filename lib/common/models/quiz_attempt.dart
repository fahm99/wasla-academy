import 'quiz.dart';
import 'user.dart';

class QuizAttempt {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final bool passed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? timeSpentSeconds;
  final List<QuestionResponse> responses;
  final Quiz? quiz;
  final User? user;

  const QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.passed,
    required this.startedAt,
    this.completedAt,
    this.timeSpentSeconds,
    this.responses = const [],
    this.quiz,
    this.user,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quizId: json['quiz_id'] as String,
      score: json['score'] as int,
      passed: json['passed'] as bool,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      timeSpentSeconds: json['time_spent_seconds'] as int?,
      responses: json['responses'] != null
          ? List<QuestionResponse>.from(
              (json['responses'] as List).map((response) => QuestionResponse.fromJson(response)))
          : [],
      quiz: json['quiz'] != null
          ? Quiz.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'score': score,
      'passed': passed,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'time_spent_seconds': timeSpentSeconds,
      'responses': responses.map((response) => response.toJson()).toList(),
      'quiz': quiz?.toJson(),
      'user': user?.toJson(),
    };
  }

  QuizAttempt copyWith({
    String? id,
    String? userId,
    String? quizId,
    int? score,
    bool? passed,
    DateTime? startedAt,
    DateTime? completedAt,
    int? timeSpentSeconds,
    List<QuestionResponse>? responses,
    Quiz? quiz,
    User? user,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      score: score ?? this.score,
      passed: passed ?? this.passed,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      responses: responses ?? this.responses,
      quiz: quiz ?? this.quiz,
      user: user ?? this.user,
    );
  }

  bool get isCompleted => completedAt != null;

  String get formattedTimeSpent {
    if (timeSpentSeconds == null) return '';
    
    final minutes = timeSpentSeconds! ~/ 60;
    final seconds = timeSpentSeconds! % 60;
    
    if (minutes > 0) {
      return '$minutes دقيقة و $seconds ثانية';
    } else {
      return '$seconds ثانية';
    }
  }

  String get formattedScore {
    if (quiz != null) {
      return '$score / ${quiz!.totalPoints}';
    }
    return '$score';
  }

  String get formattedDate {
    return '${startedAt.day}/${startedAt.month}/${startedAt.year}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizAttempt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizAttempt(id: $id, score: $score, passed: $passed)';
  }
}

class QuestionResponse {
  final String id;
  final String quizAttemptId;
  final String questionId;
  final String? selectedOptionId;
  final bool isCorrect;
  final DateTime createdAt;
  final Question? question;
  final Option? selectedOption;

  const QuestionResponse({
    required this.id,
    required this.quizAttemptId,
    required this.questionId,
    this.selectedOptionId,
    required this.isCorrect,
    required this.createdAt,
    this.question,
    this.selectedOption,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      id: json['id'] as String,
      quizAttemptId: json['quiz_attempt_id'] as String,
      questionId: json['question_id'] as String,
      selectedOptionId: json['selected_option_id'] as String?,
      isCorrect: json['is_correct'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      question: json['question'] != null
          ? Question.fromJson(json['question'] as Map<String, dynamic>)
          : null,
      selectedOption: json['selected_option'] != null
          ? Option.fromJson(json['selected_option'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_attempt_id': quizAttemptId,
      'question_id': questionId,
      'selected_option_id': selectedOptionId,
      'is_correct': isCorrect,
      'created_at': createdAt.toIso8601String(),
      'question': question?.toJson(),
      'selected_option': selectedOption?.toJson(),
    };
  }

  QuestionResponse copyWith({
    String? id,
    String? quizAttemptId,
    String? questionId,
    String? selectedOptionId,
    bool? isCorrect,
    DateTime? createdAt,
    Question? question,
    Option? selectedOption,
  }) {
    return QuestionResponse(
      id: id ?? this.id,
      quizAttemptId: quizAttemptId ?? this.quizAttemptId,
      questionId: questionId ?? this.questionId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      isCorrect: isCorrect ?? this.isCorrect,
      createdAt: createdAt ?? this.createdAt,
      question: question ?? this.question,
      selectedOption: selectedOption ?? this.selectedOption,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionResponse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuestionResponse(id: $id, isCorrect: $isCorrect)';
  }
}

