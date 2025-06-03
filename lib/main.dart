import 'package:flutter/material.dart';
import 'package:flutterAssignment/providers/todo_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'CheckMe Todo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode == ThemeModeOption.light
          ? ThemeMode.light
          : themeMode == ThemeModeOption.dark
          ? ThemeMode.dark
          : ThemeMode.system,
      home: const LoginPage(),
    );
  }
}