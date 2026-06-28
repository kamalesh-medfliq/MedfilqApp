import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      final response = await ApiClient().dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Extract the JWT from the backend response
      final accessToken = response.data['accessToken'];
      if (accessToken != null) {
        // Securely store the token
        await _storage.write(key: 'jwt_token', value: accessToken);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        _error = e.response?.data['message'] ?? 'Login failed';
      } else {
        _error = 'Connection failed: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Step 7: Registration Flow ---
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
      final response = await ApiClient().dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'clinicId': clinicName, // For demonstration, mapping name to ID field
        },
      );
      
      // If backend eventually returns token on signup, handle it here
      final accessToken = response.data['accessToken'];
      if (accessToken != null) {
        await _storage.write(key: 'jwt_token', value: accessToken);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        _error = e.response?.data['message'] ?? 'Registration failed';
      } else {
        _error = 'Connection failed: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
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

