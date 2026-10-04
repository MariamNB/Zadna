class HouseholdSummary {
  final String id;
  final String name;
  final String role;
  final String memberId;

  const HouseholdSummary(
      {required this.id,
      required this.name,
      required this.role,
      required this.memberId});

  factory HouseholdSummary.fromJson(Map<String, dynamic> json) =>
      HouseholdSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        memberId: json['memberId'] as String,
      );

  bool get canManage => role == 'owner' || role == 'admin';
}

class HouseholdMember {
  final String id;
  final String userId;
  final String email;
  final String role;

  const HouseholdMember(
      {required this.id,
      required this.userId,
      required this.email,
      required this.role});

  factory HouseholdMember.fromJson(Map<String, dynamic> json) =>
      HouseholdMember(
        id: json['id'] as String,
        userId: json['userId'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}

class HouseholdInvitation {
  final String id;
  final String householdName;
  final String email;
  final String role;

  const HouseholdInvitation(
      {required this.id,
      required this.householdName,
      required this.email,
      required this.role});

  factory HouseholdInvitation.fromJson(Map<String, dynamic> json) =>
      HouseholdInvitation(
        id: json['id'] as String,
        householdName: json['householdName'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}
