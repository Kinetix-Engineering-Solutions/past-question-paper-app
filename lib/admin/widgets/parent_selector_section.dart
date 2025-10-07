import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Parent Selector Section - Select parent question for child questions
class ParentSelectorSection extends ConsumerStatefulWidget {
  const ParentSelectorSection({super.key});

  @override
  ConsumerState<ParentSelectorSection> createState() => _ParentSelectorSectionState();
}

class _ParentSelectorSectionState extends ConsumerState<ParentSelectorSection> {
  List<Map<String, dynamic>> _parentQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParentQuestions();
  }

  Future<void> _loadParentQuestions() async {
    setState(() => _isLoading = true);
    
    try {
      // Query without orderBy to avoid composite index requirement
      final snapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where('isParent', isEqualTo: true)
          .get();

      // Map and sort in memory
      final parentsList = snapshot.docs.map((doc) {
        final data = doc.data();
        String displayText = doc.id.substring(0, 8);
        
        // Try to get PQP number
        if (data['pqpData'] != null && data['pqpData'] is Map) {
          final pqpData = data['pqpData'] as Map<String, dynamic>;
          final pqpNumber = pqpData['questionNumber'];
          if (pqpNumber != null) {
            displayText = pqpNumber.toString();
          }
        }
        
        // Add subject and topic for context
        final subject = data['subject'] ?? '';
        final topic = data['topic'] ?? '';
        
        return {
          'id': doc.id,
          'displayText': '$displayText - $subject - $topic',
          'pqpNumber': displayText,
          'subject': subject,
          'topic': topic,
        };
      }).toList();
      
      // Sort by PQP number in memory (avoids Firestore composite index)
      parentsList.sort((a, b) {
        final aNumber = a['pqpNumber'] as String? ?? '';
        final bNumber = b['pqpNumber'] as String? ?? '';
        return aNumber.compareTo(bNumber);
      });

      setState(() {
        _parentQuestions = parentsList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading parent questions: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle checkbox
        CheckboxListTile(
          title: const Text(
            'This is a child question (part of a parent question)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Child questions share context (text, images) from a parent question',
            style: TextStyle(fontSize: 12),
          ),
          value: state.isChildQuestion,
          onChanged: (value) => notifier.toggleChildQuestionMode(),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),

        // Parent selection (shown when child mode is enabled)
        if (state.isChildQuestion) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Parent selector
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _parentQuestions.isEmpty
                  ? _buildNoParentsMessage()
                  : _buildParentDropdown(state, notifier),

          // Parent context preview (shown when parent is selected)
          if (state.parentQuestionId != null) ...[
            const SizedBox(height: 16),
            _buildParentPreview(state),
            
            const SizedBox(height: 16),
            
            // Use parent image checkbox
            if (state.parentImageUrl != null && state.parentImageUrl!.isNotEmpty)
              CheckboxListTile(
                title: const Text('Use parent\'s image'),
                subtitle: const Text(
                  'Check this to display the parent\'s image with this child question',
                  style: TextStyle(fontSize: 12),
                ),
                value: state.usesParentImage,
                onChanged: (value) => notifier.toggleUsesParentImage(),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            
            // Suggested PQP number
            if (state.suggestedPQPNumber != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Suggested PQP Number: ${state.suggestedPQPNumber}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          
          const SizedBox(height: 16),
          const Divider(),
        ],
      ],
    );
  }

  Widget _buildParentDropdown(QuestionCreateState state, QuestionCreateViewModel notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Parent Question:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: state.parentQuestionId,
          decoration: InputDecoration(
            labelText: 'Parent Question',
            hintText: 'Choose a parent question...',
            suffixIcon: state.parentQuestionId != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => notifier.clearParent(),
                  )
                : null,
          ),
          items: _parentQuestions.map((parent) {
            return DropdownMenuItem<String>(
              value: parent['id'],
              child: Text(
                parent['displayText'],
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              notifier.selectParent(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNoParentsMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Parent Questions Found',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a parent question first before creating child questions.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentPreview(QuestionCreateState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Parent Context Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Parent context text
          if (state.parentContextText != null && state.parentContextText!.isNotEmpty) ...[
            Text(
              state.parentContextText!,
              style: TextStyle(
                color: AppColors.neutralMid,
                fontSize: 13,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          
          // Parent image
          if (state.parentImageUrl != null && state.parentImageUrl!.isNotEmpty) ...[
            const Text(
              'Parent Image:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                state.parentImageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  alignment: Alignment.center,
                  color: AppColors.neutralSoft,
                  child: const Text('Failed to load image'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
