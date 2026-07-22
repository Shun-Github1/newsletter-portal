class UserModel {
  final String authMethod;
  final String email;
  final bool isPro;
  final String language;
  final String profileIcon;
  final String username;

  const UserModel({
    required this.authMethod,
    required this.email,
    required this.isPro,
    required this.language,
    required this.profileIcon,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authMethod: json['authMethod'] as String,
      email: json['email'] as String,
      isPro: json['isPro'] as bool,
      language: json['language'] as String,
      profileIcon: json['profileIcon'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authMethod': authMethod,
      'email': email,
      'isPro': isPro,
      'language': language,
      'profileIcon': profileIcon,
      'username': username,
    };
  }

  UserModel copyWith({
    String? authMethod,
    String? email,
    bool? isPro,
    String? language,
    String? profileIcon,
    String? username,
  }) {
    return UserModel(
      authMethod: authMethod ?? this.authMethod,
      email: email ?? this.email,
      isPro: isPro ?? this.isPro,
      language: language ?? this.language,
      profileIcon: profileIcon ?? this.profileIcon,
      username: username ?? this.username,
    );
  }
}
