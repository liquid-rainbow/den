import 'package:flutter/material.dart';

class ShareEventBottomSheet extends StatelessWidget {
  const ShareEventBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ShareEventBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: Colors.black54, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Horizontal Users List
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _UserAvatarItem(
                  name: 'User One',
                  imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&fit=crop',
                ),
                const SizedBox(width: 24),
                _UserAvatarItem(
                  name: 'User Two',
                  imageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&fit=crop',
                ),
                const SizedBox(width: 24),
                _UserAvatarItem(
                  name: 'User Three',
                  imageUrl: 'https://images.unsplash.com/photo-1531123897727-8f129e1bf98c?w=150&fit=crop',
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Bottom Actions
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BottomActionItem(
                  icon: Icons.link,
                  label: 'Copy link',
                  onTap: () {},
                ),
                const SizedBox(width: 48),
                _BottomActionItem(
                  icon: Icons.ios_share,
                  label: 'Share to...',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatarItem extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _UserAvatarItem({
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: NetworkImage(imageUrl),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BottomActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
