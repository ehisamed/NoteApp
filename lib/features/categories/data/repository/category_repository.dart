import 'package:note_app_practice1/features/categories/model/category_model.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRepository {
  final Database db;

  CategoryRepository(this.db);

  Future<List<CategoryModel>> getAllCategories() async {
    final result = await db.query('categories', orderBy: 'updated_at DESC');
    return result.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final result = await db.query(
      'categories',
      where: 'id =?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return CategoryModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertCategory(CategoryModel category) async {
    final data = category.toMap();
    data.remove('id');

    return await db.insert(
      'categories',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(CategoryModel category) async {
    if(category.id == null) {
      throw Exception('Cannot update category without an ID');
    }

    await db.update(
      'categories',
      category.toMap(),
      where: 'id =?',
      whereArgs: [category.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategory(int id) async {
    await db.delete('categories', where: 'id =?', whereArgs: [id]);
  }
}
