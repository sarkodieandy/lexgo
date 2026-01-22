import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<_HelpOption> _options = [
    _HelpOption(
      title: 'Chat with us',
      detail:
          'Live agents are available 24/7 to answer questions about courses, grading, and onboarding.',
      action: 'Chat now',
      icon: Icons.chat_bubble_outline,
      iconBackground: Color(0xFFFCECBB),
    ),
    _HelpOption(
      title: 'Send an email',
      detail:
          'Email us your request and we’ll respond within 2 hours with guidance.',
      action: 'Send email',
      icon: Icons.mail_outline,
      iconBackground: Color(0xFFE7F0FF),
    ),
    _HelpOption(
      title: 'Call support',
      detail:
          'Call our support line for urgent lecturer or technical help between 6am–10pm.',
      action: 'Call us',
      icon: Icons.call_outlined,
      iconBackground: Color(0xFFE9F5EF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.brandDark,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.scale, color: AppColors.brandDark),
            ),
            const SizedBox(width: 12),
            const Text('Help Center'),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.brandDark,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need help?',
                    style: TextStyle(
                      color: AppColors.brandWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Our support team is ready to assist with anything LexGo-related, from course setup to account questions.',
                    style: TextStyle(
                      color: AppColors.brandAccent,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ..._options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _HelpTile(option: option),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpOption {
  final String title;
  final String detail;
  final String action;
  final IconData icon;
  final Color iconBackground;

  const _HelpOption({
    required this.title,
    required this.detail,
    required this.action,
    required this.icon,
    required this.iconBackground,
  });
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.option});

  final _HelpOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: option.iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, color: AppColors.brandDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.detail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.brandDark,
                foregroundColor: AppColors.brandWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(option.action),
            ),
          ),
        ],
      ),
    );
  }
}
