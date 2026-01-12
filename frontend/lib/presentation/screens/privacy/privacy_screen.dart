import 'package:flutter/material.dart';
import '../../widgets/main_layout.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Privacy Policy',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your privacy is important to us. It is URLens\' policy to respect your privacy regarding any information we may collect from you across our application.\n\n'
                  '1. Information Collection\n'
                  'We do not collect any personal data. URLens operates locally on your device.\n\n'
                  '2. External Links\n'
                  'Our app may link to external sites that are not operated by us. Please be aware that we have no control over the content and practices of these sites.\n\n'
                  '3. Contact Us\n'
                  'If you have any questions about our privacy policy, please contact us.',
                  style: TextStyle(height: 1.6, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
