import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/Models/Todo_model.dart';
import 'package:to_do_list_app/controllers/Todolist_controller.dart';
import 'package:to_do_list_app/widgets/mycolors.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodolistController todolistController = Get.put(TodolistController());

    return Scaffold(
      backgroundColor: ColorBack,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Kanye\'s list',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(onPressed: () {
            Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to log out?",
                textCancel: "Cancel",
                textConfirm: "Logout",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back(); // Close the dialog
                },
              );
          }, 
          icon: Icon(Icons.exit_to_app),
          )
        ],
        automaticallyImplyLeading: false,
        backgroundColor: ColorHeader,
      ),
      body: StreamBuilder(
        stream: todolistController.getTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Todos Available"));
          }

          final todos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index].data(); // A TodoModel object
              final todoID = todos[index].id;

              return GestureDetector(
                onTap: () {
                  todolistController.showFloatingWindow(context, todo.title);
                },
                child: Card(
                  color: ColorTile,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo.title,
                                style: const TextStyle(
                                    fontSize: 20,),
                              ),
                              
                              Divider(color: Colors.black,),
                            ],
                          ),
                        ),
                        StreamBuilder<List<TodoSubModel>>(
                          stream:
                              todolistController.getTodosTask(todoID),
                          builder: (context, subItemsSnapshot) {
                            if (subItemsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                
                            if (subItemsSnapshot.hasError) {
                              return Text(
                                  "Error loading sub-items: ${subItemsSnapshot.error}");
                            }
                
                            final subItems = subItemsSnapshot.data ?? [];
                
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: subItems.length,
                              itemBuilder: (context, subIndex) {
                                final subItem = subItems[subIndex];
                
                                return ListTile(
                                  title: Text(subItem.name),
                                  leading: Radio<bool>(
                                    value: true, // Represents the checked state
                                    groupValue: subItem.isDone, // The current state of the item
                                    toggleable: true,
                                    onChanged: (value) async {
                                      await todolistController.updateTodosTask(
                                        todoID,
                                        subItem.id,
                                        TodoSubModel(
                                          id: subItem.id,
                                          name: subItem.name,
                                          isDone: !subItem.isDone, 
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
