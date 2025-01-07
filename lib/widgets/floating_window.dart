import 'package:flutter/material.dart';

class FloatingWindow extends StatelessWidget {
  final VoidCallback onClose; // Callback to close the window
  final int itemCount; // Number of tasks to show in the list

  const FloatingWindow({
    super.key,
    required this.onClose,
    this.itemCount = 5, // Default to 5 items
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose, // Close the floating window when the backdrop is tapped
      child: Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent backdrop
            ),
          ),
          // Floating content
          Center(
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Floating Window',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          return ListTile(
                            tileColor: const Color.fromARGB(255, 164, 198, 255),
                            title: Text("Task $index"),
                            trailing: Checkbox(
                              value: false,
                              onChanged: (value) {
                                // Handle checkbox change
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onClose, // Close the floating window
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
