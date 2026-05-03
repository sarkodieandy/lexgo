import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../services/api_client.dart';
import '../../services/api_config.dart';
import '../../theme/app_colors.dart';

class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({super.key, required this.resourceId, required this.title});

  final String resourceId;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Construct the endpoint URI for the proxy download.
    final uri = Uri.parse('${ApiConfig.coursesBaseUrl}/resource/download/$resourceId');
    
    // Auth headers are required to stream the file securely from the proxy endpoint.
    final headers = ApiClient.shared.authHeaders;

    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: AppColors.brandDark,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.brandNavy,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.brandWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.brandWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SfPdfViewer.network(
                uri.toString(),
                headers: headers,
                canShowScrollHead: false,
                canShowScrollStatus: true,
                onPageChanged: (PdfPageChangedDetails details) {
                   // Tracking or reading progress if needed
                },
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to load PDF: ${details.description}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
