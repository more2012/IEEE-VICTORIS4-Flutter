class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'email': email, 'phone': phone};
  }
}
