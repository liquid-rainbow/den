import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/organizer_profile.dart';

enum ProfileMode {
  user,
  organizer,
}

class OrganizerDraftState {
  final String name;
  final String username;
  final String avatarUrl;
  final String instagramHandle;
  final String phoneNumber;
  final String countryCode;

  const OrganizerDraftState({
    this.name = '',
    this.username = '',
    this.avatarUrl = '',
    this.instagramHandle = '',
    this.phoneNumber = '',
    this.countryCode = '+1',
  });

  OrganizerDraftState copyWith({
    String? name,
    String? username,
    String? avatarUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? countryCode,
  }) {
    return OrganizerDraftState(
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}

class OrganizerState {
  final OrganizerProfile? profile;
  final OrganizerDraftState draft;
  final ProfileMode activeMode;

  const OrganizerState({
    this.profile,
    this.draft = const OrganizerDraftState(),
    this.activeMode = ProfileMode.user,
  });

  bool get hasOrganizerProfile => profile != null;

  OrganizerState copyWith({
    OrganizerProfile? Function()? profile,
    OrganizerDraftState? draft,
    ProfileMode? activeMode,
  }) {
    return OrganizerState(
      profile: profile != null ? profile() : this.profile,
      draft: draft ?? this.draft,
      activeMode: activeMode ?? this.activeMode,
    );
  }
}

class OrganizerController extends Notifier<OrganizerState> {
  @override
  OrganizerState build() {
    // Default initial state starts with no organizer profile until user creates it,
    // or seeds with an initial state for testing/demo if needed.
    return const OrganizerState();
  }

  void updateDraft({
    String? name,
    String? username,
    String? avatarUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? countryCode,
  }) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        name: name,
        username: username,
        avatarUrl: avatarUrl,
        instagramHandle: instagramHandle,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      ),
    );
  }

  void resetDraft() {
    state = state.copyWith(draft: const OrganizerDraftState());
  }

  void completeSetup() {
    final draft = state.draft;
    final normalizedUsername = draft.username.trim().replaceAll(RegExp(r'^@'), '');
    final finalUsername = normalizedUsername.isNotEmpty ? normalizedUsername : 'aura_collective';
    final finalName = draft.name.trim().isNotEmpty ? draft.name.trim() : 'Aura Collective';
    final finalAvatar = draft.avatarUrl.isNotEmpty
        ? draft.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80';

    final createdProfile = OrganizerProfile(
      id: 'org_${DateTime.now().millisecondsSinceEpoch}',
      name: finalName,
      username: finalUsername,
      bio: 'Curating intentional spaces for deep connection and artistic expression. We host intimate gatherings designed for those who seek depth over noise.',
      avatarUrl: finalAvatar,
      instagramHandle: draft.instagramHandle.trim().replaceAll(RegExp(r'^@'), ''),
      phoneNumber: draft.phoneNumber.trim(),
      countryCode: draft.countryCode,
      followerCount: 2500,
      photoUrls: const [
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80',
      ],
      videoThumbnails: const [
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=800&q=80',
      ],
      isVerified: true,
    );

    state = state.copyWith(
      profile: () => createdProfile,
      activeMode: ProfileMode.organizer,
      draft: const OrganizerDraftState(),
    );
  }

  void updateProfile({
    String? name,
    String? username,
    String? bio,
    String? avatarUrl,
    String? instagramHandle,
    String? phoneNumber,
    List<String>? photoUrls,
  }) {
    if (state.profile == null) return;
    state = state.copyWith(
      profile: () => state.profile!.copyWith(
        name: name,
        username: username?.trim().replaceAll(RegExp(r'^@'), ''),
        bio: bio,
        avatarUrl: avatarUrl,
        instagramHandle: instagramHandle?.trim().replaceAll(RegExp(r'^@'), ''),
        phoneNumber: phoneNumber,
        photoUrls: photoUrls,
      ),
    );
  }

  void switchMode(ProfileMode mode) {
    state = state.copyWith(activeMode: mode);
  }

  void deleteOrganizerProfile() {
    state = state.copyWith(
      profile: () => null,
      activeMode: ProfileMode.user,
      draft: const OrganizerDraftState(),
    );
  }
}

final organizerProvider =
    NotifierProvider<OrganizerController, OrganizerState>(OrganizerController.new);
