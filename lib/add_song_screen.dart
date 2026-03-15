import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'main.dart';
import 'supabase_service.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();

  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isSaving = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        if (_titleController.text.isEmpty) {
          _titleController.text =
              _selectedFileName!.replaceAll(RegExp(r'\.[^.]+$'), '');
        }
      });
    }
  }

  Future<void> _saveSong() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih file audio terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$_selectedFileName';

      await supabase.storage.from('audio').upload(
            fileName,
            File(_selectedFilePath!),
          );

      final fileUrl =
          supabase.storage.from('audio').getPublicUrl(fileName);

      final newSong = await SupabaseService.insertSong(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        album: _albumController.text.trim(),
        filePath: fileUrl,
      );

      Navigator.pop(context, newSong);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
    // ← Ambil warna card dari theme (putih di light, abu gelap di dark)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final labelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Batal',
              style: TextStyle(color: Color(0xFFFA2D48))),
        ),
        leadingWidth: 80,
        title: const Text('Tambah Lagu'),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFA2D48),
                    ),
                  ),
                )
              : TextButton(
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
              // Tombol pilih file
              GestureDetector(
                onTap: _isSaving ? null : _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor, // ← ikut tema
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFilePath != null
                            ? Icons.audio_file_rounded
                            : Icons.add_circle_rounded,
                        size: 48,
                        color: const Color(0xFFFA2D48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFileName ?? 'Pilih File Audio',
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedFilePath != null
                              ? (isDark ? Colors.white : Colors.black87)
                              : labelColor,
                          fontWeight: _selectedFilePath != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedFilePath == null) ...[
                        const SizedBox(height: 4),
                        Text('mp3, wav, flac, dll',
                            style: TextStyle(
                                fontSize: 13, color: labelColor)),
                      ],
                      if (_isSaving) ...[
                        const SizedBox(height: 12),
                        const Text('Mengupload ke Supabase Storage…',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFFFA2D48))),
                      ],
                    ],
                  ),
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

              // Card 3 TextField
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
                    _buildField(_albumController, 'Album', Icons.album_rounded),
                  ],
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
      enabled: !_isSaving,
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