part of 'question.dart';

class _QuestionMapper {
  static Question fromMap(Map<String, dynamic> data) {
    final coreMetadata = QuestionCoreMetadata(
      subject: data['subject']?.toString() ?? '',
      paper: data['paper']?.toString() ?? '',
      grade: (data['grade'] as num?)?.toInt() ?? 12,
      topic: data['topic']?.toString() ?? '',
      cognitiveLevel: data['cognitiveLevel']?.toString() ?? '',
      marks: (data['marks'] as num?)?.toInt() ?? 0,
      year: (data['year'] as num?)?.toInt() ?? 0,
      season: data['season']?.toString() ?? '',
    );

    final content = QuestionContent(
      format: data['format']?.toString() ?? 'MCQ',
      questionText: data['questionText']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString(),
      options: List<String>.from(data['options'] ?? []),
      optionImages: data['optionImages'] != null
          ? List<String>.from(data['optionImages'])
          : null,
      correctOrder: List<String>.from(data['correctOrder'] ?? []),
      correctAnswer: _extractCorrectAnswer(data),
      explanation: data['explanation'] ?? '',
      points: data['points'],
      timeAllocation: data['timeAllocation'],
    );

    final modeData = QuestionModeData(
      availableInModes: data['availableInModes'] != null
          ? List<String>.from(data['availableInModes'])
          : null,
      pqpData: data['pqpData'] != null
          ? PQPData.fromMap(safeMapCast(data['pqpData']))
          : null,
      sprintData: data['sprintData'] != null
          ? SprintData.fromMap(safeMapCast(data['sprintData']))
          : null,
    );

    final parentData = ParentContextData(
      parentQuestionId: data['parentQuestionId']?.toString(),
      usesParentImage: data['usesParentImage'] as bool? ?? false,
      parentContext: data['parentContext'] != null
          ? safeMapCast(data['parentContext'])
          : null,
    );

    final dragDropData = DragDropData(
      format: content.format,
      dragItems: data['dragItems'] != null
          ? (data['dragItems'] as List<dynamic>)
                .map((item) => DragItem.fromDynamic(item))
                .toList()
          : null,
      dragTargets: (data['dragTargets'] ?? data['dropTargets']) != null
          ? ((data['dragTargets'] ?? data['dropTargets']) as List<dynamic>)
                .map((target) => DropTarget.fromDynamic(target))
                .toList()
          : null,
    );

    return Question.fromComponents(
      id: data['id']?.toString() ?? '',
      coreMetadata: coreMetadata,
      content: content,
      modeData: modeData,
      parentContextData: parentData,
      dragDropData: dragDropData,
    );
  }

  static Question fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final hasImageBasedOptions =
        data['optionImages'] != null &&
        (data['optionImages'] as List).isNotEmpty;

    final topicValue = data['topic'] ?? data['topicId'] ?? '';
    final formatValue = data['format'] ?? data['questionType'] ?? 'MCQ';
    final String? imageUrlValue = data['imageUrl'] ?? data['questionImage'];

    final coreMetadata = QuestionCoreMetadata(
      subject: data['subject']?.toString() ?? '',
      paper: data['paper']?.toString() ?? '',
      grade: (data['grade'] as num?)?.toInt() ?? 12,
      topic: topicValue,
      cognitiveLevel: data['cognitiveLevel']?.toString() ?? '',
      marks: (data['marks'] as num?)?.toInt() ?? 0,
      year: (data['year'] as num?)?.toInt() ?? 0,
      season: data['season']?.toString() ?? '',
    );

    final content = QuestionContent(
      format: formatValue,
      questionText: data['questionText'] ?? '',
      imageUrl: imageUrlValue,
      options: hasImageBasedOptions
          ? <String>[]
          : List<String>.from(data['options'] ?? []),
      optionImages: hasImageBasedOptions
          ? List<String>.from(data['optionImages'])
          : null,
      correctOrder: List<String>.from(data['correctOrder'] ?? []),
      correctAnswer: _extractCorrectAnswer(data),
      explanation: data['explanation'] ?? '',
      points: data['points'],
      timeAllocation: data['timeAllocation'],
    );

    final parentData = ParentContextData(
      parentQuestionId: data['parentQuestionId']?.toString(),
      usesParentImage: data['usesParentImage'] as bool? ?? false,
      parentContext: data['parentContext'] != null
          ? safeMapCast(data['parentContext'])
          : null,
    );

    final dragDropData = DragDropData(
      format: content.format,
      dragItems: data['dragItems'] != null
          ? (data['dragItems'] as List<dynamic>)
                .map((item) => DragItem.fromDynamic(item))
                .toList()
          : null,
      dragTargets: (data['dragTargets'] ?? data['dropTargets']) != null
          ? ((data['dragTargets'] ?? data['dropTargets']) as List<dynamic>)
                .map((target) => DropTarget.fromDynamic(target))
                .toList()
          : null,
    );

    return Question.fromComponents(
      id: doc.id,
      coreMetadata: coreMetadata,
      content: content,
      parentContextData: parentData,
      dragDropData: dragDropData,
    );
  }

  static Map<String, dynamic> toMap(Question question) {
    final map = <String, dynamic>{
      'subject': question.subject,
      'paper': question.paper,
      'grade': question.grade,
      'topic': question.topic,
      'cognitiveLevel': question.cognitiveLevel,
      'marks': question.marks,
      'year': question.year,
      'season': question.season,
      'format': question.format,
      'questionText': question.questionText,
      'correctOrder': question.correctOrder,
      'correctAnswer': question.correctAnswer,
      'explanation': question.explanation,
    };

    if (question.imageUrl != null) {
      map['imageUrl'] = question.imageUrl;
    }

    if (question.points != null) {
      map['points'] = question.points;
    }

    if (question.timeAllocation != null) {
      map['timeAllocation'] = question.timeAllocation;
    }

    if (question.dragItems != null && question.dragItems!.isNotEmpty) {
      map['dragItems'] = question.dragItems!
          .map(
            (item) => {'id': item.id, 'text': item.text, 'image': item.image},
          )
          .toList();
    }

    if (question.dragTargets != null && question.dragTargets!.isNotEmpty) {
      map['dragTargets'] = question.dragTargets!
          .map(
            (target) => {
              'id': target.id,
              'text': target.text,
              'image': target.image,
              'correctPair': target.correctPair,
            },
          )
          .toList();
    }

    if (question.optionImages != null && question.optionImages!.isNotEmpty) {
      map['optionImages'] = question.optionImages;
    } else {
      map['options'] = question.options;
    }

    if (question.pqpData != null) {
      map['pqpData'] = {
        'paper': question.pqpData!.paper,
        'season': question.pqpData!.season,
        'year': question.pqpData!.year,
        'questionNumber': question.pqpData!.questionNumber,
        'questionText': question.pqpData!.questionText,
        'marks': question.pqpData!.marks,
      };
    }

    if (question.sprintData != null) {
      map['sprintData'] = {
        'questionText': question.sprintData!.questionText,
        'providedContext': question.sprintData!.providedContext,
        'marks': question.sprintData!.marks,
        'canRandomize': question.sprintData!.canRandomize,
        'difficulty': question.sprintData!.difficulty,
        'estimatedTime': question.sprintData!.estimatedTime,
        'tags': question.sprintData!.tags,
      };
    }

    if (question.parentContext != null) {
      map['parentContext'] = question.parentContext;
    }

    return map;
  }

  static String _extractCorrectAnswer(Map<String, dynamic> data) {
    if (data['correctAnswer'] == null) {
      return '';
    }

    if (data['correctAnswer'] is List) {
      final answerList = List<String>.from(data['correctAnswer']);
      return answerList.isNotEmpty ? answerList.first : '';
    }

    return data['correctAnswer'].toString();
  }
}
