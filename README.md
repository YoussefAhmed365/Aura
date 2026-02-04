# Aura 🎵

> **Your Music, Reimagined in Color.**
> An offline music player built with Flutter, focusing on Material Design 3 aesthetics, privacy, and a unique dynamic visual experience.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Style](https://img.shields.io/badge/Style-Material%203-purple)](https://m3.material.io)

---

## 📖 Overview

**Aura** is not just another music player; it is an immersive audio experience. Built entirely with Flutter, it leverages the power of **Material Design 3 (Material You)** to adapt its entire interface to your device's theme and the currently playing album art.

At its core, Aura features a **Dynamic Visual Engine** that generates fluid, living backgrounds—shifting between radial and linear gradients based on the mood of your music.

## ✨ Key Features

### 🎨 Visuals & Design
- **Material You Integration:** The app UI adapts to your system's wallpaper colors (Android 12+) or falls back to a sleek, branded violet theme.
- **The "Aura" Engine:** A smart background system that extracts vibrant colors from album art and animates between **Radial** (Focus) and **Linear** (Flow) gradients for every song.
- **Fluid Animations:** Smooth transitions and micro-interactions powered by `flutter_animate`.
- **Dark & Light Mode:** Fully supported with optimized contrast for both environments.

### 🎧 Audio Experience
- **Powerful Equalizer:** Built-in multi-band equalizer with presets (Rock, Jazz, Pop, etc.) and custom bass boost.
- **Gapless Playback:** Seamless transition between tracks using `just_audio`.
- **Lyrics Support:**
    - Embedded Lyrics (ID3 tags).
    - Synced `.lrc` file support.

### 📂 Library Management
- **Smart Local Scan:** Instantly fetches songs, artists, and albums from device storage using `on_audio_query`.
- **Custom Playlists:** Create, edit, and reorder your favorite mixes.
- **Search:** Blazing fast search for tracks and artists.
- **Queue Control:** Shuffle, Repeat One, Repeat All, and drag-to-reorder queue.

---

## 📱 Screenshots

| Home Screen | Player (Light) | Player (Dark) | Lyrics View |
|:-----------:|:--------------:|:-------------:|:-----------:|
| ![Home](assets/ss_home.png) | ![Player Light](assets/ss_player_light.png) | ![Player Dark](assets/ss_player_dark.png) | ![Lyrics](assets/ss_lyrics.png) |

---

## 🛠️ Tech Stack & Architecture

Aura is built using **Clean Architecture** principles to ensure scalability and testability.

- **Framework:** [Flutter](https://flutter.dev/)
- **Language:** Dart
- **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Audio Engine:** [just_audio](https://pub.dev/packages/just_audio) & [audio_service](https://pub.dev/packages/audio_service) (Background playback).
- **Local Database:** [hive](https://pub.dev/packages/hive) (For playlists and user preferences).
- **Theming:** [dynamic_color](https://pub.dev/packages/dynamic_color) & [palette_generator](https://pub.dev/packages/palette_generator).
- **Dependency Injection:** [get_it](https://pub.dev/packages/get_it) & [injectable](https://pub.dev/packages/injectable).

### Folder Structure
```bash
lib/
├── core/                   # العناصر الأساسية المشتركة
│   ├── constants/          # الثوابت (الألوان، النصوص)
│   ├── theme/              # إعدادات الثيم (Material 3)
│   ├── services/           # خدمات النظام (AudioHandler, Permissions)
│   └── utils/              # دوال مساعدة (TimeFormatter, Parsers)
│
├── data/                   # طبقة البيانات (التعامل مع الملفات والداتابيس)
│   ├── models/             # نماذج البيانات (SongModel, PlaylistModel)
│   ├── datasources/        # مصادر البيانات (LocalDataSource)
│   └── repositories/       # تنفيذ المستودعات (AudioRepositoryImpl)
│
├── domain/                 # طبقة القواعد (Business Logic "What to do")
│   ├── entities/           # الكائنات المجردة (Song, Artist)
│   ├── repositories/       # واجهات المستودعات (Interfaces)
│   └── usecases/           # حالات الاستخدام (PlaySong, ScanLibrary, SavePlaylist)
│
├── presentation/           # طبقة العرض (UI & State)
│   ├── bloc/               # إدارة الحالة (PlayerBloc, LibraryBloc, AuraColorBloc)
│   ├── pages/              # الشاشات (HomeScreen, PlayerScreen, Settings)
│   └── widgets/            # الأدوات (AuraBackground, SongTile, ProgressBar)
│
└── main.dart               # نقطة الانطلاق وحقن التبعيات (DI)
```

---

## 🚀 Getting Started

Follow these steps to run Aura on your local machine.

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Android Device or Emulator (API 21+)

### Installation

Clone the repository:
```bash
git clone https://github.com/YoussefAhmed365/aura-music-player.git
cd aura-music-player
```

Install dependencies:
```bash
flutter pub get
```

Generate code (for Hive & Injectable):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Run the app:
```bash
flutter run
```

---

## 🗺️ Roadmap

- [x] Core Audio Player Implementation
- [x] Material Design 3 Theming
- [x] Local File Scanning
- [ ] Implementation of "Aura" Dynamic Backgrounds (In Progress)
- [ ] Equalizer UI & Logic
- [ ] Lyrics Parser (.lrc)
- [ ] Sleep Timer
- [ ] Tag Editor

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

1. Fork the Project
2. Create your Feature Branch
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Commit your Changes
   ```bash
   git commit -m "Add some AmazingFeature"
   ```
4. Push to the Branch
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open a Pull Request

Please follow the repository's code style and include tests where appropriate.

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

## 📧 Contact

YoussefAhmed365 - your.email@example.com

Project Link: https://github.com/YoussefAhmed365/aura-music-player