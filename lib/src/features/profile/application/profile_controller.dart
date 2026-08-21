import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSeed {
  final String fullName;
  final String? username;
  final String location;
  final String gender;
  final int heightCm;
  final String instagramUsername;
  final int? age;
  final String? bio;
  final List<String> photoUrls;
  final bool isFaceVerified;

  const ProfileSeed({
    required this.fullName,
    this.username,
    required this.location,
    required this.gender,
    required this.heightCm,
    required this.instagramUsername,
    this.age,
    this.bio,
    required this.photoUrls,
    required this.isFaceVerified,
  });
}

class ProfileState {
  final String fullName;
  final String username;
  final int age;
  final String bio;
  final String location;
  final String gender;
  final int heightCm;
  final String instagramUsername;
  final List<String> photoUrls;
  final bool isFaceVerified;

  const ProfileState({
    required this.fullName,
    required this.username,
    required this.age,
    required this.bio,
    required this.location,
    required this.gender,
    required this.heightCm,
    required this.instagramUsername,
    required this.photoUrls,
    required this.isFaceVerified,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      fullName: 'raghav',
      username: 'den48291',
      age: 24,
      bio: '',
      location: 'New York, NY',
      gender: 'Male',
      heightCm: 178,
      instagramUsername: 'elenaspace',
      photoUrls: [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80',
      ],
      isFaceVerified: false,
    );
  }

  ProfileState copyWith({
    String? fullName,
    String? username,
    int? age,
    String? bio,
    String? location,
    String? gender,
    int? heightCm,
    String? instagramUsername,
    List<String>? photoUrls,
    bool? isFaceVerified,
  }) {
    return ProfileState(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      instagramUsername: instagramUsername ?? this.instagramUsername,
      photoUrls: photoUrls ?? this.photoUrls,
      isFaceVerified: isFaceVerified ?? this.isFaceVerified,
    );
  }

  String get heightLabel {
    final feet = (heightCm / 30.48).floor();
    final inches = (((heightCm / 2.54) - (feet * 12))).round();
    return "$feet'$inches\"";
  }

  String get displayHandle {
    final cleaned = username.trim().replaceAll(RegExp(r'^@'), '');
    return '@$cleaned';
  }
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => ProfileState.initial();

  static String generateUniqueDenUsername() {
    final randomNum = 10000 + Random().nextInt(90000);
    return 'den$randomNum';
  }

  void seedFromOnboarding(ProfileSeed seed) {
    final generatedUsername = (seed.username != null && seed.username!.trim().isNotEmpty)
        ? seed.username!.trim().replaceAll(RegExp(r'^@'), '')
        : generateUniqueDenUsername();

    state = state.copyWith(
      fullName: seed.fullName.trim().isEmpty ? state.fullName : seed.fullName.trim(),
      username: generatedUsername,
      age: seed.age ?? state.age,
      location: seed.location.trim().isEmpty ? state.location : seed.location.trim(),
      gender: seed.gender.trim().isEmpty ? state.gender : seed.gender.trim(),
      heightCm: seed.heightCm > 0 ? seed.heightCm : state.heightCm,
      instagramUsername: seed.instagramUsername.trim().isEmpty
          ? state.instagramUsername
          : seed.instagramUsername.trim().replaceAll(RegExp(r'^@'), ''),
      photoUrls: seed.photoUrls.isEmpty ? state.photoUrls : List<String>.from(seed.photoUrls),
      bio: (seed.bio != null && seed.bio!.trim().isNotEmpty) ? seed.bio!.trim() : state.bio,
      isFaceVerified: seed.isFaceVerified,
    );
  }

  void updateFullName(String name) {
    if (name.trim().isNotEmpty) {
      state = state.copyWith(fullName: name.trim());
    }
  }

  bool updateUsername(String username) {
    final normalized = username.trim().replaceAll(RegExp(r'^@'), '').toLowerCase();
    if (normalized.length < 3) return false;
    state = state.copyWith(username: normalized);
    return true;
  }

  void updateBio(String bio) {
    state = state.copyWith(bio: bio.trim());
  }

  void updateInstagram(String handle) {
    state = state.copyWith(instagramUsername: handle.trim().replaceAll(RegExp(r'^@'), ''));
  }

  void updateAge(int age) {
    if (age >= 18) {
      state = state.copyWith(age: age);
    }
  }

  void updateGender(String gender) {
    if (gender.trim().isNotEmpty) {
      state = state.copyWith(gender: gender.trim());
    }
  }

  void updateHeight(int heightCm) {
    if (heightCm > 0) {
      state = state.copyWith(heightCm: heightCm);
    }
  }

  void updateLocation(String loc) {
    if (loc.trim().isNotEmpty) {
      state = state.copyWith(location: loc.trim());
    }
  }

  void updatePhotos(List<String> photos) {
    state = state.copyWith(photoUrls: List<String>.from(photos));
  }

  void updateFaceVerification(bool isVerified) {
    state = state.copyWith(isFaceVerified: isVerified);
  }
}

final profileStateProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
