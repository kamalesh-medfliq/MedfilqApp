class Appointment {
  final String id;
  final String appointmentNumber;
  final int queueNumber;
  final String patientId;
  final String doctorId;
  final String scheduleId;
  final DateTime appointmentDate;
  final DateTime startTime;
  final DateTime endTime;
  final String visitType;
  final String priority;
  final String status;
  final String? notes;
  
  // Relations mapped if provided
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? doctor;

  Appointment({
    required this.id,
    required this.appointmentNumber,
    required this.queueNumber,
    required this.patientId,
    required this.doctorId,
    required this.scheduleId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.visitType,
    required this.priority,
    required this.status,
    this.notes,
    this.patient,
    this.doctor,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      appointmentNumber: json['appointmentNumber'] ?? '',
      queueNumber: json['queueNumber'] ?? 0,
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      scheduleId: json['scheduleId'] ?? '',
      appointmentDate: DateTime.parse(json['appointmentDate']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      visitType: json['visitType'] ?? 'CONSULTATION',
      priority: json['priority'] ?? 'NORMAL',
      status: json['status'] ?? 'SCHEDULED',
      notes: json['notes'],
      patient: json['patient'],
      doctor: json['doctor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentNumber': appointmentNumber,
      'queueNumber': queueNumber,
      'patientId': patientId,
      'doctorId': doctorId,
      'scheduleId': scheduleId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'visitType': visitType,
      'priority': priority,
      'status': status,
      'notes': notes,
    };
  }
}
