import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/services/storage_service.dart';

/// Provider for Paper Upload ViewModel
final paperUploadViewModelProvider =
    StateNotifierProvider<PaperUploadViewModel, PaperUploadState>(
      (ref) => PaperUploadViewModel(),
    );

/// State for Paper Upload Form
class PaperUploadState {
  static const Object _unset = Object();

  final String subject;
  final int grade;
  final int year;
  final String season;
  final String paperNumber;
  final String title;
  final Uint8List? selectedPdfFile;
  final String selectedFileName;
  final int selectedFileSize; // in bytes
  final String? pdfUrl;
  final bool isUploading;
  final double uploadProgress; // 0.0 to 1.0
  final String? errorMessage;
  final String? successMessage;

  const PaperUploadState({
    this.subject = 'mathematics',
    this.grade = 10,
    this.year = 2024,
    this.season = 'November',
    this.paperNumber = 'p1',
    this.title = '',
    this.selectedPdfFile,
    this.selectedFileName = '',
    this.selectedFileSize = 0,
    this.pdfUrl,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.successMessage,
  });

  PaperUploadState copyWith({
    String? subject,
    int? grade,
    int? year,
    String? season,
    String? paperNumber,
    String? title,
    Object? selectedPdfFile = _unset,
    String? selectedFileName,
    int? selectedFileSize,
    Object? pdfUrl = _unset,
    bool? isUploading,
    double? uploadProgress,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return PaperUploadState(
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      year: year ?? this.year,
      season: season ?? this.season,
      paperNumber: paperNumber ?? this.paperNumber,
      title: title ?? this.title,
      selectedPdfFile: selectedPdfFile == _unset
          ? this.selectedPdfFile
          : selectedPdfFile as Uint8List?,
      selectedFileName: selectedFileName ?? this.selectedFileName,
      selectedFileSize: selectedFileSize ?? this.selectedFileSize,
      pdfUrl: pdfUrl == _unset ? this.pdfUrl : pdfUrl as String?,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: successMessage == _unset
          ? this.successMessage
          : successMessage as String?,
    );
  }
}

/// ViewModel for Paper Upload
class PaperUploadViewModel extends StateNotifier<PaperUploadState> {
  PaperUploadViewModel() : super(const PaperUploadState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  void updateSubject(String value) {
    state = state.copyWith(subject: value);
  }

  void updateGrade(int value) {
    state = state.copyWith(grade: value);
  }

  void updateYear(int value) {
    state = state.copyWith(year: value);
  }

  void updateSeason(String value) {
    state = state.copyWith(season: value);
  }

  void updatePaperNumber(String value) {
    state = state.copyWith(paperNumber: value);
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setSelectedPdf(Uint8List? pdfBytes, String fileName, int fileSize) {
    state = state.copyWith(
      selectedPdfFile: pdfBytes,
      selectedFileName: fileName,
      selectedFileSize: fileSize,
      errorMessage: null,
    );
  }

  void clearSelectedPdf() {
    state = state.copyWith(
      selectedPdfFile: null,
      selectedFileName: '',
      selectedFileSize: 0,
    );
  }

  /// Upload paper to Firebase Storage and save metadata to Firestore
  Future<void> uploadPaper() async {
    // Validation
    if (state.subject.isEmpty) {
      state = state.copyWith(errorMessage: 'Subject is required');
      return;
    }

    if (state.title.isEmpty) {
      state = state.copyWith(errorMessage: 'Title is required');
      return;
    }

    if (state.selectedPdfFile == null) {
      state = state.copyWith(errorMessage: 'Please select a PDF file');
      return;
    }

    // Validate file size (max 10MB)
    const maxSizeBytes = 10 * 1024 * 1024; // 10MB
    if (state.selectedFileSize > maxSizeBytes) {
      state = state.copyWith(
        errorMessage: 'PDF file size must be less than 10MB',
      );
      return;
    }

    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0.0,
      errorMessage: null,
      successMessage: null,
    );

    try {
      // Generate descriptive filename
      final fileName = _generateFileName();

      debugPrint('📤 Starting PDF upload: $fileName');

      // Update progress to show upload starting
      state = state.copyWith(uploadProgress: 0.1);

      // Upload PDF to Firebase Storage
      final downloadUrl = await _storageService.uploadPDF(
        pdfBytes: state.selectedPdfFile!,
        fileName: fileName,
        folder: 'papers',
      );

      debugPrint('✅ PDF uploaded, URL: $downloadUrl');

      // Update progress to show upload complete, now saving metadata
      state = state.copyWith(uploadProgress: 0.7);

      // Save metadata to Firestore
      final user = _auth.currentUser;
      final paperData = {
        'subject': state.subject,
        'grade': state.grade,
        'year': state.year,
        'season': state.season,
        'paperNumber': state.paperNumber,
        'title': state.title,
        'pdfUrl': downloadUrl,
        'fileName': state.selectedFileName,
        'fileSize': state.selectedFileSize,
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedBy': user?.email ?? 'unknown',
        'uploadedByUid': user?.uid ?? 'unknown',
      };

      final docRef = await _firestore.collection('papers').add(paperData);

      debugPrint('✅ Paper metadata saved to Firestore: ${docRef.id}');

      state = state.copyWith(
        isUploading: false,
        uploadProgress: 1.0,
        pdfUrl: downloadUrl,
        successMessage: 'Paper uploaded successfully!',
      );

      // Reset form after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      resetForm();
    } catch (e) {
      debugPrint('❌ Error uploading paper: $e');
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 0.0,
        errorMessage: 'Failed to upload paper: ${e.toString()}',
      );
    }
  }

  /// Generate descriptive filename for the PDF
  String _generateFileName() {
    // Format: mathematics_grade10_2024_november_p1.pdf
    final subjectLower = state.subject.toLowerCase().replaceAll(' ', '_');
    final seasonLower = state.season.toLowerCase();
    return '${subjectLower}_grade${state.grade}_${state.year}_${seasonLower}_${state.paperNumber}.pdf';
  }

  /// Reset form to initial state
  void resetForm() {
    state = const PaperUploadState();
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
