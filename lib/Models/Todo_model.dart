  class TodoModel {
    final String title;
    final List<TodoSubModel> Todo_stuff;

    TodoModel({required this.title, required this.Todo_stuff});

    factory TodoModel.fromJson(Map<String, dynamic> json) {
      return TodoModel(
        title: json['Title'], 
        Todo_stuff: (json['Todo_stuff'] as List?)?.map((item) => TodoSubModel.fromJson(item)).toList() ?? [
          //TodoSubModel(name: "No items", isDone: false),
        ],
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
    final String name;
    final bool isDone;

    TodoSubModel({
      required this.name,
      required this.isDone,
    });

    factory TodoSubModel.fromJson(Map<String, dynamic> json) {
      return TodoSubModel(
        name: json['name'],
        isDone: json['isDone'],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'name': name,
        'isDone': isDone,
      };
    }
  }
