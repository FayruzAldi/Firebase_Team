import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/Models/Todo_model.dart';
import 'package:to_do_list_app/controllers/Todolist_controller.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    TodolistController todolistController = Get.put(TodolistController());
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: StreamBuilder(
        stream: todolistController.getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index].data(); // A TodoModel object
              final todoID = todos[index].id;

              return FutureBuilder<List<TodoSubModel>>(
                future: todolistController
                    .getTodoSubItems(todoID), // Fetch Todo_stuff
                builder: (context, subItemsSnapshot) {
                  if (subItemsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading items..."));
                  }

                  if (subItemsSnapshot.hasError) {
                    return ListTile(
                        title: Text('Error: ${subItemsSnapshot.error}'));
                  }

                  final subItems = subItemsSnapshot.data ?? [];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // Display Todo_stuff (sub-list)
                          ListView.builder(
                            shrinkWrap: true, // To avoid overflow
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: subItems.length,
                            itemBuilder: (context, subIndex) {
                              final subItem = subItems[subIndex];
                              return ListTile(
                                title: Text(subItem.name),
                                trailing: Checkbox(
                                  value: subItem.isDone,
                                  onChanged: (value) {
                                    // You can handle updating the value here
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
