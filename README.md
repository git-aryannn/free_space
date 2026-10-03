# Free Space

**Let's free our system from garbage.**

Free Space is a smart, native-optimized storage management and file decluttering application built with Flutter. It helps you keep your device clean by intelligently categorizing files based on their usage frequency and aging them into a temporary holding area before permanent deletion.

## 🚀 Features

* **Intelligent File Scanning**: Scans your entire device or specific directories to discover forgotten or unused files.
* **Three-Tier Storage System**:
  * 🔒 **Permanent**: Files you want to keep forever.
  * ⏳ **Temporary**: Files that are currently being monitored. They have a countdown based on your defined inactivity threshold (e.g., 30 days of no modifications).
  * 🗑️ **Bin**: Once a temporary file's countdown expires, it is safely moved to the Bin, where it awaits final permanent deletion.
* **Smart Inactivity Detection**: Tracks genuine file modifications rather than just system index accesses, ensuring you only lose files you've truly stopped using.
* **Flash Storage Optimization**: Uses native OS APIs to execute direct pointer moves instead of reading/writing file bytes when transferring to the Bin, preserving SSD and flash storage lifespan.
* **Background Sync**: Can run silently in the background (using WorkManager/Flutter Background Service) to keep track of your storage health without manual intervention.
* **Custom Ignore Lists**: Easily specify folders that should never be touched or scanned by the app.

## 📱 Supported Platforms

* **✅ Android**: Fully supported. Features deep native integration for external storage scanning and background services.
* **✅ macOS**: Fully supported. Features native security-scoped bookmarking for sandboxed folder access and native file moving.
* **⏳ iOS**: *Coming Soon*
* **⏳ Windows**: *Coming Soon*

## 🛠️ Tech Stack

* **UI Framework**: [Flutter](https://flutter.dev/) (Dart)
* **State Management**: [Riverpod](https://riverpod.dev/) (Riverpod Generator)
* **Local Database**: [Drift](https://drift.simonbinder.eu/) (SQLite)
* **Background Tasks**: [WorkManager](https://pub.dev/packages/workmanager) / Flutter Background Service
* **Native Integrations**: Custom Swift (macOS) and Kotlin (Android) MethodChannels for high-performance file system operations.

## ⚙️ Getting Started

### Prerequisites
* Flutter SDK (Latest stable)
* Android Studio (for Android builds)
* Xcode (for macOS builds)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/git-aryannn/free_space.git
   cd free_space
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate Drift database files and Riverpod providers:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run -d macos  # For macOS
   flutter run -d android # For Android
   ```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/git-aryannn/free_space/issues).

## 📄 License

This project is open-source and available under standard terms.
