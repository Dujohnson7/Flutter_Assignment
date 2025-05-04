import 'package:flutter/material.dart';
import 'package:secondapp/model/todo_model.dart';
import 'todo_detail.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Todo> _todos = [];
  String _filter = 'All';

  List<Todo> get _filteredTodos {
    switch (_filter) {
      case 'Completed':
        return _todos.where((todo) => todo.isCompleted).toList();
      case 'Pending':
        return _todos.where((todo) => !todo.isCompleted).toList();
      default:
        return _todos;
    }
  }

  void _addTodo(String title, String? description) {
    setState(() {
      _todos.add(Todo(
        title: title,
        description: description,
      ));
    });
  }

  void _toggleTodoCompletion(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _showAddTodoDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter todo title',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter todo description',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  _addTodo(
                    titleController.text,
                    descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckMe'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Tasks'),
              ),
              const PopupMenuItem(
                value: 'Completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: 'Pending',
                child: Text('Pending'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    widget.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${widget.userName}!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'You have ${_filteredTodos.length} tasks',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(_filter),
                  backgroundColor: Colors.blue.shade100,
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredTodos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_filter.toLowerCase()} tasks found',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_filter != 'All')
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filter = 'All';
                        });
                      },
                      child: const Text('Show all tasks'),
                    ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = _filteredTodos[index];
                return Dismissible(
                  key: Key(todo.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteTodo(todo.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${todo.title} deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            setState(() {
                              _todos.insert(index, todo);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (value) {
                        _toggleTodoCompletion(todo.id);
                      },
                      activeColor: Colors.green,
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isCompleted
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                    subtitle: todo.description != null
                        ? Text(
                      todo.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: todo.isCompleted
                            ? Colors.grey
                            : Colors.grey.shade700,
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TodoDetailPage(
                            todo: todo,
                            onTodoUpdated: (updatedTodo) {
                              setState(() {
                                final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
                                if (index != -1) {
                                  _todos[index] = updatedTodo;
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}