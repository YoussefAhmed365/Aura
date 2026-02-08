# Aura 🎵

> **Your Music, Reimagined in Color.**  
> Aura is a beautiful and privacy-friendly offline music player built with Flutter, bringing immersive dynamic visuals and Material Design 3 aesthetics to your music experience.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Style](https://img.shields.io/badge/Style-Material%203-purple)](https://m3.material.io)

---

## 📖 Overview

**Aura** reimagines how you interact with your offline music library. Built with Flutter and leveraging **Material Design 3 (Material You)**, Aura dynamically adapts its appearance to your system colors or a signature violet style, ensuring both beauty and clarity.

At its core, Aura’s **dynamic visual engine** uses your album artwork to generate animated, mood-matching backgrounds that blend seamlessly with the music and user interface.

---

## ✨ Key Features

### 🎨 Visuals & Design
- **Material You Adaptive Theming:** UI automatically shifts to match Android 12+ system colors, or uses a modern branded palette.
- **Aura Visual Engine:** Generates animated radial and linear gradients from album art for each song, creating lively, immersive backgrounds.
- **Smooth Animations:** Uses `flutter_animate` for fluid page transitions and micro-interactions.
- **Full Dark/Light Support:** Optimized for contrast and accessibility on any theme.

### 🎧 Audio Experience
- **Gapless Playback:** Enjoy seamless transitions, powered by `just_audio`.
- **Lyrics Display:** Support for embedded and synced `.lrc` lyrics.
- **Equalizer:** Built-in configurable multi-band equalizer and bass boost.
- **Queue Controls:** Shuffle, repeat, drag-and-drop reordering.

### 📂 Library & Playlists
- **Smart Library Scanning:** Blazing-fast local file scan using `on_audio_query`.
- **Custom Playlists:** Create, reorder, and edit playlists with drag-and-drop.
- **Fast Search:** Search across tracks, albums, and artists instantly.
- **Favorites:** Star and access your top tracks quickly.

---

## 🗂️ Project Structure

Aura uses a feature-first, modular structure for scalability:

```bash
lib/
├── core/                     # Core utilities and global configurations
│   ├── di/                   # Dependency injection setup
│   ├── theme/                # Material 3 theming logic
│   └── widgets/              # Shared/reusable widgets
│
├── features/                 # All major app features (modular)
│   ├── home/                 # Home screen & navigation
│   ├── main_wrapper.dart     # App shell/main navigation
│   ├── music_player/         # Music playback controls, visualizations
│   ├── playlists/            # Playlist creation & management
│   ├── search/               # Search flow for songs, artists, albums
│   ├── settings/             # User settings and preferences
│   └── songs/                # Song library, list, and metadata
│
└── main.dart                 # Entry point of the app and DI init
```

**Other top-level directories:**
- `assets/` - App icons, images, album art, etc.
- `android/`, `windows/`, `packages/` - Platform and package files.

---

## 🛠️ Tech Stack

- **Flutter (Dart)**
- **State Management:** flutter_bloc
- **Audio Engine:** just_audio, audio_service
- **Database:** hive (playlists, user settings)
- **Theming:** dynamic_color, palette_generator
- **DI:** get_it, injectable

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio or VS Code
- Android device or emulator (API 21+)

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

Generate code (for Hive/Injectable):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Run the app:
```bash
flutter run
```

---

## 🗺️ Roadmap

- [x] Core Audio Player Functionality
- [x] Adaptive Material Design 3 Theming
- [x] Smart File & Library Scanning
- [ ] Completion of Dynamic Aura Visual Engine (In Progress)
- [ ] Full Equalizer Feature
- [ ] Lyrics Parser (.lrc)
- [ ] Sleep Timer
- [ ] Tag Editor

---

## 🤝 Contributing

All contributions are highly welcome!

1. Fork the repository
2. Create your feature branch:  
   `git checkout -b feature/AmazingFeature`
3. Commit your changes:  
   `git commit -m "Add AmazingFeature"`
4. Push to your branch:  
   `git push origin feature/AmazingFeature`
5. Open a pull request

Please maintain code style and add tests when appropriate.

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

---

## 📧 Contact

**YoussefAhmed365** - your.email@example.com

Project Link: [Aura Music Player](https://github.com/YoussefAhmed365/aura-music-player)