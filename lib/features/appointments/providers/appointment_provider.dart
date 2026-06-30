import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../models/appointment.dart';
import 'package:dio/dio.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String _error = '';

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchAppointments({String? date, String? status, String? doctorId}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final Map<String, dynamic> queryParams = {};
      if (date != null) queryParams['date'] = date;
      if (status != null) queryParams['status'] = status;
      if (doctorId != null) queryParams['doctorId'] = doctorId;

      final response = await ApiClient().dio.get('/appointments', queryParameters: queryParams);
      
      final List<dynamic> data = response.data;
      _appointments = data.map((e) => Appointment.fromJson(e)).toList();
    } catch (e) {
      if (e is DioException) {
        _error = e.response?.data['message'] ?? e.message;
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await ApiClient().dio.patch('/appointments/$id/status', data: {'status': status});
      // Optionally just locally update without full refetch
      final idx = _appointments.indexWhere((a) => a.id == id);
      if (idx != -1) {
        final current = _appointments[idx];
        _appointments[idx] = Appointment(
          id: current.id,
          appointmentNumber: current.appointmentNumber,
          queueNumber: current.queueNumber,
          patientId: current.patientId,
          doctorId: current.doctorId,
          scheduleId: current.scheduleId,
          appointmentDate: current.appointmentDate,
          startTime: current.startTime,
          endTime: current.endTime,
          visitType: current.visitType,
          priority: current.priority,
          status: status,
          notes: current.notes,
          patient: current.patient,
          doctor: current.doctor,
        );
        notifyListeners();
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update status');
      }
      throw e;
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await ApiClient().dio.delete('/appointments/$id');
      final idx = _appointments.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _appointments.removeAt(idx);
        notifyListeners();
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Failed to cancel appointment');
      }
      throw e;
    }
  }
}
