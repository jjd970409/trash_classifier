import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '쓰레기 분류 도우미',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, // 앱의 주요 색상 ddd
          brightness: Brightness.light, // 밝은 테마 사용
        ),
        fontFamily: 'NotoSansKR', // 기본 글꼴 설정 (pubspec.yaml에 폰트 추가 필요)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green, // 앱 바 배경색
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16), // 기본 텍스트 스타일
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}