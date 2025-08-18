import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String username;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key,
    this.name = 'Mandira De Silva',
    this.username = '@chukuru7',
    this.avatarUrl = 'https://images.unsplash.com/photo-1564349683136-77e08dba1ef7',  // Cute panda photo
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 273,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 69,
            top: 0,
            child: Text(
              'Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                height: 1.30,
                letterSpacing: -0.30,
              ),
            ),
          ),
          
          Positioned(
            left: 57,
            top: 72,
            child: GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 114,
                height: 115,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(68),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(68),
                  child: Image.network(
                    avatarUrl ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
                    width: 93,
                    height: 93,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 93,
                        height: 93,
                        color: const Color(0xFFE0E0E0),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            left: 0,
            top: 211,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                height: 1.30,
                letterSpacing: -0.30,
              ),
            ),
          ),
          
          Positioned(
            left: 57,
            top: 255,
            child: Text(
              username,
              style: const TextStyle(
                color: Color(0xFF9D9D9D),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}