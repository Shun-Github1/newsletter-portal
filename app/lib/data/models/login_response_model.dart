class LoginResponseModel {
  final String? csrfToken;

  const LoginResponseModel({
    this.csrfToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      csrfToken: json['csrf_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'csrf_token': csrfToken,
    };
  }

  LoginResponseModel copyWith({
    String? csrfToken,
  }) {
    return LoginResponseModel(
      csrfToken: csrfToken ?? this.csrfToken,
    );
  }
}
