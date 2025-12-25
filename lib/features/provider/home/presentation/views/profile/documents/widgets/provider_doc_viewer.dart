// lib/features/provider/home/presentation/views/profile/documents/widgets/provider_doc_viewer.dart

import 'package:flutter/material.dart';

import 'package:beitak_app/core/network/api_constants.dart';
import 'package:beitak_app/core/network/token_provider.dart';

class ProviderDocViewer {
  static Future<void> open({
    required BuildContext context,
    required String fileName,
    String? title,
  }) async {
    final url = ApiConstants.providerDocUrl(fileName);
    final headers = await _buildAuthHeaders();

    if (_isImage(fileName)) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => _ImageViewerDialog(
          title: title ?? 'عرض الملف',
          url: url,
          headers: headers,
        ),
      );
      return;
    }

    // PDF أو غيره: بحاجة حل خاص (Signed URL / bytes endpoint)
    final msg = _isPdf(fileName)
        ? 'PDF يحتاج رابط مباشر عام أو Signed URL من الباك.'
        : 'هذا النوع يحتاج دعم إضافي من الباك (Signed URL / streaming).';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  static bool _isImage(String name) {
    final n = name.toLowerCase();
    return n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.png') ||
        n.endsWith('.webp');
  }

  static bool _isPdf(String name) => name.toLowerCase().endsWith('.pdf');

  static Future<Map<String, String>?> _buildAuthHeaders() async {
    final token = await TokenProvider.getToken();
    if (token == null || token.trim().isEmpty) return null;
    return <String, String>{'Authorization': 'Bearer $token'};
  }
}

class _ImageViewerDialog extends StatelessWidget {
  final String title;
  final String url;
  final Map<String, String>? headers;

  const _ImageViewerDialog({
    required this.title,
    required this.url,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogHeader(title: title),
          const Divider(height: 1),
          Flexible(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.network(
                url,
                headers: headers,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'تعذر فتح الصورة.\n'
                      'تأكد من مسار الملفات في ApiConstants.providerDocsPath\n'
                      'URL: $url',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final String title;

  const _DialogHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
