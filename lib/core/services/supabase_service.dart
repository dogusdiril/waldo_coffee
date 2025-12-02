import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  // ==================== AUTH ====================

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Sign up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.employee,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      // Create profile
      await client.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'role': role.value,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return response;
  }

  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  // Create profile (if not exists after login)
  Future<void> createProfile({
    required String userId,
    required String email,
    required String fullName,
    String phone = '',
    UserRole role = UserRole.employee,
  }) async {
    await client.from('profiles').insert({
      'id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.value,
      'is_approved': true, // Login'den geliyorsa zaten onaylı
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Sign up with approval (yeni kayıtlar onay bekler)
  Future<void> signUpWithApproval({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    // 1. Auth'a kayıt et (trigger profili oluşturacak)
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'is_approved': false,
      },
    );

    if (response.user != null) {
      // 2. Trigger oluşturdu ama emin olmak için güncelle
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        await client.from('profiles').upsert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'role': UserRole.employee.value,
          'is_approved': false, // Admin onayı bekliyor
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('⚠️ Profile upsert error (normal olabilir): $e');
      }

      // 3. Hemen çıkış yap (onay bekleyecek)
      await client.auth.signOut();
    }
  }

  // Onay bekleyen kullanıcıları getir (admin için)
  Future<List<UserModel>> getPendingApprovals() async {
    final response = await client
        .from('profiles')
        .select()
        .eq('is_approved', false)
        .order('created_at', ascending: false);

    return (response as List).map((user) => UserModel.fromJson(user)).toList();
  }

  // Kullanıcıyı onayla
  Future<void> approveUser(String userId) async {
    await client.from('profiles').update({
      'is_approved': true,
    }).eq('id', userId);
  }

  // Kullanıcıyı reddet (sil)
  Future<void> rejectUser(String userId) async {
    await client.from('profiles').delete().eq('id', userId);
  }

  // ==================== TASKS ====================

  // Get all tasks (for admin)
  Future<List<TaskModel>> getAllTasks() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final response = await client
        .from('tasks')
        .select('''
          *,
          profiles!tasks_assigned_to_fkey(full_name)
        ''')
        .gte('created_at', startOfDay.toIso8601String())
        .order('priority', ascending: false)
        .order('created_at', ascending: false);

    return (response as List).map((task) {
      // Extract assigned_to_name from joined profile
      if (task['profiles'] != null) {
        task['assigned_to_name'] = task['profiles']['full_name'];
      }
      return TaskModel.fromJson(task);
    }).toList();
  }

  // Get available tasks (not assigned or assigned to current user)
  Future<List<TaskModel>> getAvailableTasks(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final response = await client
        .from('tasks')
        .select()
        .gte('created_at', startOfDay.toIso8601String())
        .or('assigned_to.is.null,assigned_to.eq.$userId')
        .neq('status', TaskStatus.completed.value)
        .order('priority', ascending: false)
        .order('created_at', ascending: false);

    return (response as List).map((task) => TaskModel.fromJson(task)).toList();
  }

  // Get my tasks (assigned to me)
  Future<List<TaskModel>> getMyTasks(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final response = await client
        .from('tasks')
        .select()
        .eq('assigned_to', userId)
        .gte('created_at', startOfDay.toIso8601String())
        .order('status')
        .order('priority', ascending: false);

    return (response as List).map((task) => TaskModel.fromJson(task)).toList();
  }

  // Create task
  Future<TaskModel> createTask({
    required String title,
    String? description,
    required TaskPriority priority,
    required bool isRecurring,
    required String createdBy,
    DateTime? dueDate,
  }) async {
    final response = await client.from('tasks').insert({
      'title': title,
      'description': description,
      'priority': priority.value,
      'is_recurring': isRecurring,
      'status': TaskStatus.pending.value,
      'created_by': createdBy,
      'created_at': DateTime.now().toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
    }).select().single();

    return TaskModel.fromJson(response);
  }

  // Assign task to user
  Future<void> assignTask(String taskId, String userId) async {
    await client.from('tasks').update({
      'assigned_to': userId,
      'status': TaskStatus.inProgress.value,
    }).eq('id', taskId);
  }

  // Unassign task
  Future<void> unassignTask(String taskId) async {
    await client.from('tasks').update({
      'assigned_to': null,
      'status': TaskStatus.pending.value,
    }).eq('id', taskId);
  }

  // Complete task
  Future<void> completeTask(String taskId) async {
    await client.from('tasks').update({
      'status': TaskStatus.completed.value,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await client.from('tasks').delete().eq('id', taskId);
  }

  // ==================== EMPLOYEES ====================

  // Get all employees
  Future<List<UserModel>> getAllEmployees() async {
    final response = await client
        .from('profiles')
        .select()
        .order('full_name');

    return (response as List).map((user) => UserModel.fromJson(user)).toList();
  }

  // ==================== REALTIME ====================

  // Subscribe to task changes
  RealtimeChannel subscribeToTasks(void Function(Map<String, dynamic>) callback) {
    return client
        .channel('tasks_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          callback: (payload) => callback(payload.newRecord),
        )
        .subscribe();
  }
}

