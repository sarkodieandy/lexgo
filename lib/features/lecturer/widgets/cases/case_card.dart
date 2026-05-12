import 'package:flutter/material.dart';

import '../../models/cases/case_item.dart';
import '../../screens/cases/case_details_screen.dart';
import '../../theme/app_colors.dart';

class CaseCard extends StatelessWidget {
  const CaseCard({super.key, required this.item});

  final CaseItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.brandWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContent(),
                const SizedBox(height: 20),
                _buildReadButton(context),
              ],
            ),
          ),
          _buildWatermark(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1D2939),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.subtitle,
          style: const TextStyle(
            color: Color(0xFF475467),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.code,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        _buildTag(),
      ],
    );
  }

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: item.tagColor.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.balance,
            size: 16,
            color: item.tagColor,
          ),
          const SizedBox(width: 6),
          Text(
            item.tag,
            style: TextStyle(
              color: item.tagColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CaseDetailsScreen(item: item),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: Color(0xFFE4E7EC), width: 1.5),
          foregroundColor: const Color(0xFF344054),
        ),
        child: const Text(
          'Read',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWatermark() {
    return Positioned(
      right: 0,
      top: 10,
      child: Opacity(
        opacity: 0.04,
        child: Icon(
          Icons.balance,
          size: 140,
          color: Colors.black,
        ),
      ),
    );
  }
}
