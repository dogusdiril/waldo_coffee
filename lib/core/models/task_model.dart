import '../constants/app_constants.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final bool isRecurring;
  final String? assignedTo; // user id
  final String? assignedToName; // user full name (for display)
  final TaskStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.isRecurring,
    this.assignedTo,
    this.assignedToName,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: TaskPriority.values.firstWhere(
        (p) => p.value == json['priority'],
        orElse: () => TaskPriority.normal,
      ),
      isRecurring: json['is_recurring'] as bool? ?? false,
      assignedTo: json['assigned_to'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
      status: TaskStatus.values.firstWhere(
        (s) => s.value == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.value,
      'is_recurring': isRecurring,
      'assigned_to': assignedTo,
      'status': status.value,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
    };
  }

  bool get isUrgent => priority == TaskPriority.urgent || priority == TaskPriority.critical;
  bool get isAssigned => assignedTo != null;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isPending => status == TaskStatus.pending;
  bool get isInProgress => status == TaskStatus.inProgress;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    bool? isRecurring,
    String? assignedTo,
    String? assignedToName,
    TaskStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

