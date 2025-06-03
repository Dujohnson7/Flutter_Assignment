import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model/todo_model.dart';
import 'providers/todo_provider.dart';
import 'providers/theme_provider.dart';

class TodoDetailPage extends ConsumerWidget {
  final Todo todo;
  final Function(Todo) onTodoUpdated;

  const TodoDetailPage({
    Key? key,
    required this.todo,
    required this.onTodoUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ['Personal', 'Work', 'School', 'Urgent', 'Health'];
    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    void _editTodo() {
      final titleController = TextEditingController(text: todo.title);
      final descriptionController = TextEditingController(text: todo.description ?? '');
      String selectedCategory = todo.category;
      DateTime? selectedDueDate = todo.dueDate;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Edit Todo'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter todo title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
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
                          filled: true,
                          fillColor: Colors.grey[100],
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
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: categories.map((category) {
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
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[100],
                        ),
                        child: ListTile(
                          title: Text(selectedDueDate == null
                              ? 'Select Due Date (Optional)'
                              : 'Due: ${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}'),
                          leading: const Icon(Icons.calendar_today),
                          trailing: selectedDueDate != null
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() {
                                selectedDueDate = null;
                              });
                            },
                          )
                              : null,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedDueDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final updatedTodo = Todo.update(
                          id: todo.id,
                          title: titleController.text,
                          description: descriptionController.text.isEmpty
                              ? null
                              : descriptionController.text,
                          isCompleted: todo.isCompleted,
                          createdAt: todo.createdAt,
                          category: selectedCategory,
                          dueDate: selectedDueDate,
                        );
                        onTodoUpdated(updatedTodo);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        },
      );
    }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            onPressed: _editTodo,
            tooltip: 'Edit Todo',
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            color: todo.isCompleted ? Colors.grey : null,
                          ),
                        ),
                      ),
                      Chip(
                        label: Text(
                          todo.isCompleted ? 'Completed' : 'Pending',
                          style: TextStyle(
                            color: todo.isCompleted
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                        backgroundColor: todo.isCompleted
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(todo.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category,
                              size: 16,
                              color: _getCategoryColor(todo.category),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              todo.category,
                              style: TextStyle(
                                color: _getCategoryColor(todo.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (todo.dueDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOverdue ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOverdue ? Icons.warning : Icons.schedule,
                                size: 16,
                                color: isOverdue ? Colors.red : Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOverdue ? 'Overdue' : 'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                                style: TextStyle(
                                  color: isOverdue ? Colors.red : Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                todo.description ?? 'No description provided',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Created on',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.today, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${todo.createdAt.day}/${todo.createdAt.month}/${todo.createdAt.year} at ${todo.createdAt.hour}:${todo.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            if (todo.dueDate != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Due Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOverdue ? Colors.red.shade200 : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOverdue ? Icons.warning : Icons.schedule,
                      color: isOverdue ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        color: isOverdue ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(Overdue)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}