import 'package:flutter/material.dart';

class TopicResourcesScreen extends StatelessWidget {
  const TopicResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildResourceItem(
          'Introduction to Constitutional Law 1',
          '1MB • Sept 7 2025 • 10:00AM',
        ),
        const Divider(),
        _buildResourceItem(
          'Introduction to Constitutional Law 2',
          '1MB • Sept 7 2025 • 10:00AM',
        ),
        const Divider(),
        _buildResourceItem(
          'Introduction to Constitutional Law 3',
          '2MB • Sept 8 2025 • 11:00AM',
        ),
        const Divider(),
        _buildResourceItem(
          'Introduction to Constitutional Law 4',
          '1.5MB • Sept 9 2025 • 09:00AM',
        ),
        const Divider(),
        _buildResourceItem(
          'Introduction to Constitutional Law 5',
          '3.1MB • Sept 10 2025 • 08:30AM',
        ),
      ],
    );
  }

  Widget _buildResourceItem(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Colors.green),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () {
          // Implement download logic
        },
      ),
    );
  }
}
