import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/task_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isEmployee;
  final VoidCallback? onTakeTask;
  final VoidCallback? onCompleteTask;
  final VoidCallback? onDropTask;
  final VoidCallback? onDeleteTask;

  const TaskCard({
    super.key,
    required this.task,
    required this.isEmployee,
    this.onTakeTask,
    this.onCompleteTask,
    this.onDropTask,
    this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: task.isUrgent
              ? Border.all(color: AppTheme.urgentColor, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Priority indicator
                  _buildPriorityBadge(),
                  const SizedBox(width: 8),
                  
                  // Status badge
                  _buildStatusBadge(),
                  
                  const Spacer(),
                  
                  // Recurring indicator
                  if (task.isRecurring)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.repeat, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Günlük',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted
                      ? AppTheme.textLight
                      : AppTheme.textPrimary,
                ),
              ),

              // Description
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Footer row
              Row(
                children: [
                  // Assigned to (for admin view)
                  if (!isEmployee && task.isAssigned) ...[
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedToName ?? 'Bilinmiyor',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Time
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(task.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const Spacer(),

                  // Action buttons
                  ..._buildActionButtons(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    String label;
    IconData icon;

    switch (task.priority) {
      case TaskPriority.critical:
        color = AppTheme.urgentColor;
        label = 'Kritik';
        icon = Icons.warning_rounded;
        break;
      case TaskPriority.urgent:
        color = AppTheme.warningColor;
        label = 'Acil';
        icon = Icons.priority_high;
        break;
      case TaskPriority.normal:
      default:
        color = AppTheme.primaryColor;
        label = 'Normal';
        icon = Icons.flag_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    IconData icon;

    switch (task.status) {
      case TaskStatus.completed:
        color = AppTheme.successColor;
        label = 'Tamamlandı';
        icon = Icons.check_circle;
        break;
      case TaskStatus.inProgress:
        color = AppTheme.primaryColor;
        label = 'Yapılıyor';
        icon = Icons.play_circle;
        break;
      case TaskStatus.pending:
      default:
        color = AppTheme.warningColor;
        label = 'Bekliyor';
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    final buttons = <Widget>[];

    if (onTakeTask != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onTakeTask,
          icon: const Icon(Icons.front_hand, size: 18),
          label: const Text('Alıyorum'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (onCompleteTask != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onCompleteTask,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Tamamla'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (onDropTask != null) {
      buttons.add(
        const SizedBox(width: 8),
      );
      buttons.add(
        OutlinedButton.icon(
          onPressed: onDropTask,
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Bırak'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.errorColor,
            side: const BorderSide(color: AppTheme.errorColor),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (onDeleteTask != null) {
      buttons.add(
        IconButton(
          onPressed: onDeleteTask,
          icon: const Icon(Icons.delete_outline),
          color: AppTheme.errorColor,
          tooltip: 'Sil',
        ),
      );
    }

    return buttons;
  }
}

