import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  
import 'src/services/data_controller.dart';
import 'src/services/history_service.dart';
import 'src/services/theme_notifier.dart';
import 'src/live_ekg_view.dart';
import 'src/live_emg_view.dart';
import 'src/history_view.dart';
import 'src/settings_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataController()),
        ChangeNotifierProvider(create: (_) => HistoryService()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biosignal App',
      theme: ThemeData.light().copyWith(primaryColor: Colors.redAccent),
      darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.redAccent),
      themeMode: theme.mode,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController();
  int _currentIndex = 0;

  static const _titles = ['Live EKG', 'Live EMG', 'Historik', 'Inställningar'];
  static const _pages = [
    LiveEkgView(),
    LiveEmgView(),
    HistoryView(),
    SettingsView(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTapNav(int idx) {
    setState(() => _currentIndex = idx);
    _pageController.animateToPage(
      idx,
      duration: const Duration(milliseconds: 580),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _pages,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
            ),
          ),
          /*   Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 7,
                dotWidth: 7,
                activeDotColor: Colors.redAccent,
                dotColor: Colors.grey,
              ),
            ),
          ),*/
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTapNav,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'EKG'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'EMG'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historik'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Inställningar'),
        ],
      ),
    );
  }
}
