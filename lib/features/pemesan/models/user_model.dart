class UserModel {
  final String id;
  final String? name;
  final String? username;
  final String email;
  final String role;
  final String? profilePhoto;
  final String? phoneCode;
  final String? phoneNumber;
  final String? bio;
  final String? birthDate;
  final bool isProfileSetup;

  UserModel({
    required this.id,
    this.name,
    this.username,
    required this.email,
    required this.role,
    this.profilePhoto,
    this.phoneCode,
    this.phoneNumber,
    this.bio,
    this.birthDate,
    required this.isProfileSetup,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'],
      username: json['username'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      profilePhoto: json['profile_photo'],
      phoneCode: json['phone_code'],
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      birthDate: json['birth_date'],
      isProfileSetup: json['is_profile_setup'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'profile_photo': profilePhoto,
      'phone_code': phoneCode,
      'phone_number': phoneNumber,
      'bio': bio,
      'birth_date': birthDate,
      'is_profile_setup': isProfileSetup,
    };
  }
}
