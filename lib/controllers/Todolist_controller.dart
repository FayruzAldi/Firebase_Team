import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/Models/Todo_model.dart';
import 'package:to_do_list_app/widgets/floating_window.dart';

const String Collectionname = "TodoList";

class TodolistController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  OverlayEntry? _floatingWindow;

  late final CollectionReference<TodoModel> _todosRef;

  //Firebase Todos
  TodolistController() {
    _todosRef = _firestore.collection(Collectionname).withConverter<TodoModel>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            if (data == null) {
              throw Exception("Document data is null");
            }
            return TodoModel.fromJson(data);
          },
          toFirestore: (todo, _) => todo.toJson(),
        );
  }

  Stream<QuerySnapshot<TodoModel>> getTodos(){
    return _todosRef.snapshots();
  }

  Future<List<TodoSubModel>> getTodoSubItems(String todoId) async {
    final todoStuffRef = _firestore.collection(Collectionname).doc(todoId).collection('Todo_stuff');
    final snapshot = await todoStuffRef.get();

    // If no items in the collection, return an empty list
    return snapshot.docs.map((doc) => TodoSubModel.fromJson(doc.data())).toList();
  }

  //floating window
  void showFloatingWindow(BuildContext context) {
    final overlay = Overlay.of(context);

    _floatingWindow = OverlayEntry(
      builder: (context) {
        return FloatingWindow(
          onClose: () {
            _floatingWindow?.remove();
            _floatingWindow = null;
          },
        );
      },
    );

    overlay?.insert(_floatingWindow!);
  }
}
