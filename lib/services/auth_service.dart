import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _databaseService = DatabaseService();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Initialize tables
  Future<void> initializeTables() async {
    final db = await _databaseService.database;
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        createdAt TEXT NOT NULL,
        isAdmin INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_sessions(
        user_id TEXT PRIMARY KEY,
        session_token TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password + 'ecoguardian_salt_2024');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      await initializeTables();
      final db = await _databaseService.database;

      // Check if email already exists
      final existingUsers = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (existingUsers.isNotEmpty) {
        return {
          'success': false,
          'message': 'Email already registered. Please use a different email.',
        };
      }

      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return {
          'success': false,
          'message': 'Please enter a valid email address.',
        };
      }

      // Validate password strength
      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters long.',
        };
      }

      // Create new user
      final userId = const Uuid().v4();
      final passwordHash = _hashPassword(password);
      
      final user = User(
        id: userId,
        email: email.toLowerCase(),
        name: name.trim(),
        phone: phone?.trim(),
        createdAt: DateTime.now(),
        isAdmin: false,
      );

      // Insert into database
      await db.insert('users', {
        ...user.toJson(),
        'password_hash': passwordHash,
      });

      debugPrint('User registered successfully: ${user.email}');
      
      return {
        'success': true,
        'message': 'Account created successfully! Please log in.',
        'user': user,
      };
    } catch (e) {
      debugPrint('Registration error: $e');
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      await initializeTables();
      final db = await _databaseService.database;

      // Find user by email
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid email or password.',
        };
      }

      final userData = users.first;
      final storedPasswordHash = userData['password_hash'] as String;
      final inputPasswordHash = _hashPassword(password);

      if (storedPasswordHash != inputPasswordHash) {
        return {
          'success': false,
          'message': 'Invalid email or password.',
        };
      }

      // Create user object
      final user = User.fromJson(userData);
      _currentUser = user;

      // Save session
      await _saveSession(user.id);

      debugPrint('User logged in successfully: ${user.email}');

      return {
        'success': true,
        'message': 'Welcome back, ${user.name}!',
        'user': user,
      };
    } catch (e) {
      debugPrint('Login error: $e');
      return {
        'success': false,
        'message': 'Login failed. Please try again.',
      };
    }
  }

  // Save user session
  Future<void> _saveSession(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', userId);
      await prefs.setString('session_created', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  // Load saved session
  Future<bool> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      
      if (userId == null) return false;

      await initializeTables();
      final db = await _databaseService.database;
      
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isNotEmpty) {
        _currentUser = User.fromJson(users.first);
        debugPrint('Session loaded for user: ${_currentUser!.email}');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error loading session: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_id');
      await prefs.remove('session_created');
      
      _currentUser = null;
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'No user logged in.',
        };
      }

      final db = await _databaseService.database;
      
      await db.update(
        'users',
        {
          'name': name.trim(),
          'phone': phone?.trim(),
        },
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      _currentUser = _currentUser!.copyWith(
        name: name.trim(),
        phone: phone?.trim(),
      );

      return {
        'success': true,
        'message': 'Profile updated successfully!',
        'user': _currentUser,
      };
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return {
        'success': false,
        'message': 'Failed to update profile.',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'No user logged in.',
        };
      }

      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'New password must be at least 6 characters long.',
        };
      }

      final db = await _databaseService.database;
      
      // Verify current password
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'User not found.',
        };
      }

      final storedPasswordHash = users.first['password_hash'] as String;
      final currentPasswordHash = _hashPassword(currentPassword);

      if (storedPasswordHash != currentPasswordHash) {
        return {
          'success': false,
          'message': 'Current password is incorrect.',
        };
      }

      // Update password
      final newPasswordHash = _hashPassword(newPassword);
      await db.update(
        'users',
        {'password_hash': newPasswordHash},
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      return {
        'success': true,
        'message': 'Password changed successfully!',
      };
    } catch (e) {
      debugPrint('Error changing password: $e');
      return {
        'success': false,
        'message': 'Failed to change password.',
      };
    }
  }

  // Get all users (admin only)
  Future<List<User>> getAllUsers() async {
    try {
      if (_currentUser == null || !_currentUser!.isAdmin) {
        return [];
      }

      final db = await _databaseService.database;
      final users = await db.query('users', orderBy: 'createdAt DESC');
      
      return users.map((userData) => User.fromJson(userData)).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  // Delete user account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'No user logged in.',
        };
      }

      final db = await _databaseService.database;
      
      await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      await logout();

      return {
        'success': true,
        'message': 'Account deleted successfully.',
      };
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return {
        'success': false,
        'message': 'Failed to delete account.',
      };
    }
  }
} 