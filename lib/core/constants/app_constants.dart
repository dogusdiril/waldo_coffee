// Waldo Coffee - App Constants
// Supabase bilgilerini buraya ekleyeceğiz

class AppConstants {
  // Supabase credentials
  static const String supabaseUrl = 'https://gmjzwwtkuywnvailktit.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_sP4DpD_lFI7SerNTuTg6Xg_wCY41nHU';

  // App info
  static const String appName = 'Waldo Coffee';
  static const String appVersion = '1.0.0';
}

// Task priority levels
enum TaskPriority {
  normal('Normal', 0),
  urgent('Acil', 1),
  critical('Kritik', 2);

  final String label;
  final int value;
  const TaskPriority(this.label, this.value);
}

// Task status
enum TaskStatus {
  pending('Bekliyor', 'pending'),
  inProgress('Yapılıyor', 'in_progress'),
  completed('Tamamlandı', 'completed');

  final String label;
  final String value;
  const TaskStatus(this.label, this.value);
}

// User roles
enum UserRole {
  admin('Admin', 'admin'),
  employee('Çalışan', 'employee');

  final String label;
  final String value;
  const UserRole(this.label, this.value);
}

