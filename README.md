# 🎵 Music Player — minpro_2

> Aplikasi pemutar musik modern berbasis Flutter dengan integrasi Supabase untuk penyimpanan data dan file audio di cloud.

---

## 📱 Deskripsi Aplikasi

**Music Player** adalah aplikasi mobile/desktop yang dibangun menggunakan Flutter sebagai pengembangan lanjutan dari minpro_1. Aplikasi ini hadir untuk memudahkan pengguna dalam mengelola dan menikmati koleksi musik pribadi mereka — mulai dari menambahkan lagu, mengedit informasi, hingga memutar audio dengan kontrol yang lengkap.

Yang membedakan versi ini dari sebelumnya adalah integrasi penuh dengan **Supabase** sebagai backend cloud. Data lagu kini tersimpan di database Supabase, sementara file audio diunggah ke Supabase Storage dan dapat di-streaming langsung dari URL — tanpa perlu menyimpan file di perangkat. Ditambah dengan fitur **Dark/Light Mode** dan pengelolaan kredensial yang aman menggunakan file `.env`.

---

## ✨ Fitur Aplikasi

| Fitur | Deskripsi |
|---|---|
| ➕ **Tambah Lagu** | Pilih file audio dari perangkat, lalu diunggah otomatis ke Supabase Storage |
| 📋 **Library Musik** | Daftar lagu lengkap dengan judul, artis, dan album yang diambil langsung dari Supabase |
| ✏️ **Edit Lagu** | Ubah metadata lagu kapan saja dan perubahan langsung tersimpan ke database |
| 🗑️ **Hapus Lagu** | Hapus lagu dari library sekaligus menghapus file-nya dari Supabase Storage secara otomatis |
| ▶️ **Pemutar Audio** | Player bar interaktif dengan tombol play/pause, stop, dan seekbar untuk navigasi audio |
| ⏱️ **Progress Bar** | Slider real-time yang bisa di-drag dengan tampilan waktu posisi dan durasi lagu |
| ☁️ **Cloud Storage** | Data dan file audio tersimpan di Supabase — bisa diakses selama terhubung internet |
| 🌙 **Dark / Light Mode** | Toggle tema gelap dan terang langsung dari AppBar, berlaku di seluruh halaman |
| 🔐 **Keamanan Kredensial** | URL dan API Key Supabase disimpan di file `.env` — tidak pernah terekspos di kode |
| 💬 **Feedback Interaktif** | SnackBar untuk notifikasi error, validasi input, dan status upload |

---

## 🧩 Widget yang Digunakan

### Struktural & Layout

| Widget | Kegunaan |
|---|---|
| `Scaffold` | Kerangka utama setiap halaman |
| `AppBar` | Header halaman dengan judul dan tombol aksi |
| `Column` / `Row` | Menyusun elemen secara vertikal dan horizontal |
| `Expanded` | Mengisi sisa ruang layar yang tersedia |
| `SingleChildScrollView` | Membuat konten form bisa di-scroll |
| `Container` | Wrapper dengan styling — warna, border radius, dan shadow |

### Tampilan & List

| Widget | Kegunaan |
|---|---|
| `ListView.builder` | Menampilkan daftar lagu secara efisien |
| `StreamBuilder` | Memperbarui progress bar secara real-time dari audio stream |
| `CircularProgressIndicator` | Indikator loading saat upload file ke Supabase Storage |
| `Icon` / `Text` | Ikon dan teks informasi lagu |

### Interaktif

| Widget | Kegunaan |
|---|---|
| `TextFormField` | Input judul, artis, dan album lagu |
| `GestureDetector` | Mendeteksi tap pada tile lagu dan tombol pilih file |
| `IconButton` | Tombol play/pause, stop, tambah lagu, dan toggle dark/light mode |
| `TextButton` | Tombol simpan, batal, dan hapus lagu |
| `Slider` + `SliderTheme` | Seekbar dengan kustomisasi tampilan untuk navigasi posisi audio |
| `Form` + `GlobalKey<FormState>` | Validasi input pada form tambah dan edit lagu |

### Dialog & Notifikasi

| Widget | Kegunaan |
|---|---|
| `AlertDialog` | Dialog konfirmasi sebelum menghapus lagu |
| `SnackBar` | Notifikasi untuk error, validasi input, dan status operasi |

### State & Tema

| Widget | Kegunaan |
|---|---|
| `StatefulWidget` + `setState` | Manajemen state lokal — status play, list lagu, lagu aktif, dan loading |
| `ValueNotifier` + `ValueListenableBuilder` | Manajemen state tema dark/light secara global dan efisien |

---

## 🗂️ Struktur Proyek

```
minpro_2/
├── .env                        # Kredensial Supabase (tidak di-upload ke GitHub)
├── pubspec.yaml                # Konfigurasi dependencies
└── lib/
    ├── main.dart               # Entry point, model Song, ThemeNotifier, tema app
    ├── home_screen.dart        # Library lagu, song tile, dan player bar
    ├── add_song_screen.dart    # Form tambah lagu + upload ke Supabase Storage
    ├── edit_song_screen.dart   # Form edit metadata & hapus lagu
    └── supabase_service.dart   # Semua operasi CRUD ke Supabase
```

---

## 📦 Dependencies

| Package | Versi | Kegunaan |
|---|---|---|
| `just_audio` | ^0.10.5 | Engine pemutaran audio — lokal maupun URL streaming |
| `file_picker` | 10.3.10 | Pemilihan file audio dari penyimpanan perangkat |
| `supabase_flutter` | ^2.12.0 | Koneksi ke database dan storage Supabase |
| `flutter_dotenv` | ^5.2.1 | Membaca kredensial Supabase dari file `.env` |

---

## 🚀 Cara Menjalankan

**1. Clone repository dan masuk ke folder project**
```bash
git clone <repo-url>
cd minpro_2
```

**2. Buat file `.env` di root project**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

**3. Install dependencies dan jalankan**
```bash
flutter pub get
flutter run
```

> ⚠️ Pastikan tabel `songs` dan bucket `audio` sudah dibuat di Supabase Dashboard sebelum menjalankan aplikasi.

---

## 📱 Platform yang Didukung

`Android` · `iOS` · `macOS` · `Windows` · `Linux` · `Web`
