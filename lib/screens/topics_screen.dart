import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/screens/questions_screen.dart';
import 'package:past_question_paper_stem/services/firestore_service.dart';

class TopicsScreen extends StatefulWidget {
  final String subjectId;
  final String examTypeId;

  const TopicsScreen({
    super.key,
    required this.subjectId,
    required this.examTypeId,
  });

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<String> _topics = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final topics = await _firestoreService.getTopics(
        widget.subjectId,
        widget.examTypeId,
      );

      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load topics: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examTypeId} - Topics'),
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
            ElevatedButton(onPressed: _loadTopics, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_topics.isEmpty) {
      return const Center(
        child: Text(
          'No topics available for this exam type.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              _topics[index],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => QuestionsScreen(
                        subjectId: widget.subjectId,
                        examTypeId: widget.examTypeId,
                        topicId: _topics[index],
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
