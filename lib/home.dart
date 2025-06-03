import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_detail.dart';
import 'model/todo_model.dart';
import 'providers/todo_provider.dart';
import 'providers/theme_provider.dart';

class HomePage extends ConsumerWidget {
  final String userName;

  const HomePage({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodos = ref.watch(filteredTodosProvider);
    final todos = ref.watch(todosProvider);
    final categories = ['All', 'Personal', 'Work', 'School', 'Urgent', 'Health'];
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final completedCount = todos.where((todo) => todo.isCompleted).length;
    final totalCount = todos.length;

    Color _getCategoryColor(String category) {
      switch (category) {
        case 'Work':
          return Colors.blue;
        case 'Personal':
          return Colors.green;
        case 'School':
          return Colors.orange;
        case 'Urgent':
          return Colors.red;
        case 'Health':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    void _addTodo() {
      final titleController = TextEditingController();
      final descriptionController = TextEditingController();
      DateTime? selectedDate;
      String selectedCategory = 'Personal';

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Add New Todo'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          hintText: 'Enter todo title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter todo description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: categories.skip(1).map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(selectedDate == null
                            ? 'Select Due Date (Optional)'
                            : 'Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                        leading: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final newTodo = Todo(
                          title: titleController.text,
                          description: descriptionController.text.isEmpty ? null : descriptionController.text,
                          category: selectedCategory,
                          dueDate: selectedDate,
                        );
                        ref.read(todosProvider.notifier).addTodo(newTodo);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add Todo'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    Widget _buildTodoItem(Todo todo) {
      final isOverdue = todo.dueDate != null &&
          todo.dueDate!.isBefore(DateTime.now()) &&
          !todo.isCompleted;

      return Dismissible(
        key: Key(todo.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          ref.read(todosProvider.notifier).deleteTodo(todo);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${todo.title} deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  ref.read(todosProvider.notifier).addTodo(todo);
                },
              ),
            ),
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 30,
          ),
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodoDetailPage(
                    todo: todo,
                    onTodoUpdated: (updatedTodo) {
                      ref.read(todosProvider.notifier).updateTodo(updatedTodo);
                    },
                  ),
                ),
              );
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Todo'),
                  content: Text('Are you sure you want to delete "${todo.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(todosProvider.notifier).deleteTodo(todo);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (_) => ref.read(todosProvider.notifier).toggleTodoStatus(todo),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                color: todo.isCompleted ? Colors.grey : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.description != null)
                  Text(
                    todo.description!,
                    style: TextStyle(
                      color: todo.isCompleted ? Colors.grey : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(todo.category).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        todo.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(todo.category),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (todo.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isOverdue ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOverdue ? 'Overdue' : 'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckMe', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          PopupMenuButton<ThemeModeOption>(
            icon: const Icon(Icons.brightness_6),
            onSelected: (ThemeModeOption value) {
              ref.read(themeModeProvider.notifier).state = value;
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeModeOption>>[
              const PopupMenuItem<ThemeModeOption>(
                value: ThemeModeOption.light,
                child: ListTile(
                  leading: Icon(Icons.wb_sunny, color: Colors.amber),
                  title: Text('Light'),
                ),
              ),
              const PopupMenuItem<ThemeModeOption>(
                value: ThemeModeOption.dark,
                child: ListTile(
                  leading: Icon(Icons.nightlight_round, color: Colors.blueGrey),
                  title: Text('Dark'),
                ),
              ),
              const PopupMenuItem<ThemeModeOption>(
                value: ThemeModeOption.system,
                child: ListTile(
                  leading: Icon(Icons.settings_system_daydream, color: Colors.grey),
                  title: Text('System'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $userName!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$completedCount of $totalCount tasks completed',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: TextEditingController(
                    text: ref.watch(searchQueryProvider),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search todos...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedCategoryProvider.notifier).state = category;
                    },
                    selectedColor: Colors.blue.withOpacity(0.3),
                    checkmarkColor: Colors.blue,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: filteredTodos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    todos.isEmpty ? 'No todos yet!' : 'No todos match your search',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todos.isEmpty
                        ? 'Tap the + button to add your first todo'
                        : 'Try different keywords or categories',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                return _buildTodoItem(filteredTodos[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}