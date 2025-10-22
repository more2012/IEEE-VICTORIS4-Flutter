# API Keys Security Setup

## Overview
This project uses environment variables to securely store API keys and prevent them from being exposed in version control.

## Setup Instructions

### 1. Create your .env file
Copy the `.env.example` file to create your own `.env` file:
```bash
cp .env.example .env
```

### 2. Add your API keys
Open the `.env` file and replace the placeholder values with your actual API keys:
```
GOOGLE_AI_API_KEY=your_actual_primary_api_key
GOOGLE_AI_API_KEY_FALLBACK=your_actual_fallback_api_key
```

### 3. Get API Keys
- Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
- Create new API keys or use existing ones
- Copy the keys to your `.env` file

### 4. Install dependencies
Run the following command to install the required packages:
```bash
flutter pub get
```

### 5. Run the app
The app will automatically load the environment variables from the `.env` file on startup.

## Important Notes

⚠️ **NEVER commit the `.env` file to version control!**
- The `.env` file is already added to `.gitignore`
- Only commit `.env.example` as a template for other developers
- Each developer should create their own `.env` file with their own API keys

## Files Modified
- **`.env`** - Contains actual API keys (gitignored)
- **`.env.example`** - Template file (committed to git)
- **`.gitignore`** - Updated to ignore `.env` files
- **`pubspec.yaml`** - Added `flutter_dotenv` package
- **`lib/main.dart`** - Loads environment variables on app startup
- **`lib/core/config/env_config.dart`** - Centralized config for accessing env variables
- **`lib/features/meal/constants.dart`** - Updated to use env_config
- **`lib/features/chatbot/screens/chatbot_screen.dart`** - Updated to use env_config
- **`lib/features/medication/screens/medication_detail_screen.dart`** - Updated to use env_config

## Troubleshooting

### Error: "GOOGLE_AI_API_KEY is not set in .env file"
- Make sure you created the `.env` file in the project root
- Verify that the API keys are set correctly in the `.env` file
- Run `flutter pub get` to ensure dependencies are installed

### API keys not loading
- Check that `.env` is in the project root directory (same level as `pubspec.yaml`)
- Verify the `.env` file is listed in `pubspec.yaml` under assets
- Restart the app after making changes to `.env`
