class Patient {
  final String id;
  final String patientNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final DateTime dateOfBirth;
  final String? bloodGroup;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? relationship;
  final List<String>? allergies;
  final List<String>? chronicDiseases;
  final String? medicalNotes;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final String status;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.patientNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    this.bloodGroup,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.relationship,
    this.allergies,
    this.chronicDiseases,
    this.medicalNotes,
    this.insuranceProvider,
    this.insuranceNumber,
    required this.status,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      patientNumber: json['patientNumber'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] ?? '') ?? DateTime.now(),
      bloodGroup: json['bloodGroup'],
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      relationship: json['relationship'],
      allergies: json['allergies'] != null ? List<String>.from(json['allergies']) : null,
      chronicDiseases: json['chronicDiseases'] != null ? List<String>.from(json['chronicDiseases']) : null,
      medicalNotes: json['medicalNotes'],
      insuranceProvider: json['insuranceProvider'],
      insuranceNumber: json['insuranceNumber'],
      status: json['status'] ?? 'ACTIVE',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get fullName => '$firstName $lastName';
  
  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month || (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
