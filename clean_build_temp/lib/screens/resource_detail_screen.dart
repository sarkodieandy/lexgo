import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/resource.dart';
import '../services/api_config.dart';
import '../theme/app_colors.dart';

class ResourceDetailScreen extends StatelessWidget {
  const ResourceDetailScreen({super.key, required this.resource});

  final CourseResource resource;

  static const List<ResourceReadEntry> _readBy = [
    ResourceReadEntry(
      name: 'Mike Adjatey',
      id: '22189872',
      dateLabel: 'Sep 4, 2025',
      timeLabel: '06:00AM',
      color: Color(0xFFED0A2C),
    ),
    ResourceReadEntry(
      name: 'Andrew Kaine',
      id: '22153103',
      dateLabel: 'Sep 4, 2025',
      timeLabel: '07:00AM',
      color: Color(0xFF9C1F9C),
    ),
    ResourceReadEntry(
      name: 'Kofi',
      id: '22125693',
      dateLabel: 'Sep 4, 2025',
      timeLabel: '07:00AM',
      color: Color(0xFF070B91),
    ),
    ResourceReadEntry(
      name: 'Kojo',
      id: '22195055',
      dateLabel: 'Sep 5, 2025',
      timeLabel: '07:00AM',
      color: Color(0xFF7F3FD1),
    ),
    ResourceReadEntry(
      name: 'Yaw',
      id: '22174641',
      dateLabel: 'Sep 6, 2025',
      timeLabel: '01:00PM',
      color: Color(0xFFF7B500),
    ),
    ResourceReadEntry(
      name: 'Ama',
      id: '22130074',
      dateLabel: 'Sep 7, 2025',
      timeLabel: '05:00PM',
      color: Color(0xFFFFD600),
    ),
    ResourceReadEntry(
      name: 'Kwesi',
      id: '22191057',
      dateLabel: 'Sep 8, 2025',
      timeLabel: '12:00PM',
      color: Color(0xFF4931FF),
    ),
  ];

  static const List<ResourceReadEntry> _yetToOpen = [
    ResourceReadEntry(
      name: 'Ama',
      id: '22130074',
      dateLabel: 'Sep 7, 2025',
      timeLabel: '05:00PM',
      color: Color(0xFFF7B500),
    ),
    ResourceReadEntry(
      name: 'Kojo',
      id: '22195055',
      dateLabel: 'Sep 5, 2025',
      timeLabel: '07:00AM',
      color: Color(0xFF7F3FD1),
    ),
    ResourceReadEntry(
      name: 'Kofi Kaine',
      id: '22189872',
      dateLabel: 'Sep 4, 2025',
      timeLabel: '06:00AM',
      color: Color(0xFFB20A07),
    ),
    ResourceReadEntry(
      name: 'Andrew Kaine',
      id: '22153103',
      dateLabel: 'Sep 4, 2025',
      timeLabel: '07:00AM',
      color: Color(0xFF9C1F9C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final downloadUrl = resource.downloadUrl;
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B2138),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.brandWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Resource Info',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.brandWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                  color: AppColors.brandWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6E2FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.insert_drive_file,
                                color: AppColors.brandDark,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                resource.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brandDark,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: downloadUrl == null ? null : 'Download',
                              onPressed: downloadUrl == null
                                  ? null
                                  : () async {
                                      final uri = downloadUrl.startsWith('http')
                                          ? Uri.parse(downloadUrl)
                                          : ApiConfig.resolve(downloadUrl);
                                      final launched = await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                      if (!launched && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Unable to open download link',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              icon: const Icon(
                                Icons.download_rounded,
                                color: AppColors.brandDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        resource.formattedTimestamp,
                        style: const TextStyle(color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Read By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._readBy.map(
                        (entry) => _ResourceReadTile(entry: entry),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Yet to Open',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._yetToOpen.map(
                        (entry) => _ResourceReadTile(entry: entry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResourceReadEntry {
  const ResourceReadEntry({
    required this.name,
    required this.id,
    required this.dateLabel,
    required this.timeLabel,
    required this.color,
  });

  final String name;
  final String id;
  final String dateLabel;
  final String timeLabel;
  final Color color;
}

class _ResourceReadTile extends StatelessWidget {
  const _ResourceReadTile({required this.entry});

  final ResourceReadEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: entry.color,
            child: Text(
              entry.name[0],
              style: const TextStyle(color: AppColors.brandWhite),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.id,
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.dateLabel,
                style: const TextStyle(color: AppColors.mutedText),
              ),
              const SizedBox(height: 4),
              Text(
                entry.timeLabel,
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
