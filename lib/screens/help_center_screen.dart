import 'package:flutter/material.dart';

import '../models/help_center/help_center_option.dart';
import '../theme/app_colors.dart';
import '../widgets/help_action_card.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<HelpCenterOption> _options = [
    HelpCenterOption(
      icon: Icons.chat_bubble_outline,
      title:
          'Get quick answers through our live chat. Our support team is available to guide you with anything related to courses, grading, or account setup.',
      actionLabel: 'Chat with Us',
    ),
    HelpCenterOption(
      icon: Icons.mail_outline,
      title:
          'If your issue requires more detail, you can email us directly. We’ll get back to you as soon as possible with a full response.',
      actionLabel: 'Send an Email',
    ),
    HelpCenterOption(
      icon: Icons.call_outlined,
      title:
          'Need urgent help? Call our support line for direct assistance with your lecturer account or technical problems.',
      actionLabel: 'Call us',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: Column(
        children: [
          HelpCenterHeader(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _options.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 24),
                itemBuilder: (context, index) =>
                    HelpActionCard(option: _options[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpCenterHeader extends StatelessWidget {
  const HelpCenterHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.brandDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          _BackButton(onPressed: onBack),
          const SizedBox(width: 16),
          const Expanded(
            child: Center(
              child: Text(
                'Help Center',
                style: TextStyle(
                  color: AppColors.brandWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.brandWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.brandDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}
