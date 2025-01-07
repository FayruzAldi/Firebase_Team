import 'package:flutter/material.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  OverlayEntry? _floatingWindow;

  void showFloatingWindow(BuildContext context) {
    final overlay = Overlay.of(context);

    _floatingWindow = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Close the floating window when the backdrop is tapped
                _floatingWindow?.remove();
                _floatingWindow = null;
              },
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent backdrop
              ),
            ),
          ),
          Center(
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 300,
                height: 300,
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
                        itemCount: 5, // Change this to your desired number of items
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
                      onPressed: () {
                        // Close the floating window
                        _floatingWindow?.remove();
                        _floatingWindow = null;
                      },
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

    overlay?.insert(_floatingWindow!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showFloatingWindow(context),
          child: const Text('Show Floating Window'),
        ),
      ),
    );
  }
}
