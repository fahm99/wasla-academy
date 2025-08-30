import 'section.dart';

class Quiz {
  final String id;
  final String title;
  final String? description;
  final String lessonId;
  final int passingScore;
  final int? timeLimitMinutes;
  final List<Question> questions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Lesson? lesson;

  const Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.lessonId,
    required this.passingScore,
    this.timeLimitMinutes,
    this.questions = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lesson,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      lessonId: json['lesson_id'] as String,
      passingScore: json['passing_score'] as int,
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      questions: json['questions'] != null
          ? List<Question>.from(
              (json['questions'] as List).map((question) => Question.fromJson(question)))
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lesson: json['lesson'] != null
          ? Lesson.fromJson(json['lesson'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lesson_id': lessonId,
      'passing_score': passingScore,
      'time_limit_minutes': timeLimitMinutes,
      'questions': questions.map((question) => question.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'lesson': lesson?.toJson(),
    };
  }

  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    String? lessonId,
    int? passingScore,
    int? timeLimitMinutes,
    List<Question>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
    Lesson? lesson,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      lessonId: lessonId ?? this.lessonId,
      passingScore: passingScore ?? this.passingScore,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lesson: lesson ?? this.lesson,
    );
  }

  int get totalPoints => questions.fold(0, (sum, question) => sum + question.points);

  int get totalQuestions => questions.length;

  String get formattedTimeLimit {
    if (timeLimitMinutes == null) return 'غير محدد';
    if (timeLimitMinutes! < 60) {
      return '$timeLimitMinutes دقيقة';
    } else {
      final hours = timeLimitMinutes! ~/ 60;
      final minutes = timeLimitMinutes! % 60;
      if (minutes == 0) {
        return '$hours ساعة';
      } else {
        return '$hours ساعة و $minutes دقيقة';
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quiz && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Quiz(id: $id, title: $title, questions: ${questions.length})';
  }
}

class Question {
  final String id;
  final String quizId;
  final String questionText;
  final String questionType;
  final int points;
  final int orderIndex;
  final List<Option> options;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Question({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    required this.points,
    required this.orderIndex,
    this.options = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      points: json['points'] as int,
      orderIndex: json['order_index'] as int,
      options: json['options'] != null
          ? List<Option>.from(
              (json['options'] as List).map((option) => Option.fromJson(option)))
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question_text': questionText,
      'question_type': questionType,
      'points': points,
      'order_index': orderIndex,
      'options': options.map((option) => option.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Question copyWith({
    String? id,
    String? quizId,
    String? questionText,
    String? questionType,
    int? points,
    int? orderIndex,
    List<Option>? options,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      questionText: questionText ?? this.questionText,
      questionType: questionType ?? this.questionType,
      points: points ?? this.points,
      orderIndex: orderIndex ?? this.orderIndex,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isMultipleChoice => questionType == 'multiple_choice';
  bool get isTrueFalse => questionType == 'true_false';
  bool get isSingleChoice => questionType == 'single_choice';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Question(id: $id, type: $questionType, points: $points)';
  }
}

class Option {
  final String id;
  final String questionId;
  final String optionText;
  final bool isCorrect;
  final int orderIndex;
  final DateTime createdAt;

  const Option({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
    required this.orderIndex,
    required this.createdAt,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      optionText: json['option_text'] as String,
      isCorrect: json['is_correct'] as bool,
      orderIndex: json['order_index'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'is_correct': isCorrect,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Option copyWith({
    String? id,
    String? questionId,
    String? optionText,
    bool? isCorrect,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return Option(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      optionText: optionText ?? this.optionText,
      isCorrect: isCorrect ?? this.isCorrect,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Option && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Option(id: $id, isCorrect: $isCorrect)';
  }
}

