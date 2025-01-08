import 'package:flutter/material.dart';
import 'package:to_do_list_app/widgets/mycolors.dart';

class FloatingWindow extends StatelessWidget {
  final String title;
  final VoidCallback onClose; // Callback to close the window
  final int itemCount; // Number of tasks to show in the list

  const FloatingWindow({
    super.key,
    required this.onClose,
    this.itemCount = 5, 
    required this.title, // Default to 5 items
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController(text: title);
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
                  color: ColorTile,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(
                          fontSize: 28
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          return ListTile(
                            tileColor: const Color.fromARGB(255, 164, 198, 255),
                            title: Text("Task $index"),
                            leading: Radio<bool>(
                              value: true,
                              groupValue: false,
                              toggleable: true,
                              onChanged: (value) {
                                // Handle checkbox change
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: onClose, // Close the floating window
                          icon: Icon(
                            Icons.arrow_forward_outlined,
                            size: 32,
                          ),
                        ),
                      ],
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
