# 🎧 Aetheris — Design System Reference

> **Versi:** 1.0.0 | **Platform:** Android, iOS, Windows, macOS  
> **Framework:** Flutter | **Tema:** Glassmorphism Dark Mode

---

## 📋 Daftar Isi

1. [Brand Identity](#1-brand-identity)
2. [Color Palette](#2-color-palette)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Glassmorphism System](#5-glassmorphism-system)
6. [Component Rules](#6-component-rules)
7. [Iconography](#7-iconography)
8. [Animation & Motion](#8-animation--motion)
9. [Audio Quality Indicators](#9-audio-quality-indicators)
10. [Page Inventory](#10-page-inventory)
11. [Dos & Don'ts](#11-dos--donts)

---

## 1. Brand Identity

| Property | Value |
|----------|-------|
| **App Name** | Aetheris |
| **Tagline** | *Beyond Sound* |
| **Personality** | Premium · Ethereal · Audiophile · Modern |
| **Design Inspiration** | Apple Music (typography) + Spotify (layout) + Custom Glassmorphism |
| **Logo Concept** | Minimalist sound wave forming letter "A" with a violet gradient glow |
| **Primary Target** | Hi-Fi / audiophile music listeners |

---

## 2. Color Palette

### 2.1 Base Colors (Dark Mode — Primary)

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `color-bg-primary` | `#0A0A0F` | Background utama seluruh app |
| `color-bg-secondary` | `#12121A` | Surface yang sedikit elevated |
| `color-bg-tertiary` | `#1A1A2E` | Card, container, bottom sheet |
| `color-bg-elevated` | `#20203A` | Dialog, modal |

### 2.2 Accent Colors

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `color-accent-primary` | `#6C5CE7` | Electric Violet — CTA utama, progress bar, ikon aktif |
| `color-accent-secondary` | `#A29BFE` | Soft Lavender — highlight, teks artistis |
| `color-accent-gradient` | `#6C5CE7 → #A29BFE → #74B9FF` | Tombol primer, ikon Now Playing, badge |
| `color-accent-glow` | `rgba(108,92,231,0.35)` | Shadow/glow pada elemen interaktif |

### 2.3 Text Colors

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `color-text-primary` | `#FFFFFF` | Judul, teks utama |
| `color-text-secondary` | `#8E8EA0` | Subjudul, metadata |
| `color-text-tertiary` | `#5A5A6E` | Placeholder, disabled |
| `color-text-accent` | `#A29BFE` | Link, teks interaktif |

### 2.4 Semantic Colors

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `color-success` | `#00D2A0` | Bit-Perfect indicator, koneksi OK, Download selesai |
| `color-warning` | `#FDCB6E` | Alert, format lossy |
| `color-error` | `#FF6B6B` | Error, hapus, destructive action |
| `color-spotify` | `#1DB954` | Tombol/ikon integrasi Spotify |
| `color-hires-gold` | `#F9CA24` | Badge Hi-Res, premium quality |

### 2.5 Dynamic Color (Runtime)
- **Album Art Dominant Color** — diekstrak secara otomatis dari cover art menggunakan `palette_generator`
- Digunakan sebagai: warna blob background di Now Playing, glow di sekitar album art, tint warna glassmorphism card
- Selalu divalidasi contrast ratio minimum **4.5:1** terhadap teks putih

---

## 3. Typography

**Font Family Utama:** `SF Pro Display` / `SF Pro Text` (iOS/macOS), `Roboto` (Android), `Inter` (Web/Windows)

### Scale

| Token | Size | Weight | Letter Spacing | Penggunaan |
|-------|------|--------|----------------|------------|
| `text-display-lg` | 34px | Bold (700) | -0.4px | Large Title (header iOS) |
| `text-heading-1` | 28px | Bold (700) | -0.3px | Judul section utama |
| `text-heading-2` | 22px | SemiBold (600) | -0.2px | Judul card, dialog |
| `text-heading-3` | 17px | SemiBold (600) | 0 | Section headers |
| `text-body-lg` | 17px | Regular (400) | 0 | Body utama |
| `text-body` | 15px | Regular (400) | 0 | Deskripsi, konten |
| `text-body-sm` | 13px | Regular (400) | 0 | Metadata, timestamp |
| `text-caption` | 12px | Regular (400) | 0 | Caption, hint |
| `text-mini` | 11px | Medium (500) | +0.6px | Badge, label pill, uppercase label |
| `text-micro` | 10px | Medium (500) | +0.8px | Quality badge (FLAC, 24-bit) |

### Aturan Tipografi
- **Heading**: Selalu warna `color-text-primary` (`#FFFFFF`)
- **Subtext/Metadata**: Selalu `color-text-secondary` (`#8E8EA0`)
- **Uppercase label**: Huruf kapital + `text-mini` + `letter-spacing: 1.2px` (contoh: "NOW PLAYING", "NEXT IN QUEUE")
- **Line clamp**: Semua nama lagu & album dibatasi 1 baris dengan ellipsis
- **Jangan** gunakan font weight Regular untuk tombol apapun — minimal SemiBold

---

## 4. Spacing & Layout

### 4.1 Spacing Scale

| Token | Value | Penggunaan |
|-------|-------|------------|
| `space-xs` | 4px | Gap antar icon & label |
| `space-sm` | 8px | Gap antar card kecil, padding internal mini |
| `space-md` | 12px | Gap antar item list, padding card |
| `space-lg` | 16px | Gap umum antar section |
| `space-xl` | 20px | Horizontal page padding |
| `space-2xl` | 24px | Gap antar blok besar |
| `space-3xl` | 28px | Gap antar section utama |
| `space-4xl` | 40px | Margin area kosong besar |

### 4.2 Border Radius

| Token | Value | Penggunaan |
|-------|-------|------------|
| `radius-sm` | 6px | Thumbnail kecil, badge |
| `radius-md` | 8px | Album art, category card |
| `radius-lg` | 12px | Album art Now Playing, panel |
| `radius-xl` | 16px | Card besar, bottom sheet |
| `radius-2xl` | 20px | Modal, setting group |
| `radius-3xl` | 24px | Bottom sheet top radius |
| `radius-full` | 999px | Pill button, chip filter, circular avatar |

### 4.3 Dimensi Komponen Tetap

| Komponen | Dimensi |
|----------|---------|
| Bottom Navigation Bar | Height: 84px (termasuk safe area) |
| Mini Player Bar | Height: 64px |
| Status Bar (iOS) | Height: 54px (Dynamic Island aware) |
| Touch Target Minimum | 44x44px |
| Button Height Primary | 48px |
| Button Height Secondary | 36px |
| Chip/Filter Pill Height | 32-34px |
| List Item Height (song) | 64px |
| List Item Height (album) | 72px |
| Album Art (Now Playing) | 320x320px |
| Album Art (Card) | 140x140px |
| Album Art (List Thumb) | 44-56px |
| Avatar (User) | 36-56px |
| FAB (Floating Action Button) | 56px diameter |

---

## 5. Glassmorphism System

> Semua surface di Aetheris menggunakan efek glassmorphism. **Jangan** gunakan solid background opak pada card/panel kecuali disebutkan.

### 5.1 Surface Tiers

| Tier | Background | Blur | Border | Shadow | Penggunaan |
|------|------------|------|--------|--------|------------|
| **Glass Level 1** (Subtle) | `rgba(255,255,255,0.04)` | `blur(20px)` | `1px solid rgba(255,255,255,0.06)` | `0 4px 16px rgba(0,0,0,0.3)` | List item hover, tag chip |
| **Glass Level 2** (Default) | `rgba(255,255,255,0.07)` | `blur(40px)` | `1px solid rgba(255,255,255,0.08)` | `0 8px 32px rgba(0,0,0,0.4)` | Card, mini player, bottom sheet |
| **Glass Level 3** (Elevated) | `rgba(255,255,255,0.10)` | `blur(60px)` | `1px solid rgba(255,255,255,0.12)` | `0 16px 48px rgba(0,0,0,0.5)` | Modal dialog, Now Playing controls |
| **Glass Dark** (Overlay) | `rgba(10,10,20,0.88)` | `blur(60px)` | `1px solid rgba(255,255,255,0.06)` | `0 20px 60px rgba(0,0,0,0.6)` | Bottom sheet full, lyrics panel |
| **Glass Accent** (Tinted) | `rgba(108,92,231,0.10)` | `blur(40px)` | `1px solid rgba(108,92,231,0.20)` | `0 8px 32px rgba(108,92,231,0.2)` | Active state card, current song highlight |

### 5.2 Background Atmosphere (Fluid Blobs)
Setiap halaman memiliki 2-3 *ambient blob* di background:

| Blob | Warna | Posisi | Ukuran | Opacity |
|------|-------|--------|--------|---------|
| Blob A | `#6C5CE7` (Violet) | Top-right | ~280px | 0.15 |
| Blob B | `#74B9FF` (Blue) | Bottom-left | ~220px | 0.10 |
| Blob C | Album art dominant color | Center | ~180px | 0.12 |

- Blob menggunakan `border-radius: 50%` dengan `filter: blur(80px)`
- Di Now Playing: blob **lebih besar** dan **lebih terang** (opacity hingga 0.25)
- Di halaman list: blob **lebih kecil** dan **lebih redup**
- **Jangan** buat blob terlihat sebagai objek — harus seperti cahaya ambient

---

## 6. Component Rules

### 6.1 Buttons

| Tipe | Style | Penggunaan |
|------|-------|------------|
| **Primary** | Accent gradient bg, white text bold, shadow glow | Aksi utama (Play, Download, Save) |
| **Secondary** | Glass L2, accent border 1px, accent text | Aksi sekunder (Shuffle, Add to Queue) |
| **Ghost** | Transparent, white text | Aksi tersier, destructive ringan |
| **Destructive** | `color-error` border, error text | Hapus, Remove, End Party |
| **Icon Button** | Glass L1, icon only, 40-44px circle | Action dalam row (heart, share, menu) |

**Rules:**
- Tombol primer SELALU pakai `accent-gradient`, bukan solid `color-accent-primary`
- Glow shadow di tombol primer: `0 4px 20px rgba(108,92,231,0.45)`
- Disabled state: opacity `0.35`, non-interactive
- Loading state: tombol tetap terlihat + spinner kecil menggantikan ikon

### 6.2 Cards

- **Song/Track Card** (horizontal): thumbnail kiri, info tengah, action kanan
- **Album Card** (vertikal): art di atas, info di bawah
- **Artist Card**: circular image, nama di bawah, centered
- **All cards** pakai Glass Level 2 sebagai default
- **Active/Playing card**: pakai Glass Accent (violet tinted)
- Tap feedback: slight scale `0.97` + glow increase

### 6.3 Lists & Separators
- Separator antar list item: `1px solid rgba(255,255,255,0.04)`
- **Jangan** gunakan separator yang terlalu kontras
- Section header: `text-mini` uppercase + `color-text-secondary`

### 6.4 Input Fields
- Background: `rgba(255,255,255,0.08)`, `blur(20px)`, `radius-md`
- Border: `1px solid rgba(255,255,255,0.08)` → on focus: `1px solid color-accent-primary`
- Placeholder: `color-text-tertiary`
- Ikon di kiri: selalu muted gray
- Clear button (X): muncul kanan, muted gray

### 6.5 Toggle Switches
- Ikuti style iOS native toggle
- ON state: `color-accent-primary` (`#6C5CE7`)
- OFF state: `rgba(255,255,255,0.15)`

### 6.6 Progress / Seek Bar
- Track: `4px` tinggi, `rgba(255,255,255,0.15)`, `radius-full`
- Fill: accent gradient kiri ke kanan
- Thumb: `14px` circle putih, shadow, muncul saat di-touch
- Mini version (mini player): `2px`, no thumb, accent fill

### 6.7 Bottom Navigation
- 5 tab: Home, Search, Library, Downloads, Settings
- Active: ikon filled + `color-accent-primary` + teks label
- Inactive: ikon outline + `color-text-secondary`
- Badge notifikasi: merah, 16px circle, angka putih 10px

---

## 7. Iconography

- **Style:** SF Symbols style — outlined dengan stroke `1.5px` (inactive), filled (active)
- **Default size:** 24px
- **Large action:** 28px (prev/next di player)
- **Primary play/pause:** 28px dalam container 64px circle
- **Mini/secondary:** 20px
- **Color:** Active = `color-accent-primary`, Inactive = `color-text-secondary`
- **Jangan** campur gaya ikon (semua harus SF Symbols-like atau Material outline — pilih salah satu)

### Ikon Wajib Per Halaman

| Ikon | Fungsi |
|------|--------|
| `house.fill` | Home (active) / `house` (inactive) |
| `magnifyingglass` | Search |
| `rectangle.stack` | Library |
| `arrow.down.circle` | Downloads |
| `gearshape` | Settings |
| `play.fill` / `pause.fill` | Play / Pause |
| `forward.fill` / `backward.fill` | Next / Prev |
| `shuffle` | Shuffle |
| `repeat` / `repeat.1` | Repeat / Repeat One |
| `heart` / `heart.fill` | Like (outline / filled red) |
| `text.alignleft` | Lyrics |
| `slider.horizontal.3` | Equalizer |
| `list.bullet` | Queue |
| `square.and.arrow.up` | Share |
| `moon.fill` | Sleep Timer |
| `person.crop.circle` | User Profile |
| `checkmark.seal.fill` | Bit-Perfect (mint green) |

---

## 8. Animation & Motion

### 8.1 Prinsip
- **Fluid & Natural** — semua animasi harus terasa organik, bukan mekanik
- **Durasi pendek** — UI response: 150-250ms, transisi halaman: 300-400ms
- **Easing:** `easeInOut` untuk mayoritas, `spring(damping: 0.8)` untuk expand/collapse

### 8.2 Transisi Wajib

| Transisi | Durasi | Easing |
|----------|--------|--------|
| Mini Player → Full Player | 350ms | Spring, damping 0.75 |
| Page navigation | 300ms | easeInOut |
| Bottom sheet slide up | 300ms | easeOut |
| Bottom sheet dismiss | 250ms | easeIn |
| Card tap feedback | 150ms | easeInOut (scale 0.97) |
| Lyrics line change | 200ms | easeInOut (opacity + position) |
| Album art crossfade | 400ms | easeInOut |
| Blob ambient motion | 8-15s | Infinite, sinusoidal |
| EQ bar response | 80ms | easeOut |
| Toggle switch | 200ms | Spring |

### 8.3 Hero Animation (Mini Player → Full Player)
- Album art: scale dari 44px thumbnail ke 320px center
- Background: fade in dynamic blurred art (duration 400ms)
- Controls: fade in dari bawah (staggered, 50ms per element)

### 8.4 Equalizer Animation (Now Playing indicator)
- 3 bar kecil di sebelah ikon album saat lagu sedang diputar
- Bar bergerak naik-turun secara random dalam range 4-16px
- Warna: `color-accent-secondary` (`#A29BFE`)
- Berhenti saat musik dipause (bar di posisi tengah)

---

## 9. Audio Quality Indicators

> Ini adalah fitur identitas utama Aetheris. Selalu tampilkan dengan jelas.

### 9.1 Quality Badge System

| Badge | Warna | Kondisi |
|-------|-------|---------|
| `FLAC` | Mint Green `#00D2A0` | File FLAC lossless |
| `Hi-Res` | Gold `#F9CA24` | FLAC ≥ 88.2kHz atau ≥ 24-bit |
| `DSD` | Gold `#F9CA24` | File DSF/DFF native DSD |
| `MP3` | Amber `#FDCB6E` | File MP3 lossy |
| `AAC` | Amber `#FDCB6E` | File AAC/M4A lossy |
| `WAV` | Soft Blue `#74B9FF` | File WAV uncompressed |
| `OGG` | Muted Gray `#8E8EA0` | Ogg Vorbis |

### 9.2 Bit-Perfect Indicator
- Pill badge: `Bit-Perfect ●` — bullet berwarna mint green berkedip perlahan
- Muncul di: Now Playing page (bawah nama artis)
- Kondisi: aktif saat Exclusive Mode / USB DAC bypass berhasil
- Saat tidak aktif: hilang atau diganti dengan badge kualitas format saja

### 9.3 Audio Spec Display (Now Playing)
Format tampilan: `[FORMAT] • [BIT DEPTH]-bit • [SAMPLE RATE]`  
Contoh: `FLAC • 24-bit • 96kHz`

---

## 10. Page Inventory

| # | Halaman | Deskripsi Singkat |
|---|---------|-------------------|
| 1 | **Home** | Greeting, Recently Played, Daily Mixes, New Releases, Mini Player |
| 2 | **Search & Download** | Search bar, kategori genre, tab Local/Online, downloader |
| 3 | **Library** | Filter chip, playlist/song/album/artist list |
| 4 | **Now Playing** | Full-screen player, seek bar, controls, audio badge |
| 5 | **Lyrics** | Synced LRC, romanize, translate, auto-scroll |
| 6 | **Equalizer** | 8-band EQ, visualizer, audio info chain |
| 7 | **Queue** | Current song, next in queue, next from playlist |
| 8 | **Album Detail** | Sliver header, tracklist, more from artist |
| 9 | **Artist Detail** | Hero banner, popular songs, discography, about |
| 10 | **Settings** | Audio engine, appearance, downloads, cloud, about |
| 11 | **Listening Party** | QR code host, join dengan kode, request lagu |
| 12 | **Sleep Timer** | Quick preset, custom picker, countdown ring |
| 13 | **Metadata Editor** | Edit tag, fetch Spotify, ganti album art |

---

## 11. Dos & Don'ts

### ✅ DO
- Selalu gunakan **dark background** sebagai base — tidak ada light mode dalam fase ini
- Selalu tampilkan **Mini Player** di semua halaman (kecuali Now Playing itu sendiri)
- Gunakan **glassmorphism** untuk semua card, panel, dan modal
- Tampilkan **audio quality badge** (FLAC/Hi-Res) pada setiap item lagu
- Gunakan **accent gradient** (violet → lavender) untuk semua elemen CTA utama
- Pastikan semua area sentuh memiliki ukuran **minimum 44x44px**
- Gunakan **staggered animation** saat banyak elemen muncul bersamaan
- Gunakan **SF Symbols-style** atau **Material outlined** icons secara konsisten

### ❌ DON'T
- **Jangan** gunakan solid putih atau warna terang sebagai background
- **Jangan** gunakan flat/solid color untuk card — selalu glassmorphism
- **Jangan** campur gaya ikon (SF Symbols + Material filled = inkonsisten)
- **Jangan** gunakan gradien yang terlalu mencolok untuk konten list (hanya untuk CTA)
- **Jangan** tampilkan elemen tanpa spacing yang cukup — minimum `space-sm` (8px) antar elemen
- **Jangan** gunakan warna merah sebagai aksen — hanya untuk destructive action
- **Jangan** gunakan border radius < 6px di komponen manapun
- **Jangan** lupakan **Bit-Perfect indicator** dan **audio quality badge** di setiap revisi

---

## 12. Referensi Design Prompt (Google Stitch)

Selalu sertakan blok ini di **awal setiap prompt** Google Stitch sebagai konteks:

```
App: Aetheris — Premium Hi-Fi Music Player
Platform: Mobile (iPhone 15 Pro, 393x852px)
Theme: Glassmorphism Dark Mode
Background: #0A0A0F (deep space black)
Accent: #6C5CE7 (electric violet) → gradient to #A29BFE (soft lavender)
Text Primary: #FFFFFF | Text Secondary: #8E8EA0
Success/Bit-Perfect color: #00D2A0 (mint green)
Card style: glassmorphism (rgba(255,255,255,0.07), blur 40px, border rgba(255,255,255,0.08))
Font: SF Pro Display (headings), SF Pro Text (body)
Border radius: min 8px, cards 12-16px, modals 24px, pills 999px
Always include: floating mini-player (64px) above bottom nav bar (84px, 5 tabs)
Bottom nav tabs: Home | Search | Library | Downloads | Settings
```

---

*Dokumen ini adalah sumber kebenaran tunggal (single source of truth) untuk desain Aetheris.*  
*Update dokumen ini setiap kali ada perubahan design decision.*
