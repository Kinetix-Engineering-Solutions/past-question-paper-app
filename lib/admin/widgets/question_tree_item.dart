import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/admin/viewmodels/parent_child_browser_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Tree item widget for displaying parent and child questions
class QuestionTreeItem extends StatelessWidget {
  final ParentQuestionNode question;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;
  final VoidCallback onDeleteParent;
  final Function(String childId) onDeleteChild;
  final VoidCallback? onEditParent;
  final Function(String childId)? onEditChild;

  const QuestionTreeItem({
    super.key,
    required this.question,
    required this.isExpanded,
    required this.onToggleExpansion,
    required this.onDeleteParent,
    required this.onDeleteChild,
    this.onEditParent,
    this.onEditChild,
  });

  @override
  Widget build(BuildContext context) {
    final isParent = question.hasChildren;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isParent
              ? AppColors.accent.withOpacity(0.3)
              : Colors.grey.shade300,
          width: isParent ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Parent Question Row
          InkWell(
            onTap: isParent ? onToggleExpansion : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Expand/Collapse Icon (only for parents)
                  if (isParent)
                    Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      color: AppColors.accent,
                    )
                  else
                    const SizedBox(width: 24),

                  const SizedBox(width: 12),

                  // Type Icon
                  Icon(
                    isParent ? Icons.folder : Icons.note,
                    color: isParent ? AppColors.accent : Colors.grey.shade600,
                    size: 20,
                  ),

                  const SizedBox(width: 12),

                  // Question Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PQP Number and Type Badge
                        Row(
                          children: [
                            Text(
                              question.pqpNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildTypeBadge(isParent),
                            if (isParent && question.children.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${question.children.length} child${question.children.length == 1 ? '' : 'ren'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Subject and Topic
                        Text(
                          '${question.subject} • ${question.topic}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        if (isParent && question.contextText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            question.contextText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button (placeholder for future)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: Colors.blue.shade700,
                        tooltip: 'Edit',
                        onPressed:
                            onEditParent ??
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Edit feature coming soon'),
                                ),
                              );
                            },
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red.shade700,
                        tooltip: 'Delete',
                        onPressed: onDeleteParent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Children List (if expanded)
          if (isParent && isExpanded && question.children.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: question.children.map((child) {
                  return _buildChildItem(context, child);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(bool isParent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isParent
            ? AppColors.accent.withOpacity(0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isParent ? 'PARENT' : 'STANDALONE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isParent ? AppColors.accent : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildChildItem(BuildContext context, ChildQuestionNode child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Indent
          const SizedBox(width: 48),

          // Child Icon
          Icon(Icons.description, color: Colors.grey.shade600, size: 18),

          const SizedBox(width: 12),

          // Child Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PQP Number and Format
                Row(
                  children: [
                    Text(
                      child.pqpNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        child.format.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${child.marks} mark${child.marks == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Question Text
                Text(
                  child.questionText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Child Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: Colors.blue.shade700,
                tooltip: 'Edit',
                onPressed: onEditChild != null
                    ? () => onEditChild!(child.id)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit feature coming soon'),
                          ),
                        );
                      },
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                color: Colors.red.shade700,
                tooltip: 'Delete',
                onPressed: () => onDeleteChild(child.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
