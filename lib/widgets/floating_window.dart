import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    todolistController.TitleController.text = title;

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
                        if (isCreateMode) {
                          todolistController.TitleController.text = todolistController.CreateTitle.value; 
                        } else {
                          todolistController.TitleController.text = todolistController.Title.value; 
                        }
                        return TextField(
                          controller: todolistController.TitleController,
                          onSubmitted: isCreateMode
                              ? (value) async {
                                  if (value.isNotEmpty) {
                                    todolistController.CreateTitle.value = value;
                                  }
                                }
                              : (value) async {
                                  if (value.isNotEmpty) {
                                    await todolistController.updateTodo(
                                      todoID,
                                      TodoModel(title: value),
                                    );
                                  }
                                  todolistController.Title.value = value;
                                },
                          style: const TextStyle(fontSize: 28),
                          decoration: InputDecoration(
                            hintText: "Enter Todo Title",
                            suffixIcon: !isCreateMode
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,),
                                    onPressed: () async {
                                      todolistController.deleteTodo(todoID);
                                      onClose();
                                    },
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length + 1, // Include "new item" row.
                        itemBuilder: (context, index) {
                          if (index == items.length) {
                            return ListTile(
                              tileColor: const Color.fromARGB(255, 164, 198, 255),
                              title: TextField(
                                decoration: const InputDecoration(
                                  hintText: "New Item",
                                ),
                                onSubmitted: (value) async {
                                  if (value.isNotEmpty) {
                                    if (isCreateMode){
                                      await todolistController.addSubTaskForCreate(
                                        value
                                      );
                                    } else {
                                      await todolistController.addNewTodoTask(
                                        todoID,
                                        value,
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          } else {
                            final subItem = items[index];
                            return Obx(() {
                              return GestureDetector(
                                onLongPress: () {
                                  todolistController.deleteTodoTask(todoID, subItem.id);
                                },
                                child: ListTile(
                                  title: subItem.isEdit.value
                                      ? TextField(
                                          controller: TextEditingController(
                                              text: subItem.name),
                                          onSubmitted: (text) async {
                                            if (text.isNotEmpty) {
                                              await todolistController
                                                  .updateTodosTask(
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
                                          },
                                        )
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
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            subItem.isEdit.value = true;
                                          },
                                        ),
                                ),
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: isCreateMode ? () {
                            todolistController.addNewTodoWithSubTasks(
                              todolistController.CreateTitle.value
                            );
                            onClose();
                          } 
                          : 
                          onClose,
                          icon: Icon(
                            isCreateMode ? Icons.add : Icons.arrow_forward_outlined,
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
