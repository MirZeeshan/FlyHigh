import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../database/db_helper.dart';
import '../../database/models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  User? _currentUser;

  // Singleton constructor
  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Getter for current user
  User? get currentUser => _currentUser;

  // Hash password consistently with registration
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      final users = await _dbHelper.fetchAllUsers();
      final hashedPassword = _hashPassword(password);

      for (var userData in users) {
        if (userData['email'].toString().toLowerCase() == email.toLowerCase() &&
            userData['password_hash'] == hashedPassword) {
          _currentUser = User.fromMap(userData);
          return _currentUser;
        }
      }

      return null; // No matching user found
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }

  // Register new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check for existing email
      final users = await _dbHelper.fetchAllUsers();
      final emailExists = users.any((user) =>
          user['email'].toString().toLowerCase() == email.toLowerCase());

      if (emailExists) {
        throw Exception('Email already registered');
      }

      // Create new user
      final user = User(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        passwordHash: _hashPassword(password),
      );

      final userId = await _dbHelper.insertUser(user.toMap());
      final createdUser = user.copyWith(userId: userId);
      _currentUser = createdUser;

      return createdUser;
    } catch (e) {
      rethrow; // Let the UI handle the error
    }
  }

  // Logout user
  void logout() {
    _currentUser = null;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _currentUser != null;
  }

  // Get user by ID
  Future<User?> getUserById(int userId) async {
    try {
      final users = await _dbHelper.fetchAllUsers();
      final userData = users.firstWhere(
        (user) => user['user_id'] == userId,
        orElse: () => throw Exception('User not found'),
      );
      return User.fromMap(userData);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<User> updateUserProfile(
      int userId, Map<String, dynamic> updates) async {
    try {
      await _dbHelper.updateUser(userId, updates);
      if (_currentUser?.userId == userId) {
        _currentUser = await getUserById(userId);
      }
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(
      int userId, String currentPassword, String newPassword) async {
    try {
      final user = await getUserById(userId);
      if (user == null) throw Exception('User not found');

      if (_hashPassword(currentPassword) != user.passwordHash) {
        throw Exception('Current password is incorrect');
      }

      await _dbHelper.updateUser(userId, {
        'password_hash': _hashPassword(newPassword),
      });
    } catch (e) {
      rethrow;
    }
  }
}
