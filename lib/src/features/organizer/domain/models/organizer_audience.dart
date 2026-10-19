class AudienceUser {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final bool isApproved;
  final bool isFollowed;

  const AudienceUser({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.isApproved = false,
    this.isFollowed = false,
  });

  String get displayHandle {
    final cleaned = username.trim().replaceAll(RegExp(r'^@'), '');
    return '@$cleaned';
  }

  AudienceUser copyWith({
    String? id,
    String? name,
    String? username,
    String? avatarUrl,
    bool? isApproved,
    bool? isFollowed,
  }) {
    return AudienceUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isApproved: isApproved ?? this.isApproved,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
