// lib/features/categories/bloc/categories_event.dart

part of 'categories_bloc.dart';

abstract class CategoriesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCategoriesList extends CategoriesEvent {}

class AddCategory extends CategoriesEvent {
  final CategoryModel category;

  AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoriesEvent {
  final CategoryModel category;

  UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoriesEvent {
  final int categoryId;

  DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
