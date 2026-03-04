import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_v1/features/practice/domain/entities/question_components/question_components.dart';
import 'package:past_question_paper_v1/features/practice/domain/entities/drag_drop/drag_item.dart';
import 'package:past_question_paper_v1/features/practice/domain/entities/drag_drop/drop_target.dart';
import 'package:past_question_paper_v1/core/shared/services/storage_service.dart';

part 'question_mapper.dart';
part 'question_practice_helpers.dart';
part 'question_mode_helpers.dart';

class Question {
  final String id;
  // --- Essential Metadata ---
  final String subject;
  final String paper;
  final int grade;
  final String topic; // Renamed from topicId
  final String cognitiveLevel;
  final int marks;
  final int year;
  final String season;

  // --- Dual Mode Support (PQP vs Sprint) ---
  final List<String>? availableInModes; // ["pqp", "sprint"]
  final PQPData? pqpData; // PQP mode specific data
  final SprintData? sprintData; // Sprint mode specific data

  // --- Option 3: Parent-Child Relationships ---
  final String? parentQuestionId; // Reference to parent question
  final bool usesParentImage; // Whether to inherit image from parent
  final Map<String, dynamic>? parentContext; // Cached parent data from backend

  // --- Question Content ---
  final String format; // Renamed from questionType
  final String questionText; // Will contain plain text and LaTeX
  final String? imageUrl; // Renamed from questionImage
  final List<String> options; // Text options (used when no option images)
  final List<String>? optionImages; // New field for option images
  final List<String>
  correctOrder; // For drag-and-drop questions (changed from int to string for step IDs)
  final String correctAnswer; // Simplified from List<String> to String
  final String explanation;
  final int? points; // Legacy field - question points
  final int? timeAllocation; // Legacy field - seconds allocated for question

  // Drag and Drop specific fields (preserved for backward compatibility)
  final List<DragItem>? dragItems; // For drag-and-drop questions
  final List<DropTarget>? dragTargets; // For drag-and-drop questions

  // Backward compatibility getters for old field names
  String get topicId => topic;
  String get questionType => format;
  String? get questionImage => imageUrl;
  List<String> get correctAnswerList => [
    correctAnswer,
  ]; // For backward compatibility

  Question({
    required this.id,
    required this.subject,
    required this.paper,
    required this.grade,
    required this.topic,
    required this.cognitiveLevel,
    required this.marks,
    required this.year,
    required this.season,
    this.availableInModes, // Dual mode support
    this.pqpData, // PQP mode specific data
    this.sprintData, // Sprint mode specific data
    this.parentQuestionId, // Option 3: Parent reference
    this.usesParentImage = false, // Option 3: Image inheritance flag
    this.parentContext, // Option 3: Cached parent data
    required this.format,
    required this.questionText,
    this.imageUrl,
    required this.options,
    this.optionImages, // Optional image URLs for options
    required this.correctOrder,
    required this.correctAnswer,
    required this.explanation,
    this.points, // Legacy field - optional points
    this.timeAllocation, // Legacy field - optional time allocation
    this.dragItems, // For drag-and-drop questions
    this.dragTargets, // For drag-and-drop questions
  });

  factory Question.fromComponents({
    required String id,
    required QuestionCoreMetadata coreMetadata,
    required QuestionContent content,
    QuestionModeData? modeData,
    ParentContextData? parentContextData,
    DragDropData? dragDropData,
  }) {
    return Question(
      id: id,
      subject: coreMetadata.subject,
      paper: coreMetadata.paper,
      grade: coreMetadata.grade,
      topic: coreMetadata.topic,
      cognitiveLevel: coreMetadata.cognitiveLevel,
      marks: coreMetadata.marks,
      year: coreMetadata.year,
      season: coreMetadata.season,
      availableInModes: modeData?.availableInModes,
      pqpData: modeData?.pqpData,
      sprintData: modeData?.sprintData,
      parentQuestionId: parentContextData?.parentQuestionId,
      usesParentImage: parentContextData?.usesParentImage ?? false,
      parentContext: parentContextData?.parentContext,
      format: content.format,
      questionText: content.questionText,
      imageUrl: content.imageUrl,
      options: content.options,
      optionImages: content.optionImages,
      correctOrder: content.correctOrder,
      correctAnswer: content.correctAnswer,
      explanation: content.explanation,
      points: content.points,
      timeAllocation: content.timeAllocation,
      dragItems: dragDropData?.dragItems,
      dragTargets: dragDropData?.dragTargets,
    );
  }

  /// Factory constructor to create Question from Cloud Function data
  factory Question.fromMap(Map<String, dynamic> data) =>
      _QuestionMapper.fromMap(data);

  factory Question.fromFirestore(DocumentSnapshot doc) =>
      _QuestionMapper.fromFirestore(doc);

  QuestionCoreMetadata get coreMetadata => QuestionCoreMetadata(
    subject: subject,
    paper: paper,
    grade: grade,
    topic: topic,
    cognitiveLevel: cognitiveLevel,
    marks: marks,
    year: year,
    season: season,
  );

  QuestionModeData get modeData => QuestionModeData(
    availableInModes: availableInModes,
    pqpData: pqpData,
    sprintData: sprintData,
  );

  ParentContextData get parentData => ParentContextData(
    parentQuestionId: parentQuestionId,
    usesParentImage: usesParentImage,
    parentContext: parentContext,
  );

  QuestionContent get content => QuestionContent(
    format: format,
    questionText: questionText,
    imageUrl: imageUrl,
    options: options,
    optionImages: optionImages,
    correctOrder: correctOrder,
    correctAnswer: correctAnswer,
    explanation: explanation,
    points: points,
    timeAllocation: timeAllocation,
  );

  DragDropData get dragDropData => DragDropData(
    format: format,
    dragItems: dragItems,
    dragTargets: dragTargets,
  );

  Map<String, dynamic> toMap() => _QuestionMapper.toMap(this);
}
