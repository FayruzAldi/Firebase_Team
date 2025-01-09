class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      photoUrl: json['photoUrl'],
    );
  }
} 