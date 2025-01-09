class SignupModel {
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;

  SignupModel({
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
} 