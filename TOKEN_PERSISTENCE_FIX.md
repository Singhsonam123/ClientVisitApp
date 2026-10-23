# Token Persistence Issue & Fix

## Problem Statement

The `getProjects` API call is returning `401 Unauthorized` with the message "Authentication credentials were not provided." This means the bearer token is not being sent in the `Authorization` header.

## Root Cause Analysis

The token flow has multiple potential failure points:

### 1. Token Extraction Failure
The `_extractToken()` method looks for the token in these keys (in order):
- `token`
- `access_token`
- `accessToken`

**If your backend returns the token with a different key name, it will extract an empty string.**

### 2. Token Not Being Saved
Even if the token is extracted, it must be saved to:
- SharedPreferences (for persistence across app restarts)
- ApiClient._token (for immediate use in subsequent requests)

### 3. Token Not Being Restored on App Startup
When the app restarts, the `AuthCheckRequested` event triggers `currentEmployee` getter which should:
- Retrieve the token from SharedPreferences
- Call `ApiClient.setToken(token)` to restore it in memory

### 4. Timing Issues
The `HomePage` calls `_loadProjects()` with only a 100ms delay, which might not be enough time for the token to be set in `ApiClient`.

## Solution

### Step 1: Identify Backend Token Response Format

Add logging to see what your backend actually returns:

```dart
print('[AUTH] Login response data: ${response.data}');
```

Check the logs to see the exact JSON structure. Common formats:
- `{"token": "eyJ0eXAi...", "user": {...}}`
- `{"access_token": "eyJ0eXAi...", "user": {...}}`
- `{"accessToken": "eyJ0eXAi...", "user": {...}}`

### Step 2: Update Token Extraction

If your backend uses a different key, update `_extractToken()`:

```dart
String _extractToken(dynamic responseData) {
  if (responseData is String) return responseData;
  if (responseData is Map) {
    return responseData['token'] as String?
        ?? responseData['access_token'] as String?
        ?? responseData['accessToken'] as String?
        ?? responseData['YOUR_CUSTOM_KEY'] as String?  // Add your key here
        ?? '';
  }
  return '';
}
```

### Step 3: Verify Token is Being Saved

The logging added to `_saveSession()` will show:
```
[AUTH] Saving session with token: eyJ0eXAi...
[AUTH] Token saved to SharedPreferences and ApiClient
```

### Step 4: Verify Token is Being Restored

The logging added to `currentEmployee` getter will show:
```
[AUTH] currentEmployee getter called - isLoggedIn: true
[AUTH] Retrieved token from SharedPreferences: eyJ0eXAi...
[AUTH] Token restored to ApiClient
```

### Step 5: Verify Token is Being Injected

The logging in `ApiClient` interceptor will show:
```
[API] Current token: eyJ0eXAi...
[API] Authorization header set: Bearer eyJ0eXAi...
```

Or if the token is missing:
```
[API] Current token: null
[API] WARNING: No token available for request
```

## Token Flow Diagram

```
Login Request
    ↓
Backend returns token (in response.data)
    ↓
_extractToken() extracts token from response
    ↓
_saveSession() saves token to:
  - SharedPreferences (key: 'auth_token')
  - ApiClient._token (static variable)
    ↓
ApiClient interceptor injects token in Authorization header
    ↓
getProjects() API call includes: Authorization: Bearer <token>
    ↓
Backend accepts request (200 OK)

---

App Restart
    ↓
AuthCheckRequested event
    ↓
currentEmployee getter retrieves token from SharedPreferences
    ↓
ApiClient.setToken(token) restores token in memory
    ↓
getProjects() API call includes: Authorization: Bearer <token>
```

## Debugging Checklist

- [ ] Check login response contains a token field
- [ ] Verify token extraction is working (check logs for extracted token length)
- [ ] Verify token is being saved to SharedPreferences
- [ ] Verify token is being restored on app startup
- [ ] Verify ApiClient interceptor is injecting the token
- [ ] Check if backend expects a different Authorization header format

## Common Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| Token key mismatch | Token extraction returns empty string | Update `_extractToken()` with correct key |
| Token not saved | `currentEmployee` returns null | Check `_saveSession()` is being called |
| Token not restored | Interceptor shows "No token available" | Ensure `currentEmployee` getter is called on startup |
| Timing issue | Token is set but request happens before | Increase delay in `HomePage.initState()` |
| Wrong header format | Backend rejects "Bearer token" | Check backend expects "Bearer" prefix |

## Files Modified

1. `lib/core/network/api_client.dart` - Added logging to interceptor
2. `lib/features/auth/data/auth_repository.dart` - Added logging to token extraction and saving
