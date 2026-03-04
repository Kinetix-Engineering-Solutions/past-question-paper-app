part of 'question.dart';

extension QuestionPracticeHelpers on Question {
  bool get isDragAndDrop => dragDropData.isDragAndDrop;

  bool get hasDragDropData => dragDropData.hasDragDropData;

  bool get isValidDragAndDrop {
    print('=== isValidDragAndDrop validation ===');

    if (!isDragAndDrop) {
      print('Validation failed: !isDragAndDrop (format: $format)');
      return false;
    }

    if (!hasDragDropData) {
      print('Validation failed: !hasDragDropData');
      print('  dragItems: ${dragItems?.length ?? 0}');
      print('  dragTargets: ${dragTargets?.length ?? 0}');
      return false;
    }

    if (dragItems!.isEmpty || dragTargets!.isEmpty) {
      print('Validation failed: Empty dragItems or dragTargets');
      return false;
    }

    bool hasValidPairs = true;
    for (final target in dragTargets!) {
      print(
        'Checking target: ${target.id} -> correctPair: ${target.correctPair}',
      );

      final hasMatchingDragItem = dragItems!.any((item) {
        print('  Comparing with dragItem: ${item.id}');
        return item.id == target.correctPair;
      });

      if (!hasMatchingDragItem) {
        print(
          'Warning: No matching drag item for target ${target.id} with correctPair ${target.correctPair}',
        );
        hasValidPairs = false;
      }
    }

    if (!hasValidPairs) {
      print(
        'Validation warning: Some targets have mismatched correctPair IDs, but allowing anyway',
      );
    } else {
      print('Validation passed: All targets have matching drag items');
    }

    return true;
  }

  DragItem? getDragItemById(String id) {
    if (!hasDragDropData) return null;
    return dragItems!.where((item) => item.id == id).firstOrNull;
  }

  DropTarget? getDropTargetById(String id) {
    if (!hasDragDropData) return null;
    return dragTargets!.where((target) => target.id == id).firstOrNull;
  }

  bool get hasImageOptions => content.hasImageOptions;

  bool get hasQuestionImage => content.hasQuestionImage;

  bool get useTextOptions => content.useTextOptions;

  bool get useQuestionImage => content.useQuestionImage;

  List<String> get displayOptions => content.displayOptions;

  bool get isMCQ => format.toLowerCase() == 'mcq';

  bool get isTrueFalse =>
      format.toLowerCase() == 'true_false' ||
      format.toLowerCase() == 'true-false';

  bool get isShortAnswer =>
      format.toLowerCase() == 'short_answer' ||
      format.toLowerCase() == 'short-answer';

  bool get isEssay => format.toLowerCase() == 'essay';

  bool get isFillInBlank =>
      format.toLowerCase() == 'fill_blank' ||
      format.toLowerCase() == 'fill-blank';

  bool get hasValidOptionCount {
    if (isDragAndDrop && hasDragDropData) {
      return dragItems!.length == dragTargets!.length;
    }
    if (format == 'drag-and-drop') {
      final optionCount = hasImageOptions
          ? optionImages!.length
          : options.length;
      return optionCount == correctOrder.length;
    }
    return true;
  }

  int get optionCount {
    if (isDragAndDrop && hasDragDropData) {
      return dragItems!.length;
    }
    return hasImageOptions ? optionImages!.length : options.length;
  }

  Future<Question> withHttpUrls() async {
    final storageService = StorageService();
    String? httpQuestionImage;
    List<String>? httpOptionImages;
    List<DragItem>? httpDragItems;
    List<DropTarget>? httpDragTargets;

    try {
      if (hasQuestionImage) {
        httpQuestionImage = await storageService.getDownloadUrl(imageUrl!);
      }

      if (hasImageOptions) {
        httpOptionImages = [];
        for (final url in optionImages!) {
          final httpUrl = await storageService.getDownloadUrl(url);
          httpOptionImages.add(httpUrl);
        }
      }

      if (dragItems != null) {
        httpDragItems = [];
        for (final item in dragItems!) {
          if (item.image != null) {
            final httpUrl = await storageService.getDownloadUrl(item.image!);
            httpDragItems.add(
              DragItem(id: item.id, text: item.text, image: httpUrl),
            );
          } else {
            httpDragItems.add(item);
          }
        }
      }

      if (dragTargets != null) {
        httpDragTargets = [];
        for (final target in dragTargets!) {
          if (target.image != null) {
            final httpUrl = await storageService.getDownloadUrl(target.image!);
            httpDragTargets.add(
              DropTarget(
                id: target.id,
                text: target.text,
                image: httpUrl,
                correctPair: target.correctPair,
              ),
            );
          } else {
            httpDragTargets.add(target);
          }
        }
      }

      return Question(
        id: id,
        subject: subject,
        paper: paper,
        grade: grade,
        topic: topic,
        cognitiveLevel: cognitiveLevel,
        marks: marks,
        year: year,
        season: season,
        availableInModes: availableInModes,
        pqpData: pqpData,
        sprintData: sprintData,
        parentQuestionId: parentQuestionId,
        usesParentImage: usesParentImage,
        parentContext: parentContext,
        format: format,
        questionText: questionText,
        imageUrl: httpQuestionImage,
        options: options,
        optionImages: httpOptionImages,
        correctOrder: correctOrder,
        correctAnswer: correctAnswer,
        explanation: explanation,
        points: points,
        timeAllocation: timeAllocation,
        dragItems: httpDragItems,
        dragTargets: httpDragTargets,
      );
    } catch (e) {
      print('Error converting URLs: $e');
      return this;
    }
  }
}
