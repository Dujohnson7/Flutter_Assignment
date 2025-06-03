import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterAssignment/model/todo_model.dart';
import 'theme_provider.dart';

final themeModeProvider = StateProvider<ThemeModeOption>((ref) => ThemeModeOption.system);

final todosProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) => TodoNotifier());

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void addTodo(Todo todo) {
    state = [...state, todo];
  }

  void updateTodo(Todo updatedTodo) {
    state = state.map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo).toList();
  }

  void deleteTodo(Todo todo) {
    state = state.where((t) => t.id != todo.id).toList();
  }

  void toggleTodoStatus(Todo todo) {
    state = state.map((t) => t.id == todo.id ? Todo.update(
      id: t.id,
      title: t.title,
      description: t.description,
      isCompleted: !t.isCompleted,
      createdAt: t.createdAt,
      category: t.category,
      dueDate: t.dueDate,
    ) : t).toList();
  }
}

final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todosProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return todos.where((todo) {
    final matchesSearch = todo.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        (todo.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
    final matchesCategory = selectedCategory == 'All' || todo.category == selectedCategory;
    return matchesSearch && matchesCategory;
  }).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');