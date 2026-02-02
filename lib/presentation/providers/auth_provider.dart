import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fashion_store/services/supabase_service.dart';
import 'package:fashion_store/data/models/profile_model.dart';

/// Provider del estado de autenticación
final authStateProvider = StreamProvider<User?>((ref) {
  return SupabaseService.client.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Provider del usuario actual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Provider de si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Provider del perfil del usuario
final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final data = await SupabaseService.instance.getProfile();
  if (data == null) return null;

  return Profile.fromJson(data);
});

/// Provider de si es admin
final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(profileProvider).valueOrNull;
  return profile?.isAdmin ?? false;
});

/// Notifier para acciones de auth
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  final _supabase = SupabaseService.instance;

  /// Registro
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Login
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _supabase.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Recuperar contraseña
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.resetPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Actualizar contraseña
  Future<void> updatePassword(String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.updatePassword(newPassword);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider del AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier();
});
