import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Initialize auth state (check for saved session)
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final sessionLoaded = await _authService.loadSession();
      if (sessionLoaded) {
        _setCurrentUser(_authService.currentUser);
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (result['success']) {
        _setError(null);
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        _setCurrentUser(result['user']);
        _setError(null);
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Login failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _setCurrentUser(null);
      _setError(null);
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.updateProfile(
        name: name,
        phone: phone,
      );

      if (result['success']) {
        _setCurrentUser(result['user']);
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to update profile.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success']) {
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to change password.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _authService.deleteAccount();

      if (result['success']) {
        _setCurrentUser(null);
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete account.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error message
  void clearError() {
    _setError(null);
  }

  // Get user display name
  String get userDisplayName {
    if (_currentUser == null) return 'Guest';
    return _currentUser!.name;
  }

  // Get user email
  String get userEmail {
    if (_currentUser == null) return '';
    return _currentUser!.email;
  }

  // Check if user has permission to manage reports
  bool get canManageReports {
    return isLoggedIn && (isAdmin || true); // For now, all logged in users can manage
  }
} 