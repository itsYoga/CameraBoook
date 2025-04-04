import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  // 播放背景音樂 (使用 AssetSource)
  Future<void> playBackgroundMusic({String assetPath = 'music/background.mp3', double volume = 0.5}) async {
    if (_isPlaying) return; // 如果正在播放，則不重複播放

    try {
      // 設定播放模式為循環播放
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // 設定音量
      await _audioPlayer.setVolume(volume);
      // 播放指定路徑的音樂資源
      await _audioPlayer.play(AssetSource(assetPath));
      _isPlaying = true;
      debugPrint('AudioPlayerService: Background music started.');

      // 監聽播放狀態變化 (可選)
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        debugPrint('AudioPlayerService: Player state changed: $state');
        _isPlaying = (state == PlayerState.playing);
      });

       // 監聽播放完成事件 (理論上 loop 模式不會觸發，但加上以防萬一)
      _audioPlayer.onPlayerComplete.listen((event) {
         debugPrint('AudioPlayerService: Player completed.');
         _isPlaying = false;
         // 如果不是 web 且需要手動循環 (雖然已設定 loop)
         // if (!kIsWeb) { playBackgroundMusic(assetPath: assetPath, volume: volume); }
      });


    } catch (e) {
      // 處理可能的錯誤，例如找不到檔案
      debugPrint('AudioPlayerService: Error playing background music: $e');
      _isPlaying = false;
    }
  }

  // 停止背景音樂
  Future<void> stopBackgroundMusic() async {
    if (!_isPlaying) return;
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      debugPrint('AudioPlayerService: Background music stopped.');
    } catch (e) {
      debugPrint('AudioPlayerService: Error stopping background music: $e');
    }
  }

  // 暫停背景音樂
  Future<void> pauseBackgroundMusic() async {
     if (!_isPlaying) return;
    try {
      await _audioPlayer.pause();
       _isPlaying = false; // Consider paused as not actively playing for this flag
      debugPrint('AudioPlayerService: Background music paused.');
    } catch (e) {
      debugPrint('AudioPlayerService: Error pausing background music: $e');
    }
  }

   // 恢復背景音樂
  Future<void> resumeBackgroundMusic() async {
     // Check current state maybe? Or just call resume.
    try {
      await _audioPlayer.resume();
       _isPlaying = true;
      debugPrint('AudioPlayerService: Background music resumed.');
    } catch (e) {
      debugPrint('AudioPlayerService: Error resuming background music: $e');
    }
  }


  // 釋放資源 (重要!)
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    debugPrint('AudioPlayerService: Disposed.');
  }
}
