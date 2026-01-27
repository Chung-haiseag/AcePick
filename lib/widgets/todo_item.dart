import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(String) onToggle;
  final Function(String) onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: todo.completed ? 0.6 : 1.0,
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => onToggle(todo.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: todo.completed
                        ? AppTheme.success
                        : AppTheme.textSecondary,
                    width: 2,
                  ),
                  color: todo.completed ? AppTheme.success : Colors.transparent,
                ),
                child: todo.completed
                    ? const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                todo.text,
                style: TextStyle(
                  color: todo.completed
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : null,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              onPressed: () => onDelete(todo.id),
              icon: const Icon(LucideIcons.trash2, size: 18),
              color: AppTheme.textSecondary,
              hoverColor: AppTheme.danger.withOpacity(0.1),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
