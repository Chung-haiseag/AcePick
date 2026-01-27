import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/todo_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/todo_input.dart';
import '../widgets/todo_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1, -1),
            radius: 1.5,
            colors: [
              Color(0x263B82F6), // rgba(59, 130, 246, 0.15)
              Colors.transparent,
            ],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(1, -1),
              radius: 1.5,
              colors: [
                Color(0x268B5CF6), // rgba(139, 92, 246, 0.15)
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  const TodoInput(),
                  Expanded(
                    child: Consumer<TodoProvider>(
                      builder: (context, provider, child) {
                        if (provider.todos.isEmpty) {
                          return _buildEmptyState();
                        }
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.todos.length,
                          itemBuilder: (context, index) {
                            final todo = provider.todos[index];
                            return TodoItem(
                              todo: todo,
                              onToggle: provider.toggleTodo,
                              onDelete: provider.deleteTodo,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.sparkles,
              color: AppTheme.accentColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.textPrimary, AppTheme.accentColor],
              ).createShader(bounds),
              child: const Text(
                'Todo List',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '오늘의 목표를 달성해보세요',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.listTodo,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            '할 일이 없습니다.\n새로운 목표를 추가해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
