import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  UserProfile? _currentUserProfile;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _currentUser = _authService.currentUser;

    // Listen to auth state changes
    _authService.authStateChanges.listen((AuthState state) {
      _currentUser = state.session?.user;
      if (_currentUser != null) {
        _loadUserProfile();
      } else {
        _currentUserProfile = null;
      }
      _isInitialized = true;
      notifyListeners();
    });

    // Load initial profile if user is already signed in
    if (_currentUser != null) {
      _loadUserProfile();
    }

    // Mark as initialized even if no user is signed in
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    try {
      _currentUserProfile = await _authService.getCurrentUserProfile();
    } catch (error) {
      debugPrint('Error loading user profile: $error');
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? firstName,
    String? lastName,
    UserRole role = UserRole.rider,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        return true;
      }
      return false;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
        return true;
      }
      return false;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _authService.signInWithOAuth(provider);
      if (success) {
        // User and profile will be updated via auth state listener
        return true;
      }
      return false;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _currentUserProfile = null;
    } catch (error) {
      _setError(error.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updatePassword(newPassword);
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedProfile = await _authService.updateUserProfile(updates);
      _currentUserProfile = updatedProfile;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadAvatar(File imageFile) async {
    try {
      _setLoading(true);
      _clearError();

      final avatarUrl = await _authService.uploadAvatarFromFile(imageFile);

      // Update the current profile with new avatar URL
      if (_currentUserProfile != null) {
        _currentUserProfile =
            _currentUserProfile!.copyWith(avatarUrl: avatarUrl);
        notifyListeners();
      }

      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAvatar() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAvatar();

      // Update the current profile to remove avatar URL
      if (_currentUserProfile != null) {
        _currentUserProfile = _currentUserProfile!.copyWith(avatarUrl: null);
        notifyListeners();
      }

      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount();
      _currentUser = null;
      _currentUserProfile = null;
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      return await _authService.searchUsers(query);
    } catch (error) {
      _setError(error.toString());
      return [];
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      return await _authService.getUserProfile(userId);
    } catch (error) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Development helper
  Map<String, String> getTestCredentials() {
    return AuthService.getTestCredentials();
  }
}
