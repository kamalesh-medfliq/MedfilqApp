import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/network/api_client.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  final _storage = const FlutterSecureStorage();

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Authenticate with Firebase Email/Password
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Retrieve Firebase ID Token
      final firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        throw Exception("Failed to get Firebase token");
      }

      // 3. Send token to NestJS backend
      final response = await ApiClient().dio.post(
        '/auth/login',
        data: {
          'firebaseToken': firebaseToken,
        },
      );
      
      // 4. Extract MedFliq JWT and store securely
      final accessToken = response.data['accessToken'];
      if (accessToken != null) {
        await _storage.write(key: 'jwt_token', value: accessToken);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Firebase Login failed (${e.code})';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseException catch (e) {
      _error = 'Firebase Error: ${e.message}';
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        _error = e.response?.data['message'] ?? 'Backend Login failed';
      } else {
        _error = 'Connection failed: ${e.message}';
      }
      // If backend fails (e.g. not registered, suspended), sign out of Firebase
      await FirebaseAuth.instance.signOut();
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final errorStr = e.toString();
      _error = errorStr == 'Error' || errorStr.isEmpty
          ? 'Invalid credentials or Account not found!' 
          : 'Unexpected error: $errorStr';
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerClinic({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String clinicName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Create user in Firebase
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Get the Firebase ID token
      final firebaseToken = await userCredential.user?.getIdToken();
      if (firebaseToken == null) {
        throw Exception("Failed to get Firebase token");
      }

      // 3. Send token and profile to backend
      final response = await ApiClient().dio.post(
        '/auth/register',
        data: {
          'firebaseToken': firebaseToken,
          'firstName': firstName,
          'lastName': lastName,
          'clinicId': clinicName, 
        },
      );
      
      // 4. Store MedFliq JWT
      final accessToken = response.data['accessToken'];
      if (accessToken != null) {
        await _storage.write(key: 'jwt_token', value: accessToken);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Firebase Registration failed (${e.code})';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseException catch (e) {
      _error = 'Firebase Error: ${e.message}';
      _isLoading = false;
      notifyListeners();
      return false;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        _error = e.response?.data['message'] ?? 'Backend Registration failed';
      } else {
        _error = 'Connection failed: ${e.message}';
      }
      // If backend registration fails, clean up the Firebase user so they aren't stuck
      await FirebaseAuth.instance.currentUser?.delete();
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final errorStr = e.toString();
      _error = errorStr == 'Error' || errorStr.isEmpty
          ? 'Failed to connect to Firebase. Check API key.' 
          : 'Unexpected error: $errorStr';
      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } catch (_) {}
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await _storage.delete(key: 'jwt_token');
    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // --- Step 6: Test Protected Endpoint ---
  Future<bool> testAuthConnection() async {
    try {
      final response = await ApiClient().dio.get('/users');
      debugPrint('Protected Endpoint Success! Data: ${response.data}');
      return true;
    } on DioException catch (e) {
      debugPrint('Protected Endpoint Failed! Status: ${e.response?.statusCode}');
      return false;
    } catch (e) {
      debugPrint('Protected Endpoint Error: $e');
      return false;
    }
  }
}

