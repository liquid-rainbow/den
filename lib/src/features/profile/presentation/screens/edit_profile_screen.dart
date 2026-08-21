import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app.dart';
import '../../../../core/widgets/image_crop_adjust_dialog.dart';
import '../../../profile/application/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _instagramController;
  late final TextEditingController _locationController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileStateProvider);
    final auth = ref.read(authStateProvider);
    _nameController = TextEditingController(text: profile.fullName);
    _usernameController = TextEditingController(text: profile.username);
    _instagramController = TextEditingController(text: profile.instagramUsername);
    _locationController = TextEditingController(text: profile.location);
    _phoneController = TextEditingController(text: auth.phoneNumber ?? '+91 99999 99999');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _instagramController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndChangePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted || image == null) return;

    final adjusted = await ImageCropAdjustDialog.show(context, image);
    if (adjusted != null) {
      final profile = ref.read(profileStateProvider);
      final updatedPhotos = [adjusted.path, ...profile.photoUrls.skip(1)];
      ref.read(profileStateProvider.notifier).updatePhotos(updatedPhotos);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!')),
        );
      }
    }
  }

  void _saveAndDone() {
    final notifier = ref.read(profileStateProvider.notifier);
    notifier.updateFullName(_nameController.text);
    notifier.updateUsername(_usernameController.text);
    notifier.updateInstagram(_instagramController.text);
    notifier.updateLocation(_locationController.text);

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile/settings');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile/settings');
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF5B21B6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveAndDone,
            child: const Text(
              'DONE',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5B21B6),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Pencil & Change Photo Label
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E2EC), width: 2),
                          ),
                          child: ClipOval(
                            child: _buildAvatar(profile.photoUrls.isNotEmpty
                                ? profile.photoUrls.first
                                : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80'),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: GestureDetector(
                            onTap: _pickAndChangePhoto,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF5B21B6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickAndChangePhoto,
                      child: const Text(
                        'Change Photo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5B21B6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 1. NAME
              _buildFieldCard(
                label: 'NAME',
                icon: Icons.person_outline,
                controller: _nameController,
                hintText: 'Your name',
              ),
              const SizedBox(height: 16),

              // 2. USERNAME
              _buildFieldCard(
                label: 'USERNAME',
                icon: Icons.alternate_email,
                controller: _usernameController,
                hintText: 'username',
                prefixText: '@',
              ),
              const SizedBox(height: 16),

              // 3. INSTAGRAM (with VERIFY button)
              _buildFieldCard(
                label: 'INSTAGRAM',
                icon: Icons.alternate_email,
                controller: _instagramController,
                hintText: 'instagram_handle',
                trailingAction: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Instagram verification coming soon!')),
                    );
                  },
                  child: const Text(
                    'VERIFY',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5B21B6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. LOCATION
              _buildFieldCard(
                label: 'LOCATION',
                icon: Icons.location_on_outlined,
                controller: _locationController,
                hintText: 'New York, NY',
              ),
              const SizedBox(height: 16),

              // 5. PHONE NUMBER
              _buildFieldCard(
                label: 'PHONE NUMBER',
                icon: Icons.phone_android,
                controller: _phoneController,
                hintText: '+91 99999 99999',
              ),
              const SizedBox(height: 20),

              // 6. GHOST MODE Nav Row Card
              InkWell(
                onTap: () => context.push('/profile/ghost-mode'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E7EC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'GHOST MODE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.black87, size: 24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    String? prefixText,
    Widget? trailingAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A4A4A),
                letterSpacing: 0.5,
              ),
            ),
            ?trailingAction,
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E7EC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    prefixText: prefixText,
                    prefixStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    hintText: hintText,
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(String url) {
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.person, color: Colors.black26)),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.person, color: Colors.black26)),
      );
    }
  }
}
