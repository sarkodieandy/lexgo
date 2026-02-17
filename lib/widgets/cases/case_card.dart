import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cases/case_item.dart';
import '../../theme/app_colors.dart';

class CaseCard extends StatelessWidget {
  const CaseCard({super.key, required this.item});

  final CaseItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.brandWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: TextStyle(color: AppColors.mutedText, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  item.code,
                  style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.tagColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/Union.png',
                        width: 18,
                        height: 18,
                        color: item.tagColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.tag,
                        style: TextStyle(color: item.tagColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final hasUrl = item.documentUrl?.isNotEmpty == true;
                      if (!hasUrl) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Document not available yet'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      final uri = Uri.tryParse(item.documentUrl!);
                      if (uri == null) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Invalid document URL'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      final launched = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (!launched && context.mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Unable to open document'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: AppColors.brandDark, width: 1.5),
                      foregroundColor: AppColors.brandDark,
                    ),
                    child: const Text('Read'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 8,
            child: Image.asset(
              'assets/Union.png',
              width: 120,
              height: 120,
              color: AppColors.brandDark.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }
}
