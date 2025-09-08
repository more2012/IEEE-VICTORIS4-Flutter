# Awan App - Project Structure

## 📁 Project Architecture

This project follows a clean architecture pattern with feature-based organization.

### 🏗️ Core Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants and configuration
│   │   └── app_constants.dart
│   ├── theme/              # App theming
│   │   └── app_theme.dart
│   ├── routes/             # Route management
│   │   └── app_routes.dart
│   └── utils/              # Utility functions
│       └── validators.dart
├── features/               # Feature-based modules
│   └── onboarding/         # Onboarding feature
│       ├── controllers/    # Business logic
│       ├── models/         # Data models
│       ├── screens/        # UI screens
│       └── widgets/        # Reusable widgets
├── services/               # External services
│   ├── api_service.dart    # API communication
│   └── storage_service.dart # Local storage
├── screens/                # Global screens
│   └── homepage.dart
├── app.dart                # Main app configuration
└── main.dart               # App entry point
```

## 🎯 Key Features

### ✅ Clean Architecture
- **Separation of Concerns**: Each layer has a specific responsibility
- **Feature-based Organization**: Related code is grouped together
- **Dependency Injection**: Using Provider for state management

### ✅ State Management
- **Provider Pattern**: For state management and dependency injection
- **ChangeNotifier**: For reactive UI updates

### ✅ Routing
- **Named Routes**: Centralized route management
- **Route Generation**: Dynamic route handling

### ✅ Theming
- **Material 3**: Modern Material Design
- **Consistent Styling**: Centralized theme configuration

### ✅ Services Layer
- **API Service**: HTTP communication
- **Storage Service**: Local data persistence

## 🚀 Getting Started

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```

## 📱 Features

### Onboarding
- **3-screen onboarding flow**
- **Smooth page transitions**
- **Custom navigation controls**
- **Responsive design**

### Home
- **Welcome screen**
- **Medical-themed UI**
- **Clean, modern design**

## 🔧 Configuration

### Constants
All app constants are centralized in `lib/core/constants/app_constants.dart`:
- App information
- Route names
- Asset paths
- Colors and dimensions
- Animation durations

### Theme
App theming is configured in `lib/core/theme/app_theme.dart`:
- Material 3 design
- Consistent color scheme
- Typography settings
- Component themes

## 📦 Dependencies

- **flutter**: SDK
- **provider**: State management
- **shared_preferences**: Local storage
- **http**: API communication
- **flutter_native_splash**: Splash screen

## 🎨 Design System

### Colors
- **Primary**: Blue (#2196F3)
- **Secondary**: Teal (#03DAC6)
- **Background**: White
- **Text**: Black/Grey

### Typography
- **Headlines**: Bold, blue
- **Body**: Regular, black/grey
- **Consistent sizing**: 14px, 16px, 20px, 24px, 28px

## 🔄 Future Enhancements

- [ ] Add more features (medication tracking, reminders)
- [ ] Implement authentication
- [ ] Add offline support
- [ ] Implement push notifications
- [ ] Add analytics
- [ ] Implement testing
