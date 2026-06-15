import 'package:flutter/material.dart';
import '../models/index.dart';
import './auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isUser => _currentUser?.role == 'user';

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize auth on app start
  void _initializeAuth() async {
    _currentUser = await _authService.getCurrentUser();
    _isLoggedIn = _currentUser != null;
    notifyListeners();

    // Listen to auth state changes
    _authService.authStateChanges.listen((data) {
      if (data.session == null) {
        _currentUser = null;
        _isLoggedIn = false;
      } else {
        _getCurrentUserData();
      }
      notifyListeners();
    });
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required String role,
    String? nomorHP,
    String? asal,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        nama: nama,
        role: role,
        nomorHP: nomorHP,
        asal: asal,
      );

      _isLoading = false;

      if (result['success']) {
        _currentUser = result['user'];
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      _isLoading = false;

      if (result['success']) {
        _currentUser = result['user'];
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal logout: $e';
      notifyListeners();
    }
  }

  // Get current user data
  Future<void> _getCurrentUserData() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      _isLoggedIn = _currentUser != null;
      notifyListeners();
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authService.emailExists(email);
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.resetPassword(email);

      _isLoading = false;

      if (result['success']) {
        _errorMessage = result['message'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updatePassword(newPassword);

      _isLoading = false;

      if (result['success']) {
        _errorMessage = result['message'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    required String nama,
    String? nomorHP,
    String? asal,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        nama: nama,
        nomorHP: nomorHP,
        asal: asal,
      );

      _isLoading = false;

      if (result['success']) {
        _currentUser = result['user'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
