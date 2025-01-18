import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/Models/Todo_model.dart';
import 'package:to_do_list_app/widgets/floating_window.dart';

const String Collection = "TodoData";
const String Collectionname = "TodoList";
const String SubCollectionname = "Todo_task";

class TodolistController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  OverlayEntry? _floatingWindow;

  late final CollectionReference<TodoModel> _todosRef;

  var username = 'meh'.obs;
  var Title = 'meh'.obs;

  @override
  void onInit() {
    super.onInit();
    getUsername();
  }

  // Initialize Todos collection with converter
  TodolistController() {
    _todosRef = _firestore.collection(Collection).doc(_auth.currentUser!.uid + "_Todo").collection(Collectionname).withConverter<TodoModel>(
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
        .collection(Collection).doc(_auth.currentUser!.uid + "_Todo").collection(Collectionname)
        .doc(todoId)
        .collection(SubCollectionname)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoSubModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateTodo(String todoId, TodoModel updatedTodo) async {
  try {
    final todoRef = _firestore
        .collection(Collection)
        .doc(_auth.currentUser!.uid + "_Todo")
        .collection(Collectionname)
        .doc(todoId);
    await todoRef.update(updatedTodo.toJson());
    print("Todo updated successfully");
  } catch (e) {
    print("Error updating todo: $e");
  }
}


  Future<void> updateTodosTask(String todoId, String subtodoID, TodoSubModel todoSubModel) async {
    try {
      final todoStuffRef = _firestore
          .collection(Collection)
          .doc(_auth.currentUser!.uid + "_Todo")
          .collection(Collectionname)
          .doc(todoId)
          .collection(SubCollectionname);

      await todoStuffRef.doc(subtodoID).update(todoSubModel.toJson());
      print("Sub-item updated successfully: ${todoSubModel.isDone}");
    } catch (e) {
      print("Error updating sub-item: $e");
    }
  }

  Future<void> getUsername() async {
    try {
      if (_auth.currentUser == null) {
        username.value = "Guest";
        return;
      }

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

      if (userDoc.exists) {
        username.value = userDoc['name'] ?? "Unknown";
      } else {
        username.value = "Unknown";
      }
    } catch (e) {
      print("Error fetching username: $e");
      username.value = "Error";
    }
  }

  Future<void> addNewTodoTask(String todoID, String title) async {
    try {
      final todoRef = _firestore
          .collection(Collection)
          .doc(_auth.currentUser!.uid + "_Todo")
          .collection(Collectionname)
          .doc(todoID)
          .collection(SubCollectionname);

      TodoSubModel newTodoSubItem = TodoSubModel(id: '', name: title, isDone: false);

      await todoRef.add(newTodoSubItem.toJson());
      print("New Todo Added: $title");
    } catch (e) {
      print("Error adding new todo: $e");
    }
  }

  Future<void> addNewCheckbox(String todoID, String title) async {
    try {
      final todoStuffRef = _firestore
          .collection(Collection)
          .doc(_auth.currentUser!.uid + "_Todo")
          .collection(Collectionname)
          .doc(todoID)
          .collection(SubCollectionname);

      TodoSubModel newCheckbox = TodoSubModel(id: '', name: title, isDone: false);

      await todoStuffRef.add(newCheckbox.toJson());
      print("New Checkbox Added: $title");
    } catch (e) {
      print("Error adding new checkbox: $e");
    }
  }

  // Show Floating Window For Create (Handles creating new todos)
  void showFloatingWindowForCreate(BuildContext context) {
    final overlay = Overlay.of(context);
    
    // Remove the existing floating window if any
    _floatingWindow?.remove();
    
    // Create the new floating window
    _floatingWindow = OverlayEntry(
      builder: (context) {
        return FloatingWindow(
          onClose: () {
            _floatingWindow?.remove();
            _floatingWindow = null;
          },
          title: '',
          items: [],
          todoID: '',
          isCreateMode: true,
        );
      },
    );
    overlay.insert(_floatingWindow!);
  }

  // Show Floating Window For Todo Details (Handles showing existing todo details)
  void showFloatingWindow(BuildContext context, String title, List<TodoSubModel> items, String todoID) {
    final overlay = Overlay.of(context);

    // Remove the existing floating window if any
    _floatingWindow?.remove();
    
    // Create the new floating window
    _floatingWindow = OverlayEntry(
      builder: (context) {
        return FloatingWindow(
          onClose: () {
            _floatingWindow?.remove();
            _floatingWindow = null;
          },
          title: title,
          items: items,
          todoID: todoID,
          isCreateMode: false,
        );
      },
    );
    overlay.insert(_floatingWindow!);
  }
}
