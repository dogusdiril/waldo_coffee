import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../constants/app_constants.dart';
import 'auth_provider.dart';

// All tasks provider (for admin)
final allTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getAllTasks();
});

// Available tasks provider (for employees)
final availableTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final user = ref.watch(authNotifierProvider).valueOrNull;
  
  if (user == null) return [];
  return await supabaseService.getAvailableTasks(user.id);
});

// My tasks provider
final myTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final user = ref.watch(authNotifierProvider).valueOrNull;
  
  if (user == null) return [];
  return await supabaseService.getMyTasks(user.id);
});

// All employees provider
final allEmployeesProvider = FutureProvider<List<UserModel>>((ref) async {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return await supabaseService.getAllEmployees();
});

// Task actions notifier
class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseService _supabaseService;
  final Ref _ref;

  TaskNotifier(this._supabaseService, this._ref) : super(const AsyncValue.data(null));

  Future<void> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required bool isRecurring,
    DateTime? dueDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authNotifierProvider).valueOrNull;
      if (user == null) throw Exception('Kullanıcı bulunamadı');

      await _supabaseService.createTask(
        title: title,
        description: description,
        priority: priority,
        isRecurring: isRecurring,
        createdBy: user.id,
        dueDate: dueDate,
      );

      // Refresh task lists
      _ref.invalidate(allTasksProvider);
      _ref.invalidate(availableTasksProvider);
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> assignTaskToMe(String taskId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authNotifierProvider).valueOrNull;
      if (user == null) throw Exception('Kullanıcı bulunamadı');

      await _supabaseService.assignTask(taskId, user.id);

      // Refresh task lists
      _ref.invalidate(allTasksProvider);
      _ref.invalidate(availableTasksProvider);
      _ref.invalidate(myTasksProvider);
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> unassignTask(String taskId) async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.unassignTask(taskId);

      // Refresh task lists
      _ref.invalidate(allTasksProvider);
      _ref.invalidate(availableTasksProvider);
      _ref.invalidate(myTasksProvider);
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> completeTask(String taskId) async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.completeTask(taskId);

      // Refresh task lists
      _ref.invalidate(allTasksProvider);
      _ref.invalidate(availableTasksProvider);
      _ref.invalidate(myTasksProvider);
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.deleteTask(taskId);

      // Refresh task lists
      _ref.invalidate(allTasksProvider);
      _ref.invalidate(availableTasksProvider);
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  void refreshTasks() {
    _ref.invalidate(allTasksProvider);
    _ref.invalidate(availableTasksProvider);
    _ref.invalidate(myTasksProvider);
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<void>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return TaskNotifier(supabaseService, ref);
});

