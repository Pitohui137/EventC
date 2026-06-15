# Authentication Implementation Guide

## Overview
This document describes the complete authentication system implementation for the Event Management System.

## Architecture

### Components

#### 1. **AuthService** (`lib/services/auth_service.dart`)
Singleton service that handles all authentication operations with Supabase.

**Methods:**
- `register()` - User registration with validation
- `login()` - User login with email/password
- `logout()` - User logout
- `getCurrentUser()` - Fetch current user profile
- `resetPassword()` - Password reset flow
- `updatePassword()` - Update user password
- `updateProfile()` - Update user profile
- `emailExists()` - Check if email is registered
- `verifyEmail()` - Email verification (optional)

#### 2. **AuthProvider** (`lib/services/auth_provider.dart`)
ChangeNotifier provider for state management using the Provider package.

**Properties:**
- `currentUser` - Current authenticated user
- `isLoading` - Loading state
- `errorMessage` - Error messages
- `isLoggedIn` - Authentication state
- `isAdmin` - Admin role check
- `isUser` - User role check

**Methods:**
- `register()` - Register and notify listeners
- `login()` - Login and notify listeners
- `logout()` - Logout and notify listeners
- `resetPassword()` - Send password reset email
- `updatePassword()` - Change password
- `updateProfile()` - Update profile
- `clearError()` - Clear error messages

#### 3. **Screens**

**SplashScreen** (`lib/screens/auth/splash_screen.dart`)
- Animated splash screen (3 seconds)
- Checks authentication state on startup
- Routes to appropriate screen based on user role

**LoginScreen** (`lib/screens/auth/login_screen.dart`)
- Email and password login form
- Password visibility toggle
- Remember me checkbox
- Forgot password dialog
- Error message display
- Link to registration page

**RegisterScreen** (`lib/screens/auth/register_screen.dart`)
- Full registration form
- Email, password, confirm password fields
- Optional: phone number, origin/institution
- Role selection: User or Admin
- Terms & conditions agreement
- Password validation
- Input validation
- Error handling

## Flow Diagram

```
┌─────────────────┐
│  SplashScreen   │
│   (3 seconds)   │
└────────┬────────┘
         │
    ┌────▼────┐
    │  Check  │
    │   Auth  │
    └────┬────┘
         │
    ┌────┴────────────────┐
    │                     │
    ▼                     ▼
┌─────────────┐    ┌───────────────┐
│  Logged In? │    │  Not Logged?  │
└─────┬───────┘    └───────┬───────┘
      │                    │
  ┌───┴───┐            ┌───┴────┐
  │       │            │        │
  ▼       ▼            ▼        ▼
┌──────┐┌────────────────────────────┐
│Admin││        Login Screen         │
│Home ││  [Email] [Password]         │
└──────┘│  [ Login ]  [ Register ]   │
  OR    └────────────────────────────┘
┌──────┐    │          │
│User ││    │ Success  │ New User?
│Home ││    │    ▼     │    ▼
└──────┘│ Register Screen
        │  [Full Form + Role]
        │  [ Register ]
        └──────┬────────┘
               │
               ▼
          Dashboard
          (Admin/User)
```

## State Management Flow

```
User Action
    │
    ▼
LoginScreen / RegisterScreen
    │
    ▼
AuthProvider.login() / register()
    │
    ▼
AuthService.login() / register()
    │
    ▼
Supabase Authentication
    │
    ▼
Update AuthProvider State
    │
    ▼
Notify Listeners (UI rebuilds)
    │
    ▼
Navigation to Dashboard
```

## Security Features

### 1. **Password Requirements**
- Minimum 6 characters
- Must be confirmed during registration
- Uses Supabase's bcrypt hashing

### 2. **Email Validation**
- Standard email format validation
- Prevents duplicate emails
- Unique constraint in database

### 3. **Role-Based Access**
- Admin: `role = 'admin'`
- User: `role = 'user'`
- Enforced at database level via RLS

### 4. **Session Management**
- Automatic session tracking via Supabase Auth
- Sessions persist across app restarts
- Secure token storage

### 5. **Error Handling**
- User-friendly error messages
- Validation at both client and server
- No sensitive data in error messages

## Login Flow

```dart
1. User enters email & password
   ↓
2. LoginScreen validates input
   ↓
3. AuthProvider.login() called
   ↓
4. AuthService.login() called
   ↓
5. Supabase authenticates user
   ↓
6. Fetch user profile from DB
   ↓
7. Update AuthProvider state
   ↓
8. Navigate to Admin/User Home based on role
```

## Registration Flow

```dart
1. User fills registration form
   ↓
2. RegisterScreen validates all fields
   ↓
3. Check if email exists (optional)
   ↓
4. Check password match
   ↓
5. AuthProvider.register() called
   ↓
6. AuthService.register() called
   ↓
7. Supabase creates auth user
   ↓
8. Insert user profile with role
   ↓
9. Auto-login user
   ↓
10. Navigate to appropriate dashboard
```

## Logout Flow

```dart
1. User taps logout button
   ↓
2. AuthProvider.logout() called
   ↓
3. AuthService.logout() called
   ↓
4. Supabase destroys session
   ↓
5. Clear user data from provider
   ↓
6. Navigate to login screen
```

## Password Reset Flow

```dart
1. User taps "Forgot Password"
   ↓
2. Enter email in dialog
   ↓
3. AuthProvider.resetPassword() called
   ↓
4. AuthService sends reset email via Supabase
   ↓
5. Show success message
   ↓
6. User clicks link in email
   ↓
7. Reset password in browser/app
```

## Implementation Checklist

### Dependencies Added ✅
- `supabase_flutter: ^2.0.0` - Backend & Auth
- `provider: ^6.0.0` - State management
- `intl: ^0.18.0` - Date/time utilities
- `qr_flutter: ^6.0.0` - QR code generation
- `shared_preferences: ^2.2.0` - Local storage

### Files Created ✅
- `lib/services/auth_service.dart` - Auth business logic
- `lib/services/auth_provider.dart` - State management
- `lib/screens/auth/splash_screen.dart` - Initial screen
- Updated `lib/screens/auth/login_screen.dart` - Complete login
- Updated `lib/screens/auth/register_screen.dart` - Complete registration
- Updated `lib/main.dart` - Provider setup & routing
- Updated `pubspec.yaml` - Dependencies

### Features Implemented ✅
- User registration with validation
- Email/password login
- Password visibility toggle
- Remember me checkbox
- Forgot password flow
- Role-based navigation (Admin/User)
- Error message handling
- Loading states
- Animated splash screen
- Session persistence
- Profile update

## Configuration Required

### In `lib/main.dart`:

Replace these placeholders with your Supabase credentials:
```dart
await Supabase.initialize(
  url: 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

Get these from Supabase Dashboard → Settings → API.

## Testing

### Test Credentials

Create test users in Supabase:

**Admin User:**
- Email: `admin@example.com`
- Password: `Password123`
- Role: `admin`

**Regular User:**
- Email: `user@example.com`
- Password: `Password123`
- Role: `user`

### Test Cases

1. **Login with valid credentials** → Should navigate to dashboard
2. **Login with invalid credentials** → Should show error
3. **Register new user** → Should auto-login
4. **Duplicate email** → Should show error
5. **Password mismatch** → Should show error
6. **Logout** → Should return to login
7. **Forgot password** → Should send email
8. **Session persistence** → Should remain logged in after app restart

## Troubleshooting

### Issue: "UNKNOWN_ERROR"
- Check Supabase credentials in main.dart
- Verify Supabase project is active

### Issue: "Invalid email"
- Use valid email format (test@example.com)

### Issue: "Weak password"
- Password must be minimum 6 characters
- Supabase may have additional requirements

### Issue: "User already exists"
- Email is already registered
- Use different email or reset password

### Issue: Auth state not persisting
- Check that `currentUser` initialization in AuthProvider
- Verify Supabase SDK is properly initialized

## Next Steps

After authentication is working:
1. Test login/register flows
2. Verify role-based navigation
3. Proceed to Step 4: Implement Event CRUD
4. Then: User registration for events
5. Finally: Digital ticket generation

