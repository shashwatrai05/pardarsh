class UserModel {
  final String uid;
  final String email;
  final String role;
  final String legalName;
  final String dob;
  final String phoneNumber;
  final String aadharNumber;
  final String address;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.legalName,
    required this.dob,
    required this.phoneNumber,
    required this.aadharNumber,
    required this.address,
  });

  // Convert Firestore DocumentSnapshot to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'General User',
      legalName: data['legalName'] ?? '',
      dob: data['dob'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      aadharNumber: data['aadharNumber'] ?? '',
      address: data['address'] ?? '',
    );
  }

  // Convert UserModel to Map (for Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'legalName': legalName,
      'dob': dob,
      'phoneNumber': phoneNumber,
      'aadharNumber': aadharNumber,
      'address': address,
    };
  }
}
