class User {
  final String username;
  final String email;
  final bool isPro;
  final String language;
  final String profileIcon;
  final String authMethod;

  const User({
    required this.username,
    required this.email,
    required this.isPro,
    required this.language,
    required this.profileIcon,
    required this.authMethod,
  });

  User copyWith({
    String? username,
    String? email,
    bool? isPro,
    String? language,
    String? profileIcon,
    String? authMethod,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      isPro: isPro ?? this.isPro,
      language: language ?? this.language,
      profileIcon: profileIcon ?? this.profileIcon,
      authMethod: authMethod ?? this.authMethod,
    );
  }
}
