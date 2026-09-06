import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/image_crop_adjust_dialog.dart';
import '../../application/organizer_controller.dart';
import '../theme/organizer_theme.dart';

class OrganizerSetupScreen extends ConsumerStatefulWidget {
  const OrganizerSetupScreen({super.key});

  @override
  ConsumerState<OrganizerSetupScreen> createState() => _OrganizerSetupScreenState();
}

class _OrganizerSetupScreenState extends ConsumerState<OrganizerSetupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  String? _pickedAvatarPath;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(organizerProvider).draft;
    _nameController = TextEditingController(text: draft.name);
    _usernameController = TextEditingController(text: draft.username);
    _pickedAvatarPath = draft.avatarUrl.isNotEmpty ? draft.avatarUrl : null;
  }

  @override
  void dispose() {
    _nameController.dispose;
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted || image == null) return;

    final adjustedImage = await ImageCropAdjustDialog.show(context, image);
    if (adjustedImage != null) {
      setState(() {
        _pickedAvatarPath = adjustedImage.path;
      });
      ref.read(organizerProvider.notifier).updateDraft(avatarUrl: adjustedImage.path);
    }
  }

  void _onContinue() {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().replaceAll(RegExp(r'^@'), '');

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an organization or event name')),
      );
      return;
    }
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a username')),
      );
      return;
    }

    ref.read(organizerProvider.notifier).updateDraft(
          name: name,
          username: username,
          avatarUrl: _pickedAvatarPath ?? '',
        );

    context.push('/organizer/instagram');
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // Title
              const Text(
                'Setup Your Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 32),

              // Avatar upload area with edit badge
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OrganizerColors.surfaceContainer,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _pickedAvatarPath != null
                          ? (_pickedAvatarPath!.startsWith('http')
                              ? Image.network(_pickedAvatarPath!, fit: BoxFit.cover)
                              : Image.file(File(_pickedAvatarPath!), fit: BoxFit.cover))
                          : const Center(
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                size: 44,
                                color: OrganizerColors.primaryFixedDim,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: OrganizerColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: OrganizerColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: OrganizerColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Upload image',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: OrganizerColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 36),

              // Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: OrganizerColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: OrganizerColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: OrganizerColors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: Icon(Icons.person_outline, color: OrganizerColors.onSurfaceVariant),
                        hintText: 'e.g. Neon Nights Events',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9AA7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Username Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: OrganizerColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: OrganizerColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: OrganizerColors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: Icon(Icons.alternate_email, color: OrganizerColors.onSurfaceVariant),
                        hintText: 'neonnights',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9AA7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This will be your username for this app',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8A8594),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Bottom CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: OrganizerColors.onPrimary,
                    elevation: 4,
                    shadowColor: OrganizerColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
