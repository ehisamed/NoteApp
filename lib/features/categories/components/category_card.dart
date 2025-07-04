// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CategoryCard extends StatefulWidget {
  final String categoryName;
  final String createdAt;
  final Color color;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.createdAt,
    required this.color,
  });

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Column(children: [])),
          IconButton(onPressed: () {}, icon: Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }
}
