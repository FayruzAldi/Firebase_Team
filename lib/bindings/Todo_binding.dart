import 'package:get/get.dart';
import 'package:to_do_list_app/controllers/Todolist_controller.dart';

class TodoBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => TodolistController());
  }
}