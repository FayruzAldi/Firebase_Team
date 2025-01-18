import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:to_do_list_app/Models/Todo_model.dart';
import 'package:to_do_list_app/widgets/mycolors.dart';
import 'package:to_do_list_app/controllers/Todolist_controller.dart';

class FloatingWindow extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final int itemCount;
  final List<TodoSubModel> items;
  final String todoID;
  final bool isCreateMode;

  FloatingWindow({
    super.key,
    required this.onClose,
    this.itemCount = 5,
    required this.title,
    required this.items,
    required this.todoID,
    required this.isCreateMode,
  });

  @override
  Widget build(BuildContext context) {
    final TodolistController todolistController = Get.find();
    // Use RxString for the title
    todolistController.Title = title.obs;
    
    // Using an Obx widget to bind the controller to the reactive variable
    TextEditingController _controller = TextEditingController();

    return GestureDetector(
      onTap: onClose,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Center(
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorTile,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Obx(() {
                        _controller.text = todolistController.Title.value;
                        return TextField(
                          controller: _controller,
                          onSubmitted: isCreateMode
                              ? null
                              : (value) async {
                                  if (value.isNotEmpty) {
                                    await todolistController.updateTodo(
                                      todoID,
                                      TodoModel(
                                        title: value,
                                        Todo_stuff: items,
                                      ),
                                    );
                                    todolistController.Title.value = value; 
                                    print(todolistController.Title.value);
                                  }
                                },
                          style: TextStyle(fontSize: 28),
                          decoration: InputDecoration(
                            hintText: "Enter Todo Title",
                            suffixIcon: isCreateMode
                                ? IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () async {
                                      if (_controller.text.isNotEmpty) {
                                        await todolistController.addNewTodoTask(
                                          todoID,
                                          _controller.text,
                                        );
                                        onClose(); // Close the window after adding
                                      }
                                    },
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                    if (!isCreateMode) ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final subItem = items[index];
                            return Obx(() {
                              return ListTile(
                                tileColor: Color.fromARGB(255, 164, 198, 255),
                                title: subItem.isEdit.value
                                    ? TextField(
                                        controller: TextEditingController(
                                            text: subItem.name),
                                        onSubmitted: (text) {
                                          if (text.isNotEmpty) {
                                            todolistController.updateTodosTask(
                                              todoID,
                                              subItem.id,
                                              TodoSubModel(
                                                id: subItem.id,
                                                name: text,
                                                isDone: subItem.isDone,
                                              ),
                                            );
                                            subItem.isEdit.value = false;
                                          }
                                        })
                                    : Text(subItem.name),
                                leading: Checkbox(
                                  value: subItem.isDone,
                                  onChanged: (bool? value) async {
                                    if (value != null) {
                                      await todolistController.updateTodosTask(
                                        todoID,
                                        subItem.id,
                                        TodoSubModel(
                                          id: subItem.id,
                                          name: subItem.name,
                                          isDone: value,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                trailing: subItem.isEdit.value
                                    ? null
                                    : IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          subItem.isEdit.value = true;
                                        },
                                      ),
                              );
                            });
                          },
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length + 1,
                          itemBuilder: (context, index) {
                            if (index == items.length) {
                              return ListTile(
                                tileColor: Color.fromARGB(255, 164, 198, 255),
                                title: TextField(
                                  decoration: InputDecoration(hintText: "New Item"),
                                  onSubmitted: (value) async {
                                    if (value.isNotEmpty) {
                                      await todolistController.addNewCheckbox(
                                        todoID,
                                        value,
                                      );
                                    }
                                  },
                                ),
                              );
                            } else {
                              final subItem = items[index];
                              return ListTile(
                                title: Text(subItem.name),
                                leading: Checkbox(
                                  value: subItem.isDone,
                                  onChanged: (bool? value) async {
                                    if (value != null) {
                                      await todolistController.updateTodosTask(
                                        todoID,
                                        subItem.id,
                                        TodoSubModel(
                                          id: subItem.id,
                                          name: subItem.name,
                                          isDone: value,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: onClose,
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
