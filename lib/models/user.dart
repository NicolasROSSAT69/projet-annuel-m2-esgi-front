class AppUser {
  final String id;
  final String username;
  final String email;
  final String accessToken;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.accessToken,
  });

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      accessToken: json['accessToken'],
    );
  }
}
