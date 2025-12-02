import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/task_model.dart';
import '../../core/theme/app_theme.dart';
import '../shared/task_card.dart';

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    ref.read(taskNotifierProvider.notifier).refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final availableTasks = ref.watch(availableTasksProvider);
    final myTasks = ref.watch(myTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waldo Coffee ☕'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'Görevler',
            ),
            Tab(
              icon: Icon(Icons.person),
              text: 'Benim İşlerim',
            ),
          ],
        ),
        actions: [
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
          // User info bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.secondaryColor.withOpacity(0.2),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba, ${user?.fullName ?? 'Kullanıcı'}!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Bugün neler yapacaksın? 💪',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Available tasks tab
                availableTasks.when(
                  data: (tasks) => _buildTaskList(
                    tasks,
                    emptyMessage: 'Şu an bekleyen görev yok 🎉',
                    isAvailableList: true,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                ),

                // My tasks tab
                myTasks.when(
                  data: (tasks) => _buildTaskList(
                    tasks,
                    emptyMessage: 'Henüz görev almadın',
                    isAvailableList: false,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    List<TaskModel> tasks, {
    required String emptyMessage,
    required bool isAvailableList,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAvailableList ? Icons.check_circle_outline : Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
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
            isEmployee: true,
            onTakeTask: isAvailableList && !task.isAssigned
                ? () => _takeTask(task)
                : null,
            onCompleteTask: !isAvailableList && task.isInProgress
                ? () => _completeTask(task)
                : null,
            onDropTask: !isAvailableList && !task.isCompleted
                ? () => _dropTask(task)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _takeTask(TaskModel task) async {
    try {
      await ref.read(taskNotifierProvider.notifier).assignTaskToMe(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} görevi alındı! 💪'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _tabController.animateTo(1); // Switch to "My Tasks" tab
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

  Future<void> _completeTask(TaskModel task) async {
    try {
      await ref.read(taskNotifierProvider.notifier).completeTask(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} tamamlandı! ✅'),
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

  Future<void> _dropTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Bırak'),
        content: Text('${task.title} görevini bırakmak istediğine emin misin?'),
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
            child: const Text('Bırak'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(taskNotifierProvider.notifier).unassignTask(task.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görev bırakıldı'),
              backgroundColor: AppTheme.warningColor,
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

