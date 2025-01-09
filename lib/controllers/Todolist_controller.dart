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

  Stream<List<TodoSubModel>> getTodoSubItemsStream(String todoId) {
    return _firestore
        .collection(Collection).doc(_auth.currentUser!.uid + "_Todo").collection(Collectionname)
        .doc(todoId)
        .collection(SubCollectionname)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoSubModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateTodos(String todoId, String subtodoID, TodoSubModel todoSubModel) async {
    try {
      final todoStuffRef = _firestore
          .collection(Collection).doc(_auth.currentUser!.uid + "_Todo").collection(Collectionname)
          .doc(todoId)
          .collection(SubCollectionname);
      await todoStuffRef.doc(subtodoID).update(todoSubModel.toJson());
      print("Sub-item updated successfully");
    } catch (e) {
      print("Error updating sub-item: $e");
    }
  }

  Future<void> getUsername() async {
  try {
      // Ensure user is logged in
      if (_auth.currentUser == null) {
        username.value = "Guest"; // Default value for non-authenticated users
        return;
      }

      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

      if (userDoc.exists) {
        username.value = userDoc['name'] ?? "Unknown"; // Fallback to "Unknown" if field is null
      } else {
        username.value = "Unknown"; // Default value if document doesn't exist
      }
    } catch (e) {
      print("Error fetching username: $e");
      username.value = "Error"; // Default value on error
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

    overlay.insert(_floatingWindow!);
  }
}
