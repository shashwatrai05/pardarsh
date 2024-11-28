class UserModel {
  final String uid;
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
  });

  // Convert Firestore DocumentSnapshot to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'General User',
    );
  }

  // Convert UserModel to Map (for Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
    };
  }
}
