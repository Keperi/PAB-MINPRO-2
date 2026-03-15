import 'main.dart';

class SupabaseService {

//READ
  static Future<List<Song>> fetchSongs() async {
    final data = await supabase
        .from('songs')
        .select();
    return (data as List).map((e) => Song.fromMap(e)).toList();
  }

//CREATE
  static Future<Song> insertSong({
    required String title,
    required String artist,
    required String album,
    required String filePath,
  }) async {
    final data = await supabase
        .from('songs')
        .insert({
          'title': title,
          'artist': artist,
          'album': album,
          'file_path': filePath,
        })
        .select()
        .single();
    return Song.fromMap(data);
  }

//UPDATE
  static Future<Song> updateSong(Song song) async {
    final data = await supabase
        .from('songs')
        .update({
          'title': song.title,
          'artist': song.artist,
          'album': song.album,
          'file_path': song.filePath,
        })
        .eq('id', song.id)
        .select()
        .single();
    return Song.fromMap(data);
  }

//DELETE
static Future<void> deleteSong(String id, String filePath) async {
    if (filePath.startsWith('http')) {
      final fileName = filePath.split('/').last;
      await supabase.storage.from('audio').remove([fileName]);
    }

    // 2. Hapus row dari tabel songs
    await supabase
        .from('songs')
        .delete()
        .eq('id', id);
  }
}