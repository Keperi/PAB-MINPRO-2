import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'main.dart';
import 'add_song_screen.dart';
import 'edit_song_screen.dart';
import 'supabase_service.dart';

// HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _player = AudioPlayer();
  List<Song> _songs = [];
  Song? _currentSong;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _player.playingStream.listen((playing) {
      setState(() => _isPlaying = playing);
    });
  }

  Future<void> _loadSongs() async {
    final songs = await SupabaseService.fetchSongs();
    setState(() => _songs = songs);
  }

  void _addSong(Song song) {
    setState(() => _songs.add(song));
  }

  void _deleteSong(Song song) async {
    if (_currentSong?.id == song.id) {
      _player.stop();
      setState(() {
        _currentSong = null;
        _isPlaying = false;
      });
    }
    await SupabaseService.deleteSong(song.id, song.filePath);
    setState(() => _songs.removeWhere((s) => s.id == song.id));
  }

  Future<void> _playSong(Song song) async {
    if (_currentSong?.id == song.id) {
      _isPlaying ? await _player.pause() : await _player.play();
    } else {
      if (song.filePath.startsWith('http')) {
        await _player.setUrl(song.filePath);
      } else {
        await _player.setFilePath(song.filePath);
      }
      await _player.play();
      setState(() => _currentSong = song);
    }
  }

  void _goToAddSong() async {
    final newSong = await Navigator.push<Song>(
      context,
      MaterialPageRoute(builder: (_) => const AddSongScreen()),
    );
    if (newSong != null) _addSong(newSong);
  }

  void _goToEditSong(Song song) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditSongScreen(song: song)),
    );

    if (result == null) return;

    if (result['action'] == 'update') {
      final updatedSong = result['song'] as Song;
      setState(() {
        final index = _songs.indexWhere((s) => s.id == song.id);
        if (index != -1) _songs[index] = updatedSong;
        if (_currentSong?.id == song.id) _currentSong = updatedSong;
      });
    } else if (result['action'] == 'delete') {
      _deleteSong(result['song'] as Song);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          // ── TOGGLE DARK/LIGHT MODE ──
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) {
              return IconButton(
                onPressed: () => themeNotifier.toggleTheme(),
                icon: Icon(
                  themeNotifier.isDark
                      ? Icons.light_mode_rounded   // tampil saat dark → tekan ke light
                      : Icons.dark_mode_rounded,   // tampil saat light → tekan ke dark
                ),
                color: themeNotifier.isDark
                    ? Colors.amber
                    : Colors.grey.shade600,
                tooltip: themeNotifier.isDark ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          IconButton(
            onPressed: _goToAddSong,
            icon: const Icon(Icons.add_circle_outline_rounded),
            iconSize: 28,
            color: const Color(0xFFFA2D48),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _songs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _songs.length,
                    itemBuilder: (_, index) {
                      final song = _songs[index];
                      return _SongTile(
                        song: song,
                        isPlaying: _currentSong?.id == song.id && _isPlaying,
                        isSelected: _currentSong?.id == song.id,
                        onTap: () => _playSong(song),
                        onDelete: () => _deleteSong(song),
                        onEdit: () => _goToEditSong(song),
                      );
                    },
                  ),
          ),
          if (_currentSong != null)
            _PlayerBar(
              song: _currentSong!,
              isPlaying: _isPlaying,
              player: _player,
              onPlayPause: () => _playSong(_currentSong!),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Belum ada lagu',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Ketuk + untuk menambahkan lagu',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// ============================================================
// SONG TILE
// ============================================================
class _SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _SongTile({
    required this.song,
    required this.isPlaying,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFA2D48).withOpacity(0.1)
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPlaying
                    ? Icons.equalizer_rounded
                    : Icons.music_note_rounded,
                color: isSelected
                    ? const Color(0xFFFA2D48)
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFFA2D48)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${song.artist} • ${song.album}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PLAYER BAR
// ============================================================
class _PlayerBar extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final AudioPlayer player;
  final VoidCallback onPlayPause;

  const _PlayerBar({
    required this.song,
    required this.isPlaying,
    required this.player,
    required this.onPlayPause,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFA2D48).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.music_note_rounded,
                    color: Color(0xFFFA2D48), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(song.artist,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPlayPause,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  color: const Color(0xFFFA2D48),
                  size: 36,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => player.stop(),
                icon: Icon(Icons.stop_circle_outlined,
                    color: Colors.grey.shade400, size: 30),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (_, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final duration = player.duration ?? Duration.zero;
              final progress = duration.inMilliseconds > 0
                  ? (position.inMilliseconds / duration.inMilliseconds)
                      .clamp(0.0, 1.0)
                  : 0.0;

              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      trackHeight: 3,
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Slider(
                      value: progress,
                      activeColor: const Color(0xFFFA2D48),
                      inactiveColor: Colors.grey.shade700,
                      onChanged: (val) {
                        if (duration.inMilliseconds > 0) {
                          player.seek(Duration(
                              milliseconds:
                                  (val * duration.inMilliseconds).toInt()));
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(position),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade400)),
                        Text(_fmt(duration),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}