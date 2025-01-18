import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/Models/Todo_model.dart';
import 'package:to_do_list_app/controllers/Todolist_controller.dart';
import 'package:to_do_list_app/routes/route.dart';
import 'package:to_do_list_app/widgets/mycolors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/notification_service.dart';

class TodoPage extends StatelessWidget {
  TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodolistController todolistController = Get.find();
    final NotificationService notificationService = Get.find();

    return Scaffold(
      backgroundColor: colorBack,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          foregroundColor: Colors.white,
          elevation: 20, //didnt work 
          title: Obx(() {
            return Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 0.0),
              child: Text(
                "${todolistController.username.value}'s List",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  decorationColor: Colors.white,
                ),
              ),
            );
          }),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 15.0, 0.0),
              child: IconButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: "Logout",
                    middleText: "Apakah Anda yakin ingin keluar?",
                    textCancel: "Batal",
                    textConfirm: "Keluar",
                    confirmTextColor: Colors.white,
                    cancelTextColor: Colors.white,
                    radius: 5,
                    backgroundColor: colorBack,
                    onConfirm: () async {
                      try {
                        await notificationService.removeCurrentToken();

                        await FirebaseAuth.instance.signOut();

                        try {
                          final GoogleSignIn googleSignIn = GoogleSignIn();
                          if (await googleSignIn.isSignedIn()) {
                            await googleSignIn.signOut();
                          }
                        } catch (e) {
                          print('Google Sign Out Error: $e');
                        }

                        Get.offAllNamed(MyRoutes.login);
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Gagal melakukan logout: $e',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 15.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: mainColor1,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 0.0),
        child: StreamBuilder(
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
                    elevation: 6,
                    color: colorTile,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 3.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todo.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Divider(
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<List<TodoSubModel>>(
                            stream: todolistController.getTodosTask(todoID),
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
                                    leading: Checkbox(
                                      value: subItem
                                          .isDone, 
                                      activeColor: Colors.black,
                                      onChanged: (value) async {
                                        await todolistController.updateTodosTask(
                                          todoID,
                                          subItem.id,
                                          TodoSubModel(
                                            id: subItem.id,
                                            name: subItem.name,
                                            isDone: value ??
                                                false, 
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog or navigate to a page for adding a new Todo
          todolistController.showFloatingWindow(context,
              "Title"); // Replace with your method to show the dialog or screen
        },
        child: Icon(Icons.add),
        backgroundColor: colorTile,
      ),
    );
  }
}
