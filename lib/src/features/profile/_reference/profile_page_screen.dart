import 'package:flutter/material.dart';
import '../../../../src/core/widgets/mobile_device_shell.dart';

class ProfilePageScreen extends StatelessWidget {
  const ProfilePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileDeviceShell(
      outerBackgroundColor: const Color(0xFFF3F2F0),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _HeaderBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      const _ProfileInfoSection(),
                      const SizedBox(height: 8),
                      const _ActionButtonsSection(),
                      const SizedBox(height: 8),
                      const _ContentTabs(),
                      const SizedBox(height: 2),
                      const _PostsGrid(),
                    ],
                  ),
                ),
              ),
              const _BottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'username',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -0.4,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.black87, size: 30),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.share_outlined, color: Colors.black87, size: 26),
              const SizedBox(width: 14),
              const Icon(Icons.edit_outlined, color: Colors.black87, size: 26),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoSection extends StatelessWidget {
  const _ProfileInfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 149,
                height: 149,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE6E3E1)),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'raghav',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: TextField(
              maxLength: 99,
              maxLines: 2,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Add a bio...',
                counterText: '',
              ),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Expanded(
                child: _InfoStat(icon: Icons.cake_outlined, value: '24'),
              ),
              _VerticalDivider(),
              Expanded(
                child: _InfoStat(icon: Icons.male, value: 'Male'),
              ),
              _VerticalDivider(),
              Expanded(
                child: _InfoStat(icon: Icons.height, value: '5\'10"'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Column(
            children: [
              _ThinDivider(),
              SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF757575),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'New York, NY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              _ThinDivider(),
              SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF757575),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '@elenaspace',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              _ThinDivider(),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF757575), size: 18),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 24, color: const Color(0xFFBDBDBD));
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(width: 48, height: 1, color: const Color(0x33000000)),
    );
  }
}

class _ActionButtonsSection extends StatelessWidget {
  const _ActionButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              shape: const CircleBorder(),
              side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
              backgroundColor: Colors.white,
            ),
            child: const Icon(Icons.close, color: Colors.black87, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3E2723),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text(
                  'invite',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentTabs extends StatelessWidget {
  const _ContentTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0)),
          bottom: BorderSide(color: Color(0xFFF0F0F0)),
        ),
      ),
      child: Row(
        children: const [
          Expanded(child: _TabIcon(icon: Icons.grid_on_outlined, active: true)),
          Expanded(child: _TabIcon(icon: Icons.play_circle_outline)),
          Expanded(child: _TabIcon(icon: Icons.person_outline)),
        ],
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _TabIcon({required this.icon, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        icon,
        size: 22,
        color: active ? const Color(0xFF1E1E1E) : const Color(0xFF9E9E9E),
      ),
    );
  }
}

class _PostsGrid extends StatelessWidget {
  const _PostsGrid();

  @override
  Widget build(BuildContext context) {
    final posts = <_PostTileData>[
      const _PostTileData(
        imageUrl:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
        views: '898',
      ),
      const _PostTileData(
        imageUrl:
            'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=900&q=80',
        views: '2,116',
      ),
      const _PostTileData(
        imageUrl:
            'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=900&q=80',
        views: '2,406',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      padding: const EdgeInsets.only(bottom: 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        if (index < posts.length) {
          return _PostTile(data: posts[index]);
        }
        return Container(color: const Color(0xFFF7F7F7));
      },
    );
  }
}

class _PostTileData {
  final String imageUrl;
  final String views;

  const _PostTileData({required this.imageUrl, required this.views});
}

class _PostTile extends StatelessWidget {
  final _PostTileData data;

  const _PostTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(data.imageUrl, fit: BoxFit.cover),
        const Positioned(
          top: 8,
          right: 8,
          child: Icon(
            Icons.collections_outlined,
            color: Colors.white,
            size: 16,
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                data.views,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavIcon(icon: Icons.home_outlined),
          _NavIcon(icon: Icons.play_circle_outline),
          _NavIcon(icon: Icons.add_circle_outline),
          _NavIcon(icon: Icons.search_outlined),
          _NavAvatar(),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;

  const _NavIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: const Color(0xFF1F1F1F), size: 28);
  }
}

class _NavAvatar extends StatelessWidget {
  const _NavAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
