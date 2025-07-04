// lib/features/categories/bloc/categories_bloc.dart
import 'dart:developer';

import 'package:equatable/equatable.dart'; // импорт equatable
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_practice1/features/categories/data/repository/category_repository.dart';
import 'package:note_app_practice1/features/categories/model/category_model.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository categoryRepository;

  CategoriesBloc(this.categoryRepository) : super(CategoriesInitial()) {
    on<LoadCategoriesList>(_onLoadCategoriesList);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategoriesList(
    LoadCategoriesList event,
    Emitter emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final categories = await categoryRepository.getAllCategories();
      log('Loaded categories count: ${categories.length}');
      emit(CategoriesLoaded(List<CategoryModel>.from(categories)));
    } catch (e) {
      log('Error loading categories: $e');
      emit(CategoriesError('Ошибка загрузки категорий'));
    }
  }

  Future<void> _onAddCategory(AddCategory event, Emitter emit) async {
    try {
      await categoryRepository.insertCategory(event.category);
      final categories = await categoryRepository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError('Ошибка добавления категории: $e'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      emit(CategoriesLoading());
      await categoryRepository.updateCategory(event.category);
      final categories = await categoryRepository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError('Ошибка изменения категории: $e'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      emit(CategoriesLoading());
      await categoryRepository.deleteCategory(event.categoryId);
      final categories = await categoryRepository.getAllCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError('Ошибка удаления категории: $e'));
    }
  }
}
