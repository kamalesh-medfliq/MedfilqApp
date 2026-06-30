import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../domain/models/patient.dart';

class PatientProvider extends ChangeNotifier {
  final List<Patient> _patients = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  String? _error;
  
  int _currentPage = 1;
  final int _limit = 20;
  String _searchQuery = '';
  
  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> fetchPatients({bool refresh = false, String? search}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _patients.clear();
      _isLoading = true;
    } else {
      if (!_hasMore || _isFetchingMore) return;
      _isFetchingMore = true;
    }
    
    if (search != null) {
      _searchQuery = search;
    }
    
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient().dio.get('/patients', queryParameters: {
        'page': _currentPage,
        'limit': _limit,
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      });

      final data = response.data['data'] as List;
      final meta = response.data['meta'];

      final newPatients = data.map((json) => Patient.fromJson(json)).toList();
      _patients.addAll(newPatients);
      
      _currentPage++;
      _hasMore = _currentPage <= meta['totalPages'];
    } on DioException catch (e) {
      _error = 'Network error: ${e.message}';
    } catch (e) {
      _error = 'Failed to load patients: $e';
    } finally {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data, {bool force = false}) async {
    try {
      final response = await ApiClient().dio.post(
        '/patients',
        data: data,
        queryParameters: force ? {'force': 'true'} : null,
      );
      
      final newPatient = Patient.fromJson(response.data);
      _patients.insert(0, newPatient);
      notifyListeners();
      
      return {'success': true, 'patient': newPatient};
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 && e.response?.data != null) {
        return {
          'success': false,
          'isDuplicate': true,
          'message': e.response!.data['message'],
          'duplicates': e.response!.data['duplicates'],
        };
      }
      
      String errorMessage = 'Failed to create patient: ${e.message}';
      if (e.response?.data != null && e.response?.data is Map) {
         final errorData = e.response!.data as Map;
         if (errorData.containsKey('errors') && errorData['errors'] is List) {
           final errors = errorData['errors'] as List;
           final errorMessages = errors.map((err) {
             final path = err['path'] != null && (err['path'] as List).isNotEmpty ? err['path'][0] : 'Field';
             return '$path: ${err['message']}';
           }).join('\\n');
           errorMessage = 'Validation Errors:\\n$errorMessages';
         } else if (errorData.containsKey('message')) {
           errorMessage = errorData['message'].toString();
         }
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
