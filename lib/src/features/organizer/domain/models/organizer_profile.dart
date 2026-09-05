class OrganizerProfile {
  final String id;
  final String name;
  final String username;
  final String bio;
  final String avatarUrl;
  final String instagramHandle;
  final String phoneNumber;
  final String countryCode;
  final int followerCount;
  final List<String> photoUrls;
  final List<String> videoThumbnails;
  final bool isVerified;

  const OrganizerProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.avatarUrl,
    required this.instagramHandle,
    required this.phoneNumber,
    this.countryCode = '+1',
    required this.followerCount,
    required this.photoUrls,
    this.videoThumbnails = const [],
    this.isVerified = false,
  });

  OrganizerProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? bio,
    String? avatarUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? countryCode,
    int? followerCount,
    List<String>? photoUrls,
    List<String>? videoThumbnails,
    bool? isVerified,
  }) {
    return OrganizerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      followerCount: followerCount ?? this.followerCount,
      photoUrls: photoUrls ?? this.photoUrls,
      videoThumbnails: videoThumbnails ?? this.videoThumbnails,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get displayHandle {
    final cleaned = username.trim().replaceAll(RegExp(r'^@'), '');
    return '@$cleaned';
  }

  String get followerCountLabel {
    if (followerCount >= 1000) {
      final inK = (followerCount / 1000).toStringAsFixed(1);
      return '${inK.endsWith(".0") ? inK.substring(0, inK.length - 2) : inK}k followers';
    }
    return '$followerCount followers';
  }
}
