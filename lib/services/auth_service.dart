import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/index.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final _supabase = Supabase.instance.client;

  // Stream to listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // Get current user
  User? get currentUser {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    // This will be fetched from DB in getCurrentUser()
    return null;
  }

  // Check if user is logged in
  bool get isLoggedIn {
    return _supabase.auth.currentUser != null;
  }

  // ==================== AUTHENTICATION ====================

  /// Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nama,
    required String role,
    String? nomorHP,
    String? asal,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || nama.isEmpty) {
        return {
          'success': false,
          'message': 'Email, password, dan nama tidak boleh kosong',
          'user': null,
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password minimal 6 karakter',
          'user': null,
        };
      }

      // Sign up
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Registrasi gagal',
          'user': null,
        };
      }

      // Insert user profile
      await _supabase.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'nama': nama,
        'role': role,
        'nomor_hp': nomorHP,
        'asal': asal,
      });

      final user = User(
        id: authResponse.user!.id,
        email: email,
        nama: nama,
        role: role,
        nomorHP: nomorHP,
        asal: asal,
        createdAt: DateTime.now(),
      );

      return {
        'success': true,
        'message': 'Registrasi berhasil!',
        'user': user,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'user': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'user': null,
      };
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Email dan password tidak boleh kosong',
          'user': null,
        };
      }

      // Sign in
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return {
          'success': false,
          'message': 'Login gagal',
          'user': null,
        };
      }

      // Get user profile
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      final user = User.fromJson(response);

      return {
        'success': true,
        'message': 'Login berhasil!',
        'user': user,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'user': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'user': null,
      };
    }
  }

  /// Get current user profile
  Future<User?> getCurrentUser() async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        return null;
      }

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('email', email);
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verify email (optional - for email verification flow)
  Future<void> verifyEmail(String email) async {
    try {
      await _supabase.auth.resendOtp(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return {
          'success': false,
          'message': 'Email tidak boleh kosong',
        };
      }

      await _supabase.auth.resetPasswordForEmail(email);

      return {
        'success': true,
        'message':
            'Link reset password telah dikirim ke email Anda. Silakan cek email Anda.',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Update password
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      if (newPassword.isEmpty || newPassword.length < 6) {
        return {
          'success': false,
          'message': 'Password minimal 6 karakter',
        };
      }

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return {
        'success': true,
        'message': 'Password berhasil diperbarui',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Update profile
  Future<Map<String, dynamic>> updateProfile({
    required String nama,
    String? nomorHP,
    String? asal,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        return {
          'success': false,
          'message': 'User tidak ditemukan',
          'user': null,
        };
      }

      await _supabase.from('users').update({
        'nama': nama,
        'nomor_hp': nomorHP,
        'asal': asal,
      }).eq('id', authUser.id);

      final user = await getCurrentUser();

      return {
        'success': true,
        'message': 'Profil berhasil diperbarui',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'user': null,
      };
    }
  }
}
