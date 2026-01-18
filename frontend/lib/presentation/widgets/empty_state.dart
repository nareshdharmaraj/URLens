import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        // Prevent overflow on small screens
        padding: const EdgeInsets.all(32.0),
        child: FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[const SizedBox(height: 32), action!],
            ],
          ),
        ),
      ),
    );
  }
}
