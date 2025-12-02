import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/task_model.dart';
import '../../core/theme/app_theme.dart';

class EmployeeStatsScreen extends ConsumerStatefulWidget {
  const EmployeeStatsScreen({super.key});

  @override
  ConsumerState<EmployeeStatsScreen> createState() => _EmployeeStatsScreenState();
}

class _EmployeeStatsScreenState extends ConsumerState<EmployeeStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa açılınca refresh et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(allEmployeesProvider);
      ref.invalidate(allTasksProvider);
    });
  }

  void _handleRefresh() {
    ref.invalidate(allEmployeesProvider);
    ref.invalidate(allTasksProvider);
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(allEmployeesProvider);
    final allTasks = ref.watch(allTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışan İstatistikleri 📊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _handleRefresh();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: employees.when(
          data: (employeeList) => allTasks.when(
            data: (tasks) => _buildEmployeeList(employeeList, tasks),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(List<UserModel> employees, List<TaskModel> tasks) {
    if (employees.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textLight),
            SizedBox(height: 16),
            Text('Henüz çalışan yok'),
          ],
        ),
      );
    }

    // Sadece employee rolündeki kullanıcıları filtrele
    final employeesOnly = employees.where((e) => e.isEmployee).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employeesOnly.length,
      itemBuilder: (context, index) {
        final employee = employeesOnly[index];
        return _EmployeeStatCard(employee: employee, allTasks: tasks);
      },
    );
  }
}

class _EmployeeStatCard extends StatelessWidget {
  final UserModel employee;
  final List<TaskModel> allTasks;

  const _EmployeeStatCard({
    required this.employee,
    required this.allTasks,
  });

  @override
  Widget build(BuildContext context) {
    // Bu çalışana atanan görevleri filtrele
    final myTasks = allTasks.where((t) => t.assignedTo == employee.id).toList();
    final completed = myTasks.where((t) => t.isCompleted).length;
    final inProgress = myTasks.where((t) => t.isInProgress).length;
    final total = myTasks.length;
    
    // Tamamlanma yüzdesi
    final completionRate = total > 0 ? (completed / total * 100).round() : 0;
    
    // Performans rengi
    Color performanceColor;
    String performanceEmoji;
    if (completionRate >= 80) {
      performanceColor = AppTheme.successColor;
      performanceEmoji = '🔥';
    } else if (completionRate >= 50) {
      performanceColor = AppTheme.warningColor;
      performanceEmoji = '💪';
    } else if (total == 0) {
      performanceColor = AppTheme.textLight;
      performanceEmoji = '😴';
    } else {
      performanceColor = AppTheme.errorColor;
      performanceEmoji = '📈';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 24,
                  child: Text(
                    employee.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            employee.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(performanceEmoji, style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                      Text(
                        employee.email,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tamamlanma yüzdesi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: performanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: performanceColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '%$completionRate',
                    style: TextStyle(
                      color: performanceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Toplam', total, AppTheme.primaryColor),
                _buildStatColumn('Tamamlanan', completed, AppTheme.successColor),
                _buildStatColumn('Devam Eden', inProgress, AppTheme.warningColor),
              ],
            ),
            
            // Progress bar
            if (total > 0) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completed / total,
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(performanceColor),
                  minHeight: 8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
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
}

