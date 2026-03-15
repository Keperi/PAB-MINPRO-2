import 'package:flutter/material.dart';
import 'main.dart';
import 'supabase_service.dart';

class EditSongScreen extends StatefulWidget {
  final Song song;
  const EditSongScreen({super.key, required this.song});

  @override
  State<EditSongScreen> createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist);
    _albumController = TextEditingController(text: widget.song.album);
  }

  Future<void> _saveSong() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedSong = Song(
      id: widget.song.id,
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      album: _albumController.text.trim(),
      filePath: widget.song.filePath,
    );

    final saved = await SupabaseService.updateSong(updatedSong);
    Navigator.pop(context, {'action': 'update', 'song': saved});
  }

  void _deleteSong() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Lagu'),
        content: Text('Hapus "${widget.song.title}" dari library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService.deleteSong(widget.song.id, widget.song.filePath);
      Navigator.pop(context, {'action': 'delete', 'song': widget.song});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ← Ambil warna card dari theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final labelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal',
              style: TextStyle(color: Color(0xFFFA2D48))),
        ),
        leadingWidth: 80,
        title: const Text('Edit Lagu'),
        actions: [
          TextButton(
            onPressed: _saveSong,
            child: const Text('Simpan',
                style: TextStyle(
                    color: Color(0xFFFA2D48),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info file (read only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor, // ← ikut tema
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFA2D48).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.audio_file_rounded,
                          color: Color(0xFFFA2D48)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.song.filePath.split('/').last,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text('INFO LAGU',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: labelColor,
                        letterSpacing: 0.5)),
              ),

              // 3 TextField
              Container(
                decoration: BoxDecoration(
                  color: cardColor, // ← ikut tema
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildField(_titleController, 'Judul Lagu',
                        Icons.music_note_rounded),
                    _divider(),
                    _buildField(
                        _artistController, 'Artis', Icons.person_rounded),
                    _divider(),
                    _buildField(
                        _albumController, 'Album', Icons.album_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Hapus
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _deleteSong,
                  style: TextButton.styleFrom(
                    backgroundColor: cardColor, // ← ikut tema
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Hapus Lagu',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      validator: (val) =>
          val == null || val.trim().isEmpty ? '$label wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFA2D48), size: 20),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1,
      thickness: 0.5,
      indent: 52,
      color: Colors.grey.shade700);
}