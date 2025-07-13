import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data'; // Import for Uint8List
import 'dart:io';

import '../models/user_profile.dart';
import './supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService = SupabaseService();

  SupabaseClient get _client => _supabaseService.clientSync;

  // Get current user
  User? get currentUser {
    try {
      return _client.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Get current session
  Session? get currentSession {
    try {
      return _client.auth.currentSession;
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges {
    try {
      return _client.auth.onAuthStateChange;
    } catch (e) {
      return Stream.empty();
    }
  }

  // Check if service is properly configured
  bool get isConfigured => _supabaseService.isProperlyConfigured;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? firstName,
    String? lastName,
    UserRole role = UserRole.rider,
  }) async {
    try {
      if (!isConfigured) {
        throw Exception('Supabase não está configurado corretamente');
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'first_name': firstName,
          'last_name': lastName,
          'role': role.name,
        },
      );

      if (response.user != null && response.session != null) {
        // Profile will be automatically created by database trigger
        await _updateLastActiveTime();
      }

      return response;
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (!isConfigured) {
        throw Exception('Supabase não está configurado corretamente');
      }

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        await _updateLastActiveTime();
      }

      return response;
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Sign in with OAuth (Google, Facebook, etc.)
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      if (!isConfigured) {
        throw Exception('Supabase não está configurado corretamente');
      }

      return await _client.auth.signInWithOAuth(provider);
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!isConfigured) {
        return; // Silent fail if not configured
      }

      await _client.auth.signOut();
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (!isConfigured) {
        throw Exception('Supabase não está configurado corretamente');
      }

      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      if (!isConfigured) {
        throw Exception('Supabase não está configurado corretamente');
      }

      return await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      if (!isConfigured) {
        throw Exception('Supabase não está configurado corretamente');
      }

      return await _client.auth.updateUser(
        UserAttributes(data: metadata),
      );
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      if (!isAuthenticated || !isConfigured) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  // Update user profile
  Future<UserProfile> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Upload avatar from file
  Future<String> uploadAvatarFromFile(File imageFile) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final fileBytes = await imageFile.readAsBytes();
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          '${currentUser!.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      await _client.storage.from('avatars').uploadBinary(fileName, fileBytes);

      final avatarUrl = _client.storage.from('avatars').getPublicUrl(fileName);

      // Update user profile with new avatar URL
      await updateUserProfile({'avatar_url': avatarUrl});

      return avatarUrl;
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Upload avatar from bytes
  Future<String> uploadAvatar(String filePath, List<int> fileBytes) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final fileName =
          '${currentUser!.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage
          .from('avatars')
          .uploadBinary(fileName, Uint8List.fromList(fileBytes));

      final avatarUrl = _client.storage.from('avatars').getPublicUrl(fileName);

      // Update user profile with new avatar URL
      await updateUserProfile({'avatar_url': avatarUrl});

      return avatarUrl;
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Delete current avatar
  Future<void> deleteAvatar() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final currentProfile = await getCurrentUserProfile();
      if (currentProfile?.avatarUrl != null) {
        // Extract the file path from the avatar URL
        final avatarUrl = currentProfile!.avatarUrl!;
        if (avatarUrl.contains('/storage/v1/object/public/avatars/')) {
          final avatarPath =
              avatarUrl.split('/storage/v1/object/public/avatars/').last;

          // Delete from storage
          await _client.storage.from('avatars').remove([avatarPath]);

          // Update profile to remove avatar URL
          await updateUserProfile({'avatar_url': null});
        }
      }
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Delete user profile (will cascade to auth.users via trigger)
      await _client.from('user_profiles').delete().eq('id', currentUser!.id);

      await signOut();
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Search users by name or email
  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .eq('is_active', true)
          .order('full_name');

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  // Update last active time
  Future<void> _updateLastActiveTime() async {
    try {
      if (!isAuthenticated) return;

      await _client
          .from('user_profiles')
          .update({'last_active_at': DateTime.now().toIso8601String()}).eq(
              'id', currentUser!.id);
    } catch (error) {
      // Silent fail - not critical
    }
  }

  // Handle auth errors
  Exception _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          return Exception(
              'Dados inválidos. Verifique as informações inseridas.');
        case '422':
          return Exception('Email já está em uso. Tente fazer login.');
        case '429':
          return Exception(
              'Muitas tentativas. Tente novamente em alguns minutos.');
        case '500':
          return Exception('Erro interno do servidor. Tente novamente.');
        default:
          return Exception(error.message);
      }
    }

    if (error is PostgrestException) {
      return Exception('Erro na base de dados: ${error.message}');
    }

    return Exception('Erro inesperado: $error');
  }

  // Development helper - get test credentials
  static Map<String, String> getTestCredentials() {
    return {
      'admin@desbrav.com': 'admin123',
      'rider@desbrav.com': 'rider123',
      'joao@desbrav.com': 'joao123',
    };
  }
}
