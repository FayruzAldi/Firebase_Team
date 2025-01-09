import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/Models/Todo_model.dart';
import 'package:to_do_list_app/widgets/floating_window.dart';

const String collection = "TodoData";
const String Collectionname = "TodoList";
const String SubCollectionname = "Todo_task";

class TodolistController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  OverlayEntry? _floatingWindow;

  late final CollectionReference<TodoModel> _todosRef;

  // Initialize Todos collection with converter
  TodolistController() {
    _todosRef = _firestore.collection(collection).doc("eMO5nYTugkJAX4WLOv2w_todo").collection(Collectionname).withConverter<TodoModel>(
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

  Stream<QuerySnapshot<TodoModel>> getTodos() {
    return _todosRef.snapshots();
  }

  Stream<List<TodoSubModel>> getTodosTask(String todoId) {
    return _firestore
        .collection(collection).doc("eMO5nYTugkJAX4WLOv2w_todo").collection(Collectionname)
        .doc(todoId)
        .collection(SubCollectionname)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoSubModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateTodosTask(String todoId, String subtodoID, TodoSubModel todoSubModel) async {
    try {
      final todoStuffRef = _firestore
          .collection(collection).doc("eMO5nYTugkJAX4WLOv2w_todo").collection(Collectionname)
          .doc(todoId)
          .collection(SubCollectionname);
      await todoStuffRef.doc(subtodoID).update(todoSubModel.toJson());
      print("Sub-item updated successfully");
    } catch (e) {
      print("Error updating sub-item: $e");
    }
  }

  // Floating window logic remains unchanged

  void showFloatingWindow(BuildContext context, String title) {
    final overlay = Overlay.of(context);

    _floatingWindow = OverlayEntry(
      builder: (context) {
        return FloatingWindow(
          onClose: () {
            _floatingWindow?.remove();
            _floatingWindow = null;
          }, 
          title: title,
        );
      },
    );

    overlay?.insert(_floatingWindow!);
  }
}
