import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/Models/Todo_model.dart';
import 'package:to_do_list_app/controllers/Todolist_controller.dart';
import 'package:to_do_list_app/routes/route.dart';
import 'package:to_do_list_app/widgets/mycolors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodolistController todolistController = Get.find();

    return Scaffold(
      backgroundColor: colorBack,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Obx(() {
          return Text(
            "${todolistController.username.value}'s List",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                middleText: "Apakah Anda yakin ingin keluar?",
                textCancel: "Batal",
                textConfirm: "Keluar",
                confirmTextColor: Colors.white,
                onConfirm: () async {
                  // Logout logic
                  try {
                    await FirebaseAuth.instance.signOut();
                    final GoogleSignIn googleSignIn = GoogleSignIn();
                    if (await googleSignIn.isSignedIn()) {
                      await googleSignIn.signOut();
                    }
                    Get.offAllNamed(MyRoutes.login);
                  } catch (e) {
                    Get.snackbar('Error', 'Gagal melakukan logout: $e');
                  }
                },
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: mainColor1,
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
                  final todoID = todos[index].id;
                  todolistController.getTodosTask(todoID).listen((subItems) {
                    todolistController.showFloatingWindow(
                        context, todo.title, subItems, todoID);
                  });
                },
                child: Card(
                  color: colorTile,
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
                                  fontSize: 20,
                                ),
                              ),
                              Divider(color: Colors.black),
                            ],
                          ),
                        ),
                        StreamBuilder<List<TodoSubModel>>(
                          stream: todolistController.getTodosTask(todoID),
                          builder: (context, subItemsSnapshot) {
                            if (subItemsSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (subItemsSnapshot.hasError) {
                              return Text("Error loading sub-items: ${subItemsSnapshot.error}");
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
                                  leading: Checkbox(
                                    value: subItem.isDone,
                                    onChanged: (bool? value) async {
                                      if (value != null) {
                                        await todolistController.updateTodosTask(
                                          todoID,
                                          subItem.id,
                                          TodoSubModel(id: subItem.id, name: subItem.name, isDone: value),
                                        );
                                      }
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
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    // Open the floating window in create mode
    todolistController.showFloatingWindowForCreate(context);
  },
  child: Icon(Icons.add),  // A plus icon
  backgroundColor: mainColor1,
),

    );
  }
}
