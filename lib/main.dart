import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // 匯入 Home Screen
import 'services/audio_player_service.dart'; // <--- 匯入 Audio Service

void main() {
  // 確保 Flutter 綁定已初始化 (如果需要在 main 中做非同步操作)
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhotographyApp());
}

// --- App Widget (改為 StatefulWidget) ---
class PhotographyApp extends StatefulWidget {
  const PhotographyApp({super.key});

  @override
  State<PhotographyApp> createState() => _PhotographyAppState();
}

class _PhotographyAppState extends State<PhotographyApp> {
  // 持有 AudioPlayerService 的實例
  late final AudioPlayerService _audioPlayerService;

  @override
  void initState() {
    super.initState();
    // 建立 AudioPlayerService 實例
    _audioPlayerService = AudioPlayerService();
    // 開始播放背景音樂 (設定音量為 0.3)
    // 注意：自動播放在某些平台/瀏覽器可能有嚴格限制
    _audioPlayerService.playBackgroundMusic(volume: 0.3);

    // 如果需要監聽 App 生命週期來控制音樂 (例如進入背景時暫停)
    // 可以考慮使用 WidgetsBindingObserver
  }

  @override
  void dispose() {
    // 在 App 結束時停止音樂並釋放資源
    _audioPlayerService.stopBackgroundMusic();
    _audioPlayerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- MaterialApp 的內容保持不變 ---
    return MaterialApp(
      title: '攝影互動學習',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.dark,
        cardTheme: CardTheme(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: const EdgeInsets.all(8.0),
        ),
        textTheme: const TextTheme(
           bodyMedium: TextStyle(fontSize: 16.0, height: 1.5),
           titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
           titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
        )
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}