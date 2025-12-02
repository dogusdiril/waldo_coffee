import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/task_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../shared/task_card.dart';
import 'create_task_dialog.dart';
import 'employee_stats_screen.dart';
import 'pending_approvals_screen.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  TaskPriority? _filterPriority;
  TaskStatus? _filterStatus;

  Future<void> _handleRefresh() async {
    ref.read(taskNotifierProvider.notifier).refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(allTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waldo Coffee Admin 👑'),
        actions: [
          // Onay bekleyenler
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PendingApprovalsScreen(),
                ),
              );
            },
            tooltip: 'Onay Bekleyenler',
          ),
          // Çalışan istatistikleri
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmployeeStatsScreen(),
                ),
              );
            },
            tooltip: 'Çalışan İstatistikleri',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
            tooltip: 'Çıkış',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          allTasks.when(
            data: (tasks) => _buildStatsBar(tasks),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Filters
          _buildFilterBar(),

          // Task list
          Expanded(
            child: allTasks.when(
              data: (tasks) {
                final filteredTasks = _filterTasks(tasks);
                return _buildTaskList(filteredTasks);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Görev'),
      ),
    );
  }

  Widget _buildStatsBar(List<TaskModel> tasks) {
    final pending = tasks.where((t) => t.isPending).length;
    final inProgress = tasks.where((t) => t.isInProgress).length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final urgent = tasks.where((t) => t.isUrgent && !t.isCompleted).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.secondaryColor.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Bekleyen', pending, AppTheme.warningColor),
          _buildStatItem('Yapılıyor', inProgress, AppTheme.primaryColor),
          _buildStatItem('Tamamlanan', completed, AppTheme.successColor),
          _buildStatItem('Acil 🚨', urgent, AppTheme.urgentColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Filtrele:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          
          // Priority filter
          DropdownButton<TaskPriority?>(
            value: _filterPriority,
            hint: const Text('Öncelik'),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tümü')),
              ...TaskPriority.values.map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.label),
              )),
            ],
            onChanged: (value) => setState(() => _filterPriority = value),
          ),
          const SizedBox(width: 12),

          // Status filter
          DropdownButton<TaskStatus?>(
            value: _filterStatus,
            hint: const Text('Durum'),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tümü')),
              ...TaskStatus.values.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.label),
              )),
            ],
            onChanged: (value) => setState(() => _filterStatus = value),
          ),

          const Spacer(),

          // Clear filters
          if (_filterPriority != null || _filterStatus != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _filterPriority = null;
                  _filterStatus = null;
                });
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Temizle'),
            ),
        ],
      ),
    );
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    return tasks.where((task) {
      if (_filterPriority != null && task.priority != _filterPriority) {
        return false;
      }
      if (_filterStatus != null && task.status != _filterStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Görev bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showCreateTaskDialog(),
              icon: const Icon(Icons.add),
              label: const Text('İlk Görevi Ekle'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            isEmployee: false,
            onDeleteTask: () => _deleteTask(task),
          );
        },
      ),
    );
  }

  Future<void> _showCreateTaskDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const CreateTaskDialog(),
    );
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text('${task.title} görevini silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görev silindi'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}

