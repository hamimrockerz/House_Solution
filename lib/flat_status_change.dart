import 'package:flutter/material.dart';

class FlatStatusChangePage extends StatelessWidget {
  const FlatStatusChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Rent Collect'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10, // Example: Dynamic count based on data
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text('House ${index + 1}'),
              subtitle: const Text('Rent: \$500'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Add rent collection logic
                },
                child: const Text('Collect Rent'),
              ),
            ),
          );
        },
      ),
    );
  }
}
