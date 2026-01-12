import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Platform icon widget
class PlatformIcon extends StatelessWidget {
  final String platform;
  final double size;

  const PlatformIcon({super.key, required this.platform, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getPlatformColor(platform),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getPlatformIcon(platform),
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return Icons.play_arrow;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
      case 'x':
        return Icons.tag;
      case 'facebook':
        return Icons.facebook;
      case 'tiktok':
        return Icons.music_note;
      case 'vimeo':
        return Icons.videocam;
      default:
        return Icons.public;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return AppColors.youtube;
      case 'instagram':
        return AppColors.instagram;
      case 'twitter':
      case 'x':
        return AppColors.twitter;
      case 'facebook':
        return AppColors.facebook;
      case 'tiktok':
        return AppColors.tiktok;
      default:
        return AppColors.primary;
    }
  }
}
