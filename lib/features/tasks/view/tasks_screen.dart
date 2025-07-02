import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _visible = false;
  bool _showBottomLine = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _visible = true;
      });
    });

    // Слушаем скролл
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      final shouldShow = offset > 40; // можно подстроить под себя

      if (shouldShow != _showBottomLine) {
        setState(() {
          _showBottomLine = shouldShow;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            expandedHeight: 100,
            collapsedHeight: 90,
            actionsPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            toolbarHeight: 90,
            centerTitle: true,
            pinned: true,
            title: const Text("Tasks"),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: AnimatedOpacity(
                opacity: _showBottomLine ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  color: Theme.of(context).hintColor,
                  height: 0.5,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  // действие при нажатии
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                splashColor: Colors.grey,
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('Task item #${index + 1}'),
              ),
              childCount: 20,
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
        child: AnimatedScale(
          scale: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                const CircleBorder(),
              ),
              iconSize: WidgetStateProperty.all(36.0),
              splashFactory: NoSplash.splashFactory,
            ),
          ),
        ),
      ),
    );
  }
}
