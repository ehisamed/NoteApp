import 'package:flutter/material.dart';
import 'package:note_app_practice1/features/notes/view/notes_screen.dart';
import 'package:note_app_practice1/features/notes/view_model/notes_provider.dart';
import 'package:note_app_practice1/features/tasks/view/tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [NotesBlocProvider(child: NotesScreen()), TasksScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).hintColor, width: 0.1),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 0,
            enableFeedback: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.notes), label: "Notes"),
              BottomNavigationBarItem(icon: Icon(Icons.note), label: "Tasks"),
            ],
          ),
        ),
      ),
    );
  }
}
