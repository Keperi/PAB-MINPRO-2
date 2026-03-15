import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

//SONG
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String filePath;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'file_path': filePath,
      };

  factory Song.fromMap(Map<String, dynamic> map) => Song(
        id: map['id'].toString(),
        title: map['title'],
        artist: map['artist'],
        album: map['album'],
        filePath: map['file_path'],
      );

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    String? filePath,
  }) =>
      Song(
        id: id,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        album: album ?? this.album,
        filePath: filePath ?? this.filePath,
      );
}

//THEME NOTIFIER
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => value == ThemeMode.dark;
}

// Global agar bisa diakses dari halaman manapun
final themeNotifier = ThemeNotifier();

// ============================================================
// APP
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Music Player',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,

          //LIGHT THEME
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFA2D48),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF2F2F7),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF2F2F7),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              iconTheme: IconThemeData(color: Colors.black),
            ),
            useMaterial3: true,
          ),

          //DARK THEME
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFA2D48),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF1C1C1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1C1C1E),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            useMaterial3: true,
          ),

          home: const HomeScreen(),
        );
      },
    );
  }
}