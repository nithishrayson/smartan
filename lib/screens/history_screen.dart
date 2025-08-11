import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyData = [
      {"timestamp": "2025-08-11 10:00", "imagePath": "", "keypoints": "{}"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: ListView.builder(
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          final item = dummyData[index];
          return ListTile(
            leading: const Icon(Icons.image),
            title: Text(item["timestamp"]!),
            subtitle: const Text("View Keypoints"),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Keypoints JSON"),
                  content: Text(item["keypoints"]!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
