import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/contact.dart';
import 'screens/home_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/settings_screen.dart' show themeController, colorController, fontSizeController;
import 'screens/pin_lock_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  if (Hive.isBoxOpen('contacts')) {
    await Hive.box<Contact>('contacts').close();
  }
  await Hive.openBox<Contact>('contacts');

  // Charger les préférences au démarrage
  final prefs = await SharedPreferences.getInstance();
  final colorValue = prefs.getInt('primary_color') ?? 0xFFFFD700;
  final fontSize = prefs.getDouble('font_size') ?? 14.0;
  final themeModeStr = prefs.getString('theme_mode') ?? 'system';
  ThemeMode themeMode = ThemeMode.system;
  if (themeModeStr == 'light') themeMode = ThemeMode.light;
  if (themeModeStr == 'dark') themeMode = ThemeMode.dark;
  // Mettre à jour les contrôleurs globaux avec les valeurs sauvegardées
  colorController.value = Color(colorValue);
  fontSizeController.value = fontSize;
  themeController.value = themeMode;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _unlocked = false;
  bool _checkingPin = true;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  Future<void> _checkPinStatus() async {
    final storage = FlutterSecureStorage();
    final pin = await storage.read(key: 'app_pin');
    print('DEBUG: PIN détecté: $pin'); // Debug log
    setState(() {
      _hasPin = pin != null;
      _checkingPin = false;
    });
    print('DEBUG: _hasPin: $_hasPin, _unlocked: $_unlocked'); // Debug log
  }

  Future<String?> _getPin() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'app_pin');
  }

  void _unlock() {
    setState(() {
      _unlocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: colorController,
          builder: (context, primaryColor, _) {
            return ValueListenableBuilder<double>(
              valueListenable: fontSizeController,
              builder: (context, fontSize, _) {
                final isDark = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: isDark
                      ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
                      : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
                  child: _buildApp(themeMode, primaryColor, fontSize),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildApp(ThemeMode themeMode, Color primaryColor, double fontSize) {
    print('DEBUG: _checkingPin: $_checkingPin, _hasPin: $_hasPin, _unlocked: $_unlocked'); // Debug log
    if (_checkingPin) {
      print('DEBUG: Affichage du loading'); // Debug log
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (_hasPin && !_unlocked) {
      print('DEBUG: Affichage de l\'écran de verrouillage'); // Debug log
      return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
          ),
          textTheme: Theme.of(context).textTheme.apply(
            fontSizeFactor: fontSize / 14,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: primaryColor),
            border: OutlineInputBorder(),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.dark,
          ),
          textTheme: Theme.of(context).textTheme.apply(
            fontSizeFactor: fontSize / 14,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: primaryColor),
            border: OutlineInputBorder(),
            fillColor: Colors.grey[800],
            filled: true,
          ),
        ),
        themeMode: themeMode,
        home: PinLockScreen(getPin: _getPin, onUnlock: _unlock),
      );
    }
    return MaterialApp(
      title: 'Scan & Save',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: fontSize / 14,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: primaryColor),
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          fontSizeFactor: fontSize / 14,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: primaryColor),
          border: OutlineInputBorder(),
          fillColor: Colors.grey[800],
          filled: true,
        ),
      ),
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    HomeScreen(),
    ScannerScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
        height: 70,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
    );
  }
}
