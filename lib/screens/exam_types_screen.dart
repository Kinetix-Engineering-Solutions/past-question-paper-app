import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/screens/topics_screen.dart';
import 'package:past_question_paper_stem/services/firestore_service.dart';

class ExamTypesScreen extends StatefulWidget {
  final String subjectId;

  const ExamTypesScreen({super.key, required this.subjectId});

  @override
  State<ExamTypesScreen> createState() => _ExamTypesScreenState();
}

class _ExamTypesScreenState extends State<ExamTypesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<String> _examTypes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExamTypes();
  }

  Future<void> _loadExamTypes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final examTypes = await _firestoreService.getExamTypes(widget.subjectId);

      setState(() {
        _examTypes = examTypes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load exam types: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectId} - Exam Types'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadExamTypes,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_examTypes.isEmpty) {
      return const Center(
        child: Text(
          'No exam types available for this subject.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: _examTypes.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              _examTypes[index],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TopicsScreen(
                        subjectId: widget.subjectId,
                        examTypeId: _examTypes[index],
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
