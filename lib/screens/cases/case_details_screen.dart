import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cases/case_item.dart';
import '../../theme/app_colors.dart';

class CaseDetailsScreen extends StatelessWidget {
  const CaseDetailsScreen({super.key, required this.item});

  final CaseItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTag(),
                  const SizedBox(height: 16),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.code,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedText.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    'Case Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This case involves a detailed legal analysis of the relevant statutes and precedents. The ruling provides clarity on the administrative procedures and the scope of judicial review in cases of this nature.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.brandDark,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Spacer(),
                ],
              ),
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      decoration: const BoxDecoration(color: AppColors.brandDark),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Text(
            'Case Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: item.tagColor.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.balance, size: 16, color: item.tagColor),
          const SizedBox(width: 8),
          Text(
            item.tag,
            style: TextStyle(
              color: item.tagColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (item.documentUrl != null) {
                  final uri = Uri.parse(item.documentUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('View Original Document', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
