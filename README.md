
# 📱 Reevo - Mobile App (Flutter)

Cross-platform mobile application for Reevo, built with Flutter.

---

## Screenshots
Here are some screenshots of the app in action:

### Home & Authentication
| Calendar Screen | Create Meeting Schedule |
|--------------|----------------|
| <img src="https://raw.githubusercontent.com/jusskynn97/MeetyMind/refs/heads/main/demo_images/Picture1.png" width="300"/> | <img src="https://raw.githubusercontent.com/jusskynn97/MeetyMind/refs/heads/main/demo_images/Picture2.png" width="300"/> |

### Meeting Features
| Meeting Summary | Meeting Transcription |
|----------------|--------------|
| <img src="https://raw.githubusercontent.com/jusskynn97/MeetyMind/refs/heads/main/demo_images/Picture3.png" width="300"/> | <img src="https://raw.githubusercontent.com/jusskynn97/MeetyMind/refs/heads/main/demo_images/Picture4.png" width="300"/> |

| Notification | RAG Chatbot |
|-----------------|-------------|
| <img src="https://raw.githubusercontent.com/jusskynn97/MeetyMind/refs/heads/main/demo_images/Picture6.png" width="300"/> | <img src="https://raw.githubusercontent.com/jusskynn97/MeetyMind/refs/heads/main/demo_images/Picture5.png" width="300"/> |


## 🛠️ Tech Stack

- **Framework**: Flutter 3.22
- **Language**: Dart 3.9
- **State Management**: Flutter BLoC
- **Routing**: GoRouter
- **HTTP Client**: Dio
- **Real-Time**: WebSocket (STOMP)
- **Local Storage**: SharedPreferences
- **Architecture**: Clean Architecture

---

## 📋 Prerequisites

- Flutter SDK: `>= 3.22.0`
- Dart SDK: `>= 3.9.0`
- Android Studio / VS Code (with Flutter extension)
- Android/iOS device or emulator

---

## 🚀 Installation & Setup

### 1. Install Dependencies
```bash
# Navigate to app directory
cd reevo

# Install packages
flutter pub get
```

### 2. Configure Environment Variables
Create a `.env` file in the root directory (see `.env.example` for reference):
```env
# Spring Boot Backend Base URL
BASE_URL=http://10.0.2.2:8080/api
# WebSocket URL
WS_URL=ws://10.0.2.2:8080/ws
# Firebase Config (if using FCM)
```
*(Note: For Android emulators, `10.0.2.2` maps to your computer's localhost)*

### 3. Run the App
```bash
# Run on Android
flutter run

# Run on iOS (macOS only)
flutter run -d ios
```

---

## 📁 Project Structure

```
lib/
├── core/                   # Shared Infrastructure
│   ├── di/                 # Dependency Injection
│   ├── router/             # GoRouter (Navigation)
│   ├── services/           # TokenStorageService, WebSocketService, etc.
│   └── theme/              # App Colors & Theme
└── features/               # Feature Modules
    ├── auth/               # Login/Signup
    │   ├── data/           # DataSource, Models
    │   ├── domain/         # Entity, UseCases
    │   └── presentation/   # BLoC, Pages, Widgets
    ├── newfeed/            # Home Feed, Video Playback
    ├── upload/             # Video Upload & Editing
    ├── user/               # User Profile
    ├── watch_together/     # Watch Together Rooms
    └── interaction/        # Likes, Comments, Follows
```

---

## ✨ Key Features

- Infinite scroll feed with performance optimizations (60fps)
- Real-time "Watch Together" video sync
- Seamless JWT + Refresh Token auth (no interruptions)
- Like/Comment on videos, follow users
- Video upload & editing
- Push notifications via FCM

