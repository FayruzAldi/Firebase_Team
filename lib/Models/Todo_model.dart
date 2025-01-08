  class TodoModel {
    final String title;
    final List<TodoSubModel> Todo_stuff;

    TodoModel({required this.title, required this.Todo_stuff});

    factory TodoModel.fromJson(Map<String, dynamic> json) {
      return TodoModel(
      title: json['Title'] as String,
      Todo_stuff: (json['Todo_stuff'] as List<dynamic>? ?? []).map((item) {
        // Handle cases where items may not have an id directly from sub-collection
        return TodoSubModel.fromJson(item, item['id'] ?? '');
      }).toList(),
    );
    }

    Map<String, dynamic> toJson() {
      return {
        'Title': title,
        'Todo_stuff': Todo_stuff.map((item) => item.toJson()).toList(),
      };
    }
  }

  class TodoSubModel {
  final String id; // The document ID
  final String name;
  final bool isDone;

  TodoSubModel({
    required this.id,
    required this.name,
    required this.isDone,
  });

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
