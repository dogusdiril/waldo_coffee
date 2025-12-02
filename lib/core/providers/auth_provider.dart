import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../constants/app_constants.dart';

// Supabase service provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (state) async {
      if (state.session?.user != null) {
        final supabase = ref.read(supabaseServiceProvider);
        return await supabase.getUserProfile(state.session!.user.id);
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth notifier for login/logout actions
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      try {
        final profile = await _supabaseService.getUserProfile(user.id);
        state = AsyncValue.data(profile);
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      debugPrint('📧 Supabase auth başlatılıyor: $email');
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      debugPrint('🔑 Auth response: ${response.user?.id}');
      
      if (response.user != null) {
        debugPrint('👤 Profile getiriliyor...');
        try {
          final profile = await _supabaseService.getUserProfile(response.user!.id);
          debugPrint('✅ Profile bulundu: ${profile?.fullName}');
          
          // Onay kontrolü - STATE SET ETMEDEN ÖNCE!
          if (profile == null) {
            debugPrint('❌ Profile bulunamadı');
            await _supabaseService.signOut();
            state = const AsyncValue.data(null);
            throw Exception('Profil bulunamadı');
          }
          
          if (!profile.isApproved) {
            debugPrint('⏳ Kullanıcı henüz onaylanmamış');
            await _supabaseService.signOut();
            state = const AsyncValue.data(null);
            throw Exception('Hesabınız henüz onaylanmadı. Admin onayı bekleniyor.');
          }
          
          // Her şey OK, state'i set et
          debugPrint('✅ Giriş başarılı, state set ediliyor');
          state = AsyncValue.data(profile);
        } catch (profileError) {
          if (profileError.toString().contains('onaylanmadı')) {
            rethrow;
          }
          debugPrint('⚠️ Profile bulunamadı, oluşturuluyor...');
          // Profile yoksa oluştur
          await _supabaseService.createProfile(
            userId: response.user!.id,
            email: email,
            fullName: email.split('@').first,
          );
          final profile = await _supabaseService.getUserProfile(response.user!.id);
          state = AsyncValue.data(profile);
        }
      } else {
        debugPrint('❌ Auth response boş');
        state = AsyncValue.error('Giriş başarısız', StackTrace.current);
      }
    } catch (e) {
      debugPrint('❌ SignIn hatası: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    UserRole role = UserRole.employee,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      if (response.user != null) {
        final profile = await _supabaseService.getUserProfile(response.user!.id);
        state = AsyncValue.data(profile);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
});

