import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/userModel.dart';
import '../services/authService.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthController() {
    _initAuthState();
  }

  // Initialize auth state by checking Firebase Auth and SharedPreferences
  Future<void> _initAuthState() async {
    _isLoading = true;
    notifyListeners();

    // First check Firebase Auth current user
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // User is already logged in via Firebase
      _currentUser = UserModel.fromFirebaseUser(firebaseUser);
    } else {
      // Check if we have a cached auth state in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final hasLoggedInBefore = prefs.getBool('isLoggedIn') ?? false;

      if (hasLoggedInBefore) {
        // Try to sign in silently using stored credentials
        // If you stored token or other auth method, you would use it here
        // This example just marks the user as not logged in
        await prefs.setBool('isLoggedIn', false);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithEmail(email, password);

      // Save login state to SharedPreferences
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }
    } catch (e) {
      // Handle errors and transform them to user-friendly messages
      String errorMessage = "Login failed";
      if (e.toString().contains('user-not-found')) {
        errorMessage = "No user found with this email";
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = "Wrong password";
      }
      throw errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register with email and password
  Future<void> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.registerWithEmail(email, password);

      // Save login state to SharedPreferences
      if (_currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
      }
    } catch (e) {
      // Handle errors and transform them to user-friendly messages
      String errorMessage = "Registration failed";
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = "Email already in use";
      } else if (e.toString().contains('weak-password')) {
        errorMessage = "Password is too weak";
      }
      throw errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;

      // Clear login state in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
