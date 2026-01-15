# Offline Login Guide

## Demo Credentials

**Email**: `admin@gmail.com`
**Password**: `admin000`

These credentials work offline and are hardcoded for development/testing purposes.

## Features Added

### ✅ Offline Login System
- Email and password authentication
- Hardcoded credentials (no backend required)
- Works completely offline
- Error messages for invalid credentials

### ✅ Password Security
- Password field with visibility toggle
- Secure input masking
- Clear error feedback

### ✅ Internet Permission
- AndroidManifest.xml updated
- Internet permission enabled
- Ready for API calls (Groq)

## How to Login

1. **Select Role**: Choose Teacher, Parent, or Student
2. **Enter Email**: `admin@gmail.com`
3. **Enter Password**: `admin000`
4. **Click Login**: Authenticate
5. **Access Dashboard**: Begin using the app

## Android Manifest Changes

Added to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

This allows your app to:
- Access the internet
- Call Groq API for suggestions
- Fetch data from online services

## Security Note

⚠️ **Development Only**: These hardcoded credentials are for testing only.

For production:
1. Implement proper authentication
2. Use Firebase Auth or similar
3. Store credentials securely
4. Remove hardcoded credentials

## Testing the Login

### Test Case 1: Valid Credentials
- Email: `admin@gmail.com`
- Password: `admin000`
- Result: ✅ Login successful

### Test Case 2: Wrong Email
- Email: `user@gmail.com`
- Password: `admin000`
- Result: ❌ "Invalid email or password"

### Test Case 3: Wrong Password
- Email: `admin@gmail.com`
- Password: `wrongpassword`
- Result: ❌ "Invalid email or password"

### Test Case 4: Empty Fields
- Email: (empty)
- Password: (empty)
- Result: ❌ "Please enter email and password"

## Features

### Login Screen Updates
- Email input field
- Password input field
- Password visibility toggle
- Error message display
- Demo credentials display
- Professional UI

### Demo Credentials Box
Shows:
- "Demo Credentials:" label
- Email: admin@gmail.com
- Password: admin000

This helps users remember the test credentials.

## Next Steps

1. **Run the app**: `flutter run`
2. **Select role**: Choose your role
3. **Login**: Use admin credentials
4. **Explore**: Test all features
5. **Create assessments**: Start using the app

## Available After Login

✅ **Role-based dashboard**
✅ **Assessment setup**
✅ **Question delivery**
✅ **Results generation**
✅ **API integration** (Groq)

## Notes

- Login is completely offline
- No internet required for login
- Internet required for API suggestions only
- Credentials are case-sensitive
- Email field validates format but accepts any value

## File Changes

### Modified Files
1. `lib/screens/auth/login_screen.dart`
   - Added email/password fields
   - Added password visibility toggle
   - Added error handling
   - Added credential validation

2. `android/app/src/main/AndroidManifest.xml`
   - Added INTERNET permission
   - Allows API calls

## Troubleshooting

### "Invalid email or password"
- Verify exact email: `admin@gmail.com`
- Verify exact password: `admin000`
- Check for typos (case-sensitive)

### "Please enter email and password"
- Make sure both fields are filled
- Don't leave either empty

### App won't connect to internet
- Check AndroidManifest.xml has INTERNET permission
- Verify device has internet connection
- Restart the app

## Production Considerations

For real-world deployment:

1. **User Management**
   - Implement proper user database
   - Hash passwords securely
   - Use authentication tokens

2. **Security**
   - Never hardcode credentials
   - Use OAuth/OpenID Connect
   - Implement 2FA

3. **Error Handling**
   - Secure error messages
   - Prevent account enumeration
   - Rate limit login attempts

## Technical Details

### Hardcoded Constants
```dart
static const String ADMIN_EMAIL = 'admin@gmail.com';
static const String ADMIN_PASSWORD = 'admin000';
```

### Email Extraction
User name is extracted from email:
```dart
final nameFromEmail = email.split('@')[0].toUpperCase();
// admin@gmail.com → ADMIN
```

### Internet Permission
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

**Ready to login?** Run the app and use the demo credentials!
