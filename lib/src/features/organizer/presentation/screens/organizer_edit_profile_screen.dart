import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/image_crop_adjust_dialog.dart';
import '../../application/organizer_controller.dart';
import '../theme/organizer_theme.dart';

class OrganizerEditProfileScreen extends ConsumerStatefulWidget {
  const OrganizerEditProfileScreen({super.key});

  @override
  ConsumerState<OrganizerEditProfileScreen> createState() =>
      _OrganizerEditProfileScreenState();
}

class _OrganizerEditProfileScreenState
    extends ConsumerState<OrganizerEditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _igController;
  late final TextEditingController _phoneController;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(organizerProvider).profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _usernameController = TextEditingController(text: profile?.username ?? '');
    _igController = TextEditingController(text: profile?.instagramHandle ?? '');
    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');
    _avatarPath = profile?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _igController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted || image == null) return;

    final adjustedImage = await ImageCropAdjustDialog.show(context, image);
    if (adjustedImage != null) {
      setState(() => _avatarPath = adjustedImage.path);
    }
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().replaceAll(RegExp(r'^@'), '');
    final ig = _igController.text.trim().replaceAll(RegExp(r'^@'), '');
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    ref.read(organizerProvider.notifier).updateProfile(
          name: name,
          username: username,
          instagramHandle: ig,
          phoneNumber: phone,
          avatarUrl: _avatarPath,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved!'),
        backgroundColor: OrganizerColors.tertiaryContainer,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: OrganizerColors.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'DONE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: OrganizerColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Profile Photo with Camera icon overlay
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: OrganizerColors.surfaceContainer,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _avatarPath != null && _avatarPath!.isNotEmpty
                              ? (_avatarPath!.startsWith('http')
                                  ? Image.network(_avatarPath!, fit: BoxFit.cover)
                                  : Image.file(File(_avatarPath!), fit: BoxFit.cover))
                              : const Icon(
                                  Icons.person,
                                  size: 52,
                                  color: OrganizerColors.outline,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: OrganizerColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: OrganizerColors.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: const Text(
                      'Change Photo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: OrganizerColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name Field
            _buildFieldGroup(
              label: 'NAME',
              icon: Icons.person_outline,
              controller: _nameController,
              hint: 'Enter your name',
            ),
            const SizedBox(height: 20),

            // Username Field
            _buildFieldGroup(
              label: 'USERNAME',
              icon: Icons.alternate_email,
              controller: _usernameController,
              hint: 'Choose a username',
            ),
            const SizedBox(height: 20),

            // Instagram Field with Verify Action
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'INSTAGRAM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: OrganizerColors.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/organizer/verify-phone');
                      },
                      child: const Text(
                        'VERIFY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: OrganizerColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: OrganizerColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Text(
                        '@',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _igController,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: OrganizerColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: 'Your IG handle',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0AAB9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Phone Number Field
            _buildFieldGroup(
              label: 'PHONE NUMBER',
              icon: Icons.phone_iphone_outlined,
              controller: _phoneController,
              hint: '+1 (555) 019-2834',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldGroup({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: OrganizerColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: OrganizerColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: OrganizerColors.outline),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OrganizerColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0AAB9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
