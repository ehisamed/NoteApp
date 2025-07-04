import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_practice1/features/categories/bloc/categories_bloc.dart';
import 'package:note_app_practice1/features/categories/model/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<CategoriesBloc>().add(LoadCategoriesList());
  }

  void _scrollListener() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _showButton) {
      setState(() => _showButton = false);
    } else if (direction == ScrollDirection.forward && !_showButton) {
      setState(() => _showButton = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    Color selectedColor = Colors.deepPurple;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новая категория'),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название категории',
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: [
                    ...[
                      Colors.red,
                      Colors.green,
                      Colors.blue,
                      Colors.orange,
                      Colors.purple,
                      Colors.teal,
                    ].map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: selectedColor == color ? 18 : 14,
                          child: selectedColor == color
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  final now = DateTime.now();
                  final category = CategoryModel(
                    name: name,
                    color: selectedColor.value.toRadixString(16),
                    createdAt: now,
                    updatedAt: now,
                  );

                  context.read<CategoriesBloc>().add(AddCategory(category));
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      body: Stack(
        children: [
          BlocBuilder<CategoriesBloc, CategoriesState>(
            builder: (context, state) {
              if (state is CategoriesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CategoriesLoaded) {
                if (state.categories.isEmpty) {
                  return const Center(child: Text('Нет категорий'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final color = category.color != null
                        ? Color(int.parse(category.color!, radix: 16))
                        : Colors.grey;

                    return ListTile(
                      key: ValueKey(category.id),
                      leading: CircleAvatar(backgroundColor: color),
                      title: Text(category.name),
                      subtitle: Text(
                        'Создано: ${category.createdAt.toIso8601String()}',
                      ),
                    );
                  },
                );
              } else if (state is CategoriesError) {
                return Center(child: Text(state.message));
              } else {
                return const SizedBox();
              }
            },
          ),

          // Плавающая кнопка с анимацией
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              offset: _showButton ? Offset.zero : const Offset(0, 2.5),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                opacity: _showButton ? 1.0 : 0.0,
                child: AnimatedScale(
                  scale: _showButton ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddCategoryDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить категорию'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 8,
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
