# MentorMesh Hub

A comprehensive mentoring and learning platform built with Flutter, designed to connect mentors and mentees in an engaging and interactive environment. The platform facilitates course creation, learning management, and real-time interaction between mentors and students.

## 🚀 Core Features

### Learning Management
- Course creation and management system
- Interactive quiz system for knowledge assessment
- Progress tracking and learning analytics
- Course search and discovery
- My Courses section for enrolled students

### User Experience
- Modern Material Design with dark/light theme support
- Responsive UI with ScreenUtil for consistent sizing
- Smooth animations and transitions
- Custom Hanken Grotesk font integration
- Device preview support for cross-platform testing

### Communication & Engagement
- Real-time messaging system
- Activity tracking and notifications
- Schedule management for sessions
- Profile management system

### Analytics & Progress
- Detailed statistics and progress tracking
- Performance analytics
- Learning path visualization

## 🏗️ Project Architecture

The project follows a modular architecture using GetX for state management:

```
lib/
├── app/
│   ├── bindings/      # Dependency injection
│   ├── controllers/   # Business logic
│   ├── data/         # Constants and helpers
│   ├── models/       # Data models
│   ├── modules/      # Feature modules
│   │   ├── auth/         # Authentication
│   │   ├── course_detail/# Course details
│   │   ├── create_course/# Course creation
│   │   ├── home/         # Home screen
│   │   ├── landing_page/ # Landing page
│   │   ├── message/      # Messaging system
│   │   ├── my_courses/   # Course management
│   │   ├── onboarding/   # User onboarding
│   │   ├── profile/      # User profiles
│   │   ├── quiz/         # Quiz system
│   │   ├── schedule/     # Scheduling
│   │   ├── search/       # Search functionality
│   │   ├── statistics/   # Analytics
│   │   └── widgets/      # Shared widgets
│   └── routes/       # Navigation routes
├── assets/
│   ├── icons/
│   ├── images/
│   └── fonts/
```

## 🛠️ Technical Stack

- **Framework**: Flutter SDK (>=2.19.0)
- **State Management**: GetX 4.6.6
- **UI Components**:
  - Flutter ScreenUtil 5.7.0 (Responsive design)
  - Flutter SVG 2.0.5 (Vector graphics)
  - Syncfusion Charts 26.2.14 (Data visualization)
  - Flutter Staggered Animations 1.1.1
  - Device Preview 1.1.0
- **Design System**:
  - Material Design
  - Custom theme support (Light/Dark)
  - Hanken Grotesk font family

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=2.19.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code (recommended IDE)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mentor_mesh_hub.git
```

2. Navigate to the project directory:
```bash
cd mentor_mesh_hub
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## 📱 Platform Support

The app is designed to work on:
- iOS
- Android
- Web
- macOS
- Windows
- Linux

## 🔧 Configuration

The app uses several configuration files:
- `pubspec.yaml` for dependencies
- `firebase.json` for Firebase configuration
- `analysis_options.yaml` for code analysis rules

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Make sure to:
1. Follow the existing code structure
2. Add appropriate documentation
3. Include tests for new features
4. Follow the Flutter style guide

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support, please:
1. Open an issue in the GitHub repository
2. Contact the development team
3. Check the documentation in the `/docs` directory
