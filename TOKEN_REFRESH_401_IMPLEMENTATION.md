# 401 Token Refresh Implementation

## Overview
This document describes the implementation of automatic token refresh on 401 Unauthorized responses. When a 401 status code is received, the system attempts to generate a new access token using the saved refresh token. If the refresh fails, a session expired toast is shown and the user is navigated to the login page.

## Architecture

### Flow Diagram
```
API Request (with access token)
    ↓
401 Unauthorized Response
    ↓
Check if already refreshing (prevent multiple simultaneous refreshes)
    ↓
Attempt token refresh using refresh_token
    ↓
    ├─ Success: Update token, retry original request
    │
    └─ Failure: Invoke session expired callback
         ↓
         Show "Session expired, please login again" toast
         ↓
         Navigate to login page
```

## Implementation Details

### 1. **AppConstants** (`lib/core/constants/app_constants.dart`)
Added refresh token storage key:
```dart
static const String prefKeyRefreshToken  = 'refresh_token';
```

### 2. **ApiClient** (`lib/core/network/api_client.dart`)

#### New Static Members
- `_refreshToken`: Stores the refresh token
- `_isRefreshing`: Flag to prevent multiple simultaneous refresh attempts
- `_onSessionExpired`: Callback function invoked when session expires

#### New Methods
- `setRefreshToken(String? token)`: Store refresh token
- `setOnSessionExpired(Function callback)`: Register session expired callback
- `_refreshAccessToken()`: Attempts to refresh the access token using the refresh token

#### Error Interceptor Enhancement
The `onError` interceptor now:
1. Detects 401 Unauthorized responses
2. Checks if a refresh is already in progress (prevents race conditions)
3. Calls `_refreshAccessToken()` to obtain a new token
4. On success: Retries the original request with the new token
5. On failure: Invokes the session expired callback

### 3. **AuthRepository** (`lib/features/auth/data/auth_repository.dart`)

#### Updated Methods
- `_saveSession()`: Now accepts optional `refreshToken` parameter and saves it to SharedPreferences and ApiClient
- `login()`: Extracts and saves refresh token from login response
- `signup()`: Extracts and saves refresh token from signup response
- `logout()`: Clears both access token and refresh token
- `currentEmployee` getter: Restores refresh token from SharedPreferences on app startup

#### New Helper Method
- `_extractRefreshToken()`: Extracts refresh token from response data, trying multiple common key names:
  - `refresh_token`
  - `refreshToken`
  - `refresh`

### 4. **AuthBloc** (`lib/features/auth/presentation/bloc/auth_bloc.dart`)

#### New Event
- `SessionExpiredEvent`: Emitted when session expires (triggered by ApiClient callback)

#### New State
- `AuthSessionExpired`: Indicates session has expired and user should re-login

#### New Handler
- `_onSessionExpired()`: Logs out the user and emits `AuthSessionExpired` state

### 5. **Toast Utility** (`lib/core/utils/toast_utils.dart`)
New utility class for showing toast messages:
- `showToast()`: Generic toast with customizable styling
- `showErrorToast()`: Red error toast
- `showSuccessToast()`: Green success toast
- `showWarningToast()`: Orange warning toast

### 6. **Main App** (`lib/main.dart`)

#### AppRouter Enhancement
- Changed from `StatelessWidget` to `StatefulWidget`
- Added `BlocListener` to listen for `AuthSessionExpired` state
- Shows error toast: "Session expired, please login again"
- Navigates to login page when session expires

#### Session Expired Callback Setup
```dart
ApiClient.setOnSessionExpired(() {
  authBloc.add(const SessionExpiredEvent());
});
```

## Token Refresh Flow

### Step 1: Access Token Expires
When an API request receives a 401 response:
```
GET /api/projects/
Authorization: Bearer <expired_token>
↓
401 Unauthorized
```

### Step 2: Automatic Refresh Attempt
The error interceptor automatically attempts to refresh:
```
POST /auth/refresh/
{
  "refresh_token": "<saved_refresh_token>"
}
```

### Step 3: Success Path
If refresh succeeds (200 OK):
```json
{
  "access_token": "<new_token>",
  "token": "<new_token>"
}
```
- New token is stored in ApiClient and SharedPreferences
- Original request is retried with new token
- User continues without interruption

### Step 4: Failure Path
If refresh fails (401, 403, 500, etc.):
1. Session expired callback is invoked
2. `SessionExpiredEvent` is added to AuthBloc
3. User is logged out
4. `AuthSessionExpired` state is emitted
5. Toast is shown: "Session expired, please login again"
6. User is navigated to login page

## Race Condition Prevention

The implementation prevents multiple simultaneous token refresh attempts:

```dart
if (!_isRefreshing) {
  _isRefreshing = true;
  // Attempt refresh
} else {
  // Wait for refresh to complete
  await Future.delayed(const Duration(milliseconds: 500));
  // Retry with new token
}
```

## Response Format Support

The implementation supports multiple response formats for tokens:

**Access Token Keys:**
- `access_token`
- `token`
- `accessToken`
- `access`
- `jwt`
- `auth_token`

**Refresh Token Keys:**
- `refresh_token`
- `refreshToken`
- `refresh`

## Backend Requirements

The backend must provide:

1. **Login/Signup Response** should include both tokens:
```json
{
  "token": "eyJhbGc...",
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "displayName": "John Doe",
  "id": "user123"
}
```

2. **Token Refresh Endpoint** (`POST /auth/refresh/`):
```
Request:
{
  "refresh_token": "<refresh_token>"
}

Response (200 OK):
{
  "access_token": "<new_token>",
  "token": "<new_token>"
}

Response (401/403):
{
  "error": "Invalid refresh token"
}
```

## Testing

### Test Case 1: Successful Token Refresh
1. Login with valid credentials
2. Wait for access token to expire
3. Make an API request
4. Verify token is automatically refreshed
5. Verify original request succeeds

### Test Case 2: Failed Token Refresh
1. Login with valid credentials
2. Manually invalidate refresh token in SharedPreferences
3. Wait for access token to expire
4. Make an API request
5. Verify "Session expired, please login again" toast appears
6. Verify user is navigated to login page

### Test Case 3: Multiple Simultaneous Requests
1. Login with valid credentials
2. Make multiple API requests simultaneously after token expires
3. Verify only one token refresh attempt is made
4. Verify all requests succeed with new token

## Logging

The implementation includes comprehensive logging for debugging:

**ApiClient logs:**
- `[API] 401 Unauthorized received`
- `[API] Attempting to refresh token using refresh token: ...`
- `[API] Token refreshed successfully`
- `[API] Token refresh failed - session expired`
- `[API] Invoking session expired callback`

**AuthRepository logs:**
- `[AUTH] Retrieved refresh token from SharedPreferences: ...`
- `[AUTH] Refresh token restored to ApiClient`

**AuthBloc logs:**
- `[AUTH] Session expired - logging out user`

**Main logs:**
- `[MAIN] Session expired callback triggered`

## Files Modified

1. `lib/core/constants/app_constants.dart` - Added refresh token key
2. `lib/core/network/api_client.dart` - Added token refresh logic
3. `lib/features/auth/data/auth_repository.dart` - Added refresh token handling
4. `lib/features/auth/presentation/bloc/auth_bloc.dart` - Added session expired event/state
5. `lib/main.dart` - Added session expired callback setup and UI handling
6. `lib/core/utils/toast_utils.dart` - Created new toast utility

## Future Enhancements

1. **Exponential Backoff**: Implement retry logic with exponential backoff for refresh failures
2. **Token Expiry Proactive Refresh**: Refresh token before it expires (e.g., 5 minutes before expiry)
3. **Refresh Token Rotation**: Implement refresh token rotation for enhanced security
4. **Offline Support**: Cache tokens and handle offline scenarios
5. **Analytics**: Track token refresh success/failure rates
