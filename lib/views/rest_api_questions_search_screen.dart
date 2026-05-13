import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/core/shared/models/rest_api_question.dart';
import 'package:past_question_paper_v1/core/shared/services/rest_questions_api_service.dart';

class RestApiQuestionsSearchScreen extends StatefulWidget {
  const RestApiQuestionsSearchScreen({super.key});

  @override
  State<RestApiQuestionsSearchScreen> createState() =>
      _RestApiQuestionsSearchScreenState();
}

class _RestApiQuestionsSearchScreenState
    extends State<RestApiQuestionsSearchScreen> {
  final RestQuestionsApiService _api = RestQuestionsApiService();

  final _subjectController = TextEditingController(text: 'mathematics');
  final _topicController = TextEditingController(
    text: 'Algebra, Equations, and Inequalities',
  );
  int _grade = 12;

  Future<List<RestApiQuestion>>? _future;

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  void _search() {
    final subject = _subjectController.text.trim();
    final topic = _topicController.text.trim();

    setState(() {
      _future = _api.fetchQuestions(
        subject: subject,
        grade: _grade,
        topic: topic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REST API Questions')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            hintText: 'math',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<int>(
                          value: _grade,
                          items: const [
                            DropdownMenuItem(value: 10, child: Text('10')),
                            DropdownMenuItem(value: 11, child: Text('11')),
                            DropdownMenuItem(value: 12, child: Text('12')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _grade = value);
                          },
                          decoration: const InputDecoration(labelText: 'Grade'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _topicController,
                          decoration: const InputDecoration(
                            labelText: 'Topic',
                            hintText: 'calculus',
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _future == null
                  ? const Center(child: Text('Enter filters and press Search.'))
                  : FutureBuilder<List<RestApiQuestion>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: SingleChildScrollView(
                              child: Text(snapshot.error.toString()),
                            ),
                          );
                        }

                        final results =
                            snapshot.data ?? const <RestApiQuestion>[];
                        if (results.isEmpty) {
                          return const Center(child: Text('No results.'));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final q = results[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID: ${q.id}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 6,
                                      children: [
                                        Text('Subject: ${q.subjectId}'),
                                        Text('Grade: ${q.grade}'),
                                        Text('Topic: ${q.topic}'),
                                        if (q.year != null)
                                          Text('Year: ${q.year}'),
                                        if ((q.season ?? '').isNotEmpty)
                                          Text('Season: ${q.season}'),
                                        if ((q.paper ?? '').isNotEmpty)
                                          Text('Paper: ${q.paper}'),
                                        if ((q.questionNumber ?? '').isNotEmpty)
                                          Text('Q#: ${q.questionNumber}'),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (q.imageUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          q.imageUrl!,
                                          fit: BoxFit.fitWidth,
                                          errorBuilder: (context, error, stack) {
                                            return const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                'Failed to load question image.',
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (q.answerImageUrl != null) ...[
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          q.answerImageUrl!,
                                          fit: BoxFit.fitWidth,
                                          errorBuilder: (context, error, stack) {
                                            return const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                'Failed to load answer image.',
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
