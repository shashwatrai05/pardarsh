class ContractorModel {
  final String uid;
  final String name;
  final double faithScore;
  final List<String> assignedProjects;

  ContractorModel({
    required this.uid,
    required this.name,
    required this.faithScore,
    required this.assignedProjects,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'faithScore': faithScore,
      'assignedProjects': assignedProjects,
    };
  }

  factory ContractorModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ContractorModel(
      uid: id,
      name: data['name'],
      faithScore: data['faithScore'],
      assignedProjects: List<String>.from(data['assignedProjects']),
    );
  }
}
