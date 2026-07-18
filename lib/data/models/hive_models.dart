import 'package:hive/hive.dart';

// -----------------------------------------------------
// Question Type Enum
// -----------------------------------------------------
enum QuestionType {
  standard,
  fillInBlanks,
  matchFollowing,
  multiStatement
}

class QuestionTypeAdapter extends TypeAdapter<QuestionType> {
  @override
  final int typeId = 2;

  @override
  QuestionType read(BinaryReader reader) {
    return QuestionType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, QuestionType obj) {
    writer.writeInt(obj.index);
  }
}

// -----------------------------------------------------
// Question Model
// -----------------------------------------------------
class QuestionModel {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final List<String>? statements;
  final List<String>? matchList1;
  final List<String>? matchList2;
  final String? examName;
  final String? examYear;

  QuestionModel({
    required this.id,
    required this.question,
    this.type = QuestionType.standard,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.statements,
    this.matchList1,
    this.matchList2,
    this.examName,
    this.examYear,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    QuestionType parseType(String? t) {
      switch (t) {
        case 'fillInBlanks': return QuestionType.fillInBlanks;
        case 'matchFollowing': return QuestionType.matchFollowing;
        case 'multiStatement': return QuestionType.multiStatement;
        default: return QuestionType.standard;
      }
    }

    return QuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      type: parseType(json['type'] as String?),
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String? ?? '',
      statements: json['statements'] != null ? List<String>.from(json['statements']) : null,
      matchList1: json['matchList1'] != null ? List<String>.from(json['matchList1']) : null,
      matchList2: json['matchList2'] != null ? List<String>.from(json['matchList2']) : null,
      examName: json['examName'] as String?,
      examYear: json['examYear'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type.name,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      if (statements != null) 'statements': statements,
      if (matchList1 != null) 'matchList1': matchList1,
      if (matchList2 != null) 'matchList2': matchList2,
      if (examName != null) 'examName': examName,
      if (examYear != null) 'examYear': examYear,
    };
  }
}

class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final int typeId = 0;

  @override
  QuestionModel read(BinaryReader reader) {
    return QuestionModel(
      id: reader.readString(),
      question: reader.readString(),
      type: QuestionType.values[reader.readInt()],
      options: reader.readStringList(),
      correctIndex: reader.readInt(),
      explanation: reader.readString(),
      statements: reader.readBool() ? reader.readStringList() : null,
      matchList1: reader.readBool() ? reader.readStringList() : null,
      matchList2: reader.readBool() ? reader.readStringList() : null,
      examName: reader.readBool() ? reader.readString() : null,
      examYear: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.question);
    writer.writeInt(obj.type.index);
    writer.writeStringList(obj.options);
    writer.writeInt(obj.correctIndex);
    writer.writeString(obj.explanation);
    
    writer.writeBool(obj.statements != null);
    if (obj.statements != null) writer.writeStringList(obj.statements!);
    
    writer.writeBool(obj.matchList1 != null);
    if (obj.matchList1 != null) writer.writeStringList(obj.matchList1!);
    
    writer.writeBool(obj.matchList2 != null);
    if (obj.matchList2 != null) writer.writeStringList(obj.matchList2!);

    writer.writeBool(obj.examName != null);
    if (obj.examName != null) writer.writeString(obj.examName!);

    writer.writeBool(obj.examYear != null);
    if (obj.examYear != null) writer.writeString(obj.examYear!);
  }
}

// -----------------------------------------------------
// Mock Model
// -----------------------------------------------------
class MockModel {
  final String mockId;
  final String mockName;
  final List<QuestionModel> questions;

  MockModel({
    required this.mockId,
    required this.mockName,
    required this.questions,
  });

  factory MockModel.fromJson(Map<String, dynamic> json) {
    return MockModel(
      mockId: json['mockId'] as String,
      mockName: json['mockName'] as String,
      questions: json['questions'] != null
          ? (json['questions'] as List<dynamic>)
              .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mockId': mockId,
      'mockName': mockName,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class MockModelAdapter extends TypeAdapter<MockModel> {
  @override
  final int typeId = 4;

  @override
  MockModel read(BinaryReader reader) {
    return MockModel(
      mockId: reader.readString(),
      mockName: reader.readString(),
      questions: reader.readList().cast<QuestionModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, MockModel obj) {
    writer.writeString(obj.mockId);
    writer.writeString(obj.mockName);
    writer.writeList(obj.questions);
  }
}

// -----------------------------------------------------
// Topic Model
// -----------------------------------------------------
class TopicModel {
  final String topicId;
  final String topicName;
  final bool isPremium;
  final List<MockModel> mocks;

  TopicModel({
    required this.topicId,
    required this.topicName,
    required this.isPremium,
    required this.mocks,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      topicId: json['topicId'] as String,
      topicName: json['topicName'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      mocks: json['mocks'] != null
          ? (json['mocks'] as List<dynamic>)
              .map((item) => MockModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topicId': topicId,
      'topicName': topicName,
      'isPremium': isPremium,
      'mocks': mocks.map((m) => m.toJson()).toList(),
    };
  }
}

class TopicModelAdapter extends TypeAdapter<TopicModel> {
  @override
  final int typeId = 3;

  @override
  TopicModel read(BinaryReader reader) {
    return TopicModel(
      topicId: reader.readString(),
      topicName: reader.readString(),
      isPremium: reader.readBool(),
      mocks: reader.readList().cast<MockModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, TopicModel obj) {
    writer.writeString(obj.topicId);
    writer.writeString(obj.topicName);
    writer.writeBool(obj.isPremium);
    writer.writeList(obj.mocks);
  }
}

// -----------------------------------------------------
// Subject Model
// -----------------------------------------------------
class SubjectModel {
  final String subjectId;
  final String subjectName;
  final List<TopicModel> topics;

  SubjectModel({
    required this.subjectId,
    required this.subjectName,
    required this.topics,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      topics: json['topics'] != null
          ? (json['topics'] as List<dynamic>)
              .map((item) => TopicModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }
}

class SubjectModelAdapter extends TypeAdapter<SubjectModel> {
  @override
  final int typeId = 1;

  @override
  SubjectModel read(BinaryReader reader) {
    return SubjectModel(
      subjectId: reader.readString(),
      subjectName: reader.readString(),
      topics: reader.readList().cast<TopicModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectModel obj) {
    writer.writeString(obj.subjectId);
    writer.writeString(obj.subjectName);
    writer.writeList(obj.topics);
  }
}
