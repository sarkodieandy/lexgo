import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/help_action_card.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<HelpCenterOption> _options = [
    HelpCenterOption(
      icon: Icons.chat_bubble_outline,
      title: 'Get quick answers through our live chat.',
      actionLabel: 'Chat with Us',
    ),
    HelpCenterOption(
      icon: Icons.mail_outline,
      title: 'If your issue requires more detail, you can email us directly.',
      actionLabel: 'Send an Email',
    ),
    HelpCenterOption(
      icon: Icons.call_outlined,
      title: 'Need urgent help? Call our support line for direct assistance.',
      actionLabel: 'Call us',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: Column(
        children: [
          const _HelpCenterHeader(),
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

class _HelpCenterHeader extends StatelessWidget {
  const _HelpCenterHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 28, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.brandDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.brandWhite),
            ),
          ),
          Center(
            child: Text(
              'Help Center',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.brandWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
