# Nutrition API Debugging Guide

## Changes Made

### 1. Fixed API Endpoint
- **Old**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent`
- **New**: `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent`

**Changes:**
- Changed from `v1beta` to `v1` (stable version)
- Changed model from `gemini-pro` to `gemini-1.5-flash` (current model)

### 2. Added Comprehensive Logging

The following logs will now appear in your console when you click "Generate Nutrition Plan":

#### Initial Logs:
```
=== Starting Nutrition Plan Generation ===
API Key configured: true/false
API Key (first 10 chars): AIzaSyBgvE...
Prompt generated successfully
User Profile: Age=30, Gender=Male, Weight=70.0kg, Height=177.0cm
```

#### Request Logs:
```
API Endpoint: https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent
Full URL (without key): https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=***
Sending POST request...
```

#### Response Logs:
```
Response received!
Status Code: 200 (or error code)
Response Headers: {...}
Response Body (first 500 chars): {...}
```

#### Success Logs:
```
✓ Success! Parsing response...
Extracted text length: XXXX characters

=== Parsing Meal Plan Response ===
Response length: XXXX characters
JSON start index: XX
JSON end index: XXX
Extracted JSON string (first 300 chars): {...}
JSON decoded successfully
Keys found: [breakfast, lunch, dinner, snacks]
✓ Meal plan parsed successfully!
```

#### Error Logs (if any):
```
✗ ERROR: Non-200 status code
Full Response Body: {...}

OR

✗ EXCEPTION CAUGHT:
Error: ...
Stack Trace: ...
```

## Testing Steps

1. **Hot Restart** your Flutter app (not just hot reload)
   ```bash
   # In your terminal or press Shift+F5 in VS Code
   flutter run
   ```

2. Navigate to **Nutrition Assistant** tab

3. Click **"Start Your Nutrition Journey"**

4. Fill in the form:
   - Age: 30
   - Gender: Male
   - Weight: 70 kg
   - Height: 177 cm
   - Health Conditions: Select any (e.g., Diabetes, Heart Disease)

5. Click **"Generate Nutrition Plan"**

6. **Check your console/terminal** for the detailed logs

## Common Issues & Solutions

### Issue 1: Still Getting 404
**Solution**: The API endpoint might need `v1beta` instead of `v1`. If you see 404 in logs, change line 6 in `constants.dart`:
```dart
const String GOOGLE_AI_ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";
```

### Issue 2: API Key Invalid (403 Error)
**Solution**: 
1. Go to https://aistudio.google.com/app/apikey
2. Generate a new API key
3. Update `GOOGLE_AI_API_KEY` in `constants.dart`

### Issue 3: Timeout Error
**Solution**: Increase timeout in `constants.dart`:
```dart
const Duration API_TIMEOUT = Duration(seconds: 60);
```

### Issue 4: Network Error
**Solution**: 
- Check your internet connection
- Ensure your app has internet permissions in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## What to Share

If it still doesn't work, please share:
1. **All console output** from the logs above
2. **The exact error message** shown in the red banner
3. **Status code** from the logs
4. **Response body** from the logs (if any)

This will help identify the exact issue!
