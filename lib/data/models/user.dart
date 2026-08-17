class UserInfo {
  final String userId;
  final String username;
  final String avatar;
  final bool isVip;
  final String plan;

  UserInfo({
    required this.userId,
    required this.username,
    required this.avatar,
    this.isVip = false,
    this.plan = '免费版',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'isVip': isVip,
      'plan': plan,
    };
  }

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      userId: map['userId'] as String,
      username: map['username'] as String,
      avatar: map['avatar'] as String,
      isVip: map['isVip'] as bool? ?? false,
      plan: map['plan'] as String? ?? '免费版',
    );
  }
}
