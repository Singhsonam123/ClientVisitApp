# Complete Token Injection Fix

## Issue Summary

The `getProjects` API returns `401 Unauthorized` because the token is not being sent in the `Authorization` header. This happens because:

1. **Token extraction fails** - The backend response format doesn't match expected keys
2. **Token is not persisted** - Empty token is saved to SharedPreferences
3. **Token is not restored** - On app restart, empty token is restored
4. **Interceptor has nothing to inject** - Authorization header is not added

## Root Cause

The `_extractToken()` method in `AuthRepository` looks for:
```dart
responseData['token'] ?? responseData['access_token'] ?? responseData['accessToken'] ?? ''
```

But your backend likely returns the token with a **different key name**.

## Solution

### Step 1: Identify Your Backend's Token Key

Run the app with the logging we added and perform a login. Check the console output:

```
[AUTH] Login response data: {key1: value1, key2: value2, ...}
```

Look for which key contains the JWT token (usually a long string starting with `eyJ`).

### Step 2: Update Token Extraction

Once you identify the key, update `lib/features/auth/data/auth_repository.dart`:

```dart
String _extractToken(dynamic responseData) {
  print('[AUTH] _extractToken called with: $responseData');
  if (responseData is String) {
    print('[AUTH] Token is String: ${responseData.substring(0, 20)}...');
    return responseData;
  }
  if (responseData is Map) {
    print('[AUTH] Response keys: ${responseData.keys.toList()}');
    
    // Try common key names first
    final token = responseData['token'] as String?
        ?? responseData['access_token'] as String?
        ?? responseData['accessToken'] as String?
        ?? responseData['access'] as String?  // Add if backend uses this
        ?? responseData['jwt'] as String?      // Add if backend uses this
        ?? '';
    
    print('[AUTH] Extracted token: ${token.isEmpty ? "EMPTY" : token.substring(0, 20)}...');
    return token;
  }
  print('[AUTH] WARNING: Could not extract token from response');
  return '';
}
```

### Step 3: Verify Token Persistence

After login, check the logs show:
```
[AUTH] Saving session with token: eyJ0eXAi...
[AUTH] Token saved to SharedPreferences and ApiClient
```

### Step 4: Verify Token Restoration on Startup

When the app starts, check the logs show:
```
[AUTH] currentEmployee getter called - isLoggedIn: true
[AUTH] Retrieved token from SharedPreferences: eyJ0eXAi...
[AUTH] Token restored to ApiClient
```

### Step 5: Verify Token Injection in Requests

When `getProjects` is called, check the logs show:
```
[API] Current token: eyJ0eXAi...
[API] Authorization header set: Bearer eyJ0eXAi...
```

## If Token is Still Not Working

### Check 1: Is the token being extracted?
Look for: `[AUTH] Extracted token: eyJ0eXAi...`
- If you see `EMPTY`, the key name is wrong
- Update `_extractToken()` with the correct key

### Check 2: Is the token being saved?
Look for: `[AUTH] Token saved to SharedPreferences and ApiClient`
- If missing, `_saveSession()` is not being called
- Check login response status code is 200

### Check 3: Is the token being restored?
Look for: `[AUTH] Token restored to ApiClient`
- If missing, `currentEmployee` getter is not being called
- Check `AuthCheckRequested` is being triggered in `main.dart`

### Check 4: Is the token being injected?
Look for: `[API] Authorization header set: Bearer eyJ0eXAi...`
- If you see `WARNING: No token available`, the token is null
- Check previous steps

## Backend Response Format Examples

### Django REST Framework (Common)
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {...}
}
```
**Fix**: Add `responseData['access']` to token extraction

### Standard JWT
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {...}
}
```
**Fix**: Already supported

### OAuth2 Style
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "Bearer",
  "user": {...}
}
```
**Fix**: Already supported

## Complete Fixed `_extractToken()` Method

```dart
String _extractToken(dynamic responseData) {
  print('[AUTH] _extractToken called');
  
  if (responseData is String) {
    print('[AUTH] Token is String type');
    return responseData;
  }
  
  if (responseData is Map) {
    print('[AUTH] Response keys: ${responseData.keys.toList()}');
    
    // Try all common token key names
    final token = responseData['token'] as String?
        ?? responseData['access_token'] as String?
        ?? responseData['accessToken'] as String?
        ?? responseData['access'] as String?
        ?? responseData['jwt'] as String?
        ?? responseData['auth_token'] as String?
        ?? '';
    
    if (token.isNotEmpty) {
      print('[AUTH] ✓ Token extracted successfully (${token.length} chars)');
    } else {
      print('[AUTH] ✗ ERROR: Token not found in response!');
      print('[AUTH] Response data: $responseData');
    }
    
    return token;
  }
  
  print('[AUTH] ✗ ERROR: Response is neither String nor Map');
  return '';
}
```

## Testing Checklist

- [ ] Login successfully
- [ ] Check `[AUTH] Token extracted successfully` in logs
- [ ] Check `[AUTH] Token saved to SharedPreferences and ApiClient` in logs
- [ ] Check `[API] Authorization header set: Bearer` in logs
- [ ] Verify `getProjects` returns 200 OK (not 401)
- [ ] Close and reopen app
- [ ] Check `[AUTH] Token restored to ApiClient` in logs
- [ ] Verify `getProjects` still works after app restart

## If Still Failing

1. **Check backend is running** - Verify `http://10.0.2.2:8000/api/projects/` is accessible
2. **Check token format** - Verify backend expects `Authorization: Bearer <token>` format
3. **Check token expiration** - Verify token is not expired
4. **Check CORS** - Verify backend allows requests from Flutter app
5. **Check endpoint** - Verify `/api/projects/` is the correct endpoint

## Files to Modify

1. `lib/features/auth/data/auth_repository.dart` - Update `_extractToken()` method
2. Keep logging in place for debugging
3. Remove logging once working (optional)
