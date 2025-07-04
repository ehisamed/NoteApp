import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_practice1/features/categories/bloc/categories_bloc.dart';
import 'package:note_app_practice1/features/categories/data/repository/category_repository.dart';
import 'package:note_app_practice1/config/database/database_provider.dart';

class CategoriesBlocProvider extends StatelessWidget {
  final Widget child;

  const CategoriesBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseProvider.database,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final db = snapshot.data!;
          final repository = CategoryRepository(db);

          return BlocProvider(
            create: (_) =>
                CategoriesBloc(repository)..add(LoadCategoriesList()),
            child: child,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
