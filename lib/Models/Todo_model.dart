  import 'package:get/get.dart';

class TodoModel {
    final String title;

    TodoModel({required this.title});

    factory TodoModel.fromJson(Map<String, dynamic> json) {
      return TodoModel(
      title: json['Title'] as String,
    );
    }

    Map<String, dynamic> toJson() {
      return {
        'Title': title,
      };
    }
  }

 class TodoSubModel {
  String id;
  String name;
  bool isDone;
  RxBool isEdit; // Make isEdit reactive

  TodoSubModel({
    required this.id,
    required this.name,
    required this.isDone,
    bool? isEdit,
  }) : isEdit = (isEdit ?? false).obs;

  // Factory method to create an instance from JSON data
  factory TodoSubModel.fromJson(Map<String, dynamic> json, String id) {
    return TodoSubModel(
      id: id, // Assign the document ID
      name: json['name'],
      isDone: json['isDone'],
    );
  }

  // Convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isDone': isDone,
    };
  }
}
