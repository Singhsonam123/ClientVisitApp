# Implementation Summary: 401 Token Refresh & Loading Indicator

## Overview
This implementation adds two key features:
1. **Automatic 401 Token Refresh** - When access token expires, the system automatically attempts to refresh it using the saved refresh token
2. **Project Loading Indicator** - Shows a loading spinner on the home screen while projects are being fetched

## Features Implemented

### 1. 401 Token Refresh with Automatic Retry

#### How It Works
```
API Request (with expired access token)
    ↓
401 Unauthorized Response
    ↓
Attempt to refresh token using refresh_token
    ↓
    ├─ Success: Update token, retry original request
    │
    └─ Failure: Show session expired toast, navigate to login
```

#### Key Components

**ApiClient** (`lib/core/network/api_client.dart`)
- Detects 401 responses in error interceptor
- Prevents race conditions with `_isRefreshing` flag
- Calls `_refreshAccessToken()` to obtain new token
- Retries original request on success
- Invokes session expired callback on failure

**AuthRepository** (`lib/features/auth/data/auth_repository.dart`)
- Extracts and saves refresh token from login/signup responses
- Restores refresh token on app startup
- Clears refresh token on logout

**AuthBloc** (`lib/features/auth/presentation/bloc/auth_bloc.dart`)
- Emits `AuthSessionExpired` state when refresh fails
- Logs out user automatically

**Main App** (`lib/main.dart`)
- Registers session expired callback
- Shows "Session expired, please login again" toast
- Navigates to login page

#### Response Format Support
The implementation supports multiple token key names:
- **Access Token**: `access_token`, `token`, `accessToken`, `access`, `jwt`, `auth_token`
- **Refresh Token**: `refresh_token`, `refreshToken`, `refresh`

### 2. Project Loading Indicator

#### How It Works
```
Home Page Loads
    ↓
Show loading spinner overlay (_isLoadingProjects = true)
    ↓
Fetch projects from API
    ↓
API returns response or throws exception
    ↓
Hide loading spinner (_isLoadingProjects = false)
    ↓
Display projects or error message
```

#### Implementation Details
**HomePage** (`lib/features/home/presentation/pages/home_page.dart`)
- Added `_isLoadingProjects` boolean state (initialized to `true`)
- Shows `CircularProgressIndicator` overlay while loading
- **On Success**: Sets `_isLoadingProjects = false` (line 80)
- **On Exception**: Sets `_isLoadingProjects = false` (line 89)
- Overlay has semi-transparent dark background for visibility

**Key Point**: The loader stops in BOTH cases:
- When API returns successful response
- When API throws an exception

## Files Modified

### Core Network
- **`lib/core/network/api_client.dart`**
  - Added refresh token storage and management
  - Enhanced error interceptor with 401 handling
  - Implemented `_refreshAccessToken()` method
  - Added session expired callback mechanism

### Authentication
- **`lib/core/constants/app_constants.dart`**
  - Added `prefKeyRefreshToken` constant

- **`lib/features/auth/data/auth_repository.dart`**
  - Updated `_saveSession()` to save refresh token
  - Updated `login()` and `signup()` to extract refresh token
  - Updated `logout()` to clear refresh token
  - Updated `currentEmployee` getter to restore refresh token
  - Added `_extractRefreshToken()` helper method

- **`lib/features/auth/presentation/bloc/auth_bloc.dart`**
  - Added `SessionExpiredEvent` class
  - Added `AuthSessionExpired` state class
  - Added `_onSessionExpired()` handler

### UI/UX
- **`lib/core/utils/toast_utils.dart`** (NEW)
  - Created toast utility for showing notifications
  - Methods: `showToast()`, `showErrorToast()`, `showSuccessToast()`, `showWarningToast()`

- **`lib/main.dart`**
  - Changed `AppRouter` to `StatefulWidget`
  - Added `BlocListener` for session expired state
  - Registered session expired callback in ApiClient
  - Shows error toast on session expiration

- **`lib/features/home/presentation/pages/home_page.dart`**
  - Added `_isLoadingProjects` state variable (initialized to `true`)
  - Updated `_loadProjects()` to set `_isLoadingProjects = false` on success
  - Updated `_loadProjects()` to set `_isLoadingProjects = false` on exception
  - Added loading overlay in build method using `Stack`

## Backend Requirements

### Token Refresh Endpoint
```
POST /auth/refresh/
Content-Type: application/json

Request Body:
{
  "refresh_token": "<refresh_token>"
}

Response (200 OK):
{
  "access_token": "<new_access_token>",
  "token": "<new_access_token>"
}

Response (401/403):
{
  "error": "Invalid or expired refresh token"
}
```

### Login/Signup Response Format
```json
{
  "token": "eyJhbGc...",
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "displayName": "John Doe",
  "id": "user123",
  "email": "john@example.com",
  "department": "Engineering"
}
```

## Testing Checklist

### Token Refresh Testing
- [ ] Login with valid credentials
- [ ] Verify both access and refresh tokens are saved
- [ ] Wait for access token to expire (or manually expire it)
- [ ] Make an API request
- [ ] Verify token is automatically refreshed
- [ ] Verify original request succeeds with new token
- [ ] Check logs for `[API] Token refreshed successfully`

### Session Expiration Testing
- [ ] Login with valid credentials
- [ ] Manually invalidate refresh token in SharedPreferences
- [ ] Wait for access token to expire
- [ ] Make an API request
- [ ] Verify "Session expired, please login again" toast appears
- [ ] Verify user is navigated to login page
- [ ] Check logs for `[API] Invoking session expired callback`

### Loading Indicator Testing
- [ ] Navigate to home page
- [ ] Verify loading spinner appears immediately
- [ ] Verify loading spinner disappears after projects load successfully
- [ ] Verify loading spinner disappears when API throws exception
- [ ] Test with slow network to see loading state clearly
- [ ] Verify error toast appears when projects fail to load

### Race Condition Testing
- [ ] Make multiple API requests simultaneously after token expires
- [ ] Verify only one token refresh attempt is made
- [ ] Verify all requests succeed with new token
- [ ] Check logs for `[API] Token refresh already in progress, waiting...`

## Logging Output

### Successful Token Refresh
```
[API] 401 Unauthorized received
[API] Attempting to refresh token using refresh token: eyJhbGc...
[API] Sending refresh token request
[API] Token refreshed successfully
[API] New token saved to SharedPreferences
```

### Failed Token Refresh
```
[API] 401 Unauthorized received
[API] Attempting to refresh token using refresh token: eyJhbGc...
[API] Token refresh failed - session expired
[API] Invoking session expired callback
[AUTH] Session expired - logging out user
[MAIN] Session expired callback triggered
```

### Project Loading
```
Home page loads
[Loading spinner visible]
Projects API request sent
Projects API response received
[Loading spinner hidden]
Projects displayed
```

## Security Considerations

1. **Refresh Token Storage**: Stored in SharedPreferences (suitable for mobile apps)
2. **Token Expiry**: Implement server-side token expiry (recommended: 15-30 minutes for access token)
3. **Refresh Token Rotation**: Consider implementing refresh token rotation for enhanced security
4. **HTTPS Only**: Ensure all API calls use HTTPS in production
5. **Token Validation**: Backend should validate refresh token before issuing new access token

## Performance Considerations

1. **Race Condition Prevention**: Only one token refresh attempt at a time
2. **Minimal Overhead**: Token refresh only happens on 401 responses
3. **Automatic Retry**: Failed requests are automatically retried without user intervention
4. **Loading Indicator**: Provides visual feedback during project loading
5. **Loader Stops on Both Success and Exception**: Ensures UI is always responsive

## Future Enhancements

1. **Proactive Token Refresh**: Refresh token before it expires (e.g., 5 minutes before expiry)
2. **Exponential Backoff**: Implement retry logic with exponential backoff for refresh failures
3. **Refresh Token Rotation**: Implement refresh token rotation for enhanced security
4. **Offline Support**: Cache tokens and handle offline scenarios
5. **Analytics**: Track token refresh success/failure rates
6. **Token Expiry Countdown**: Show warning before token expires
7. **Multiple Device Support**: Handle token refresh across multiple devices

## Troubleshooting

### Issue: "Session expired" toast appears immediately after login
**Solution**: Verify backend is returning both `access_token` and `refresh_token` in login response

### Issue: Token refresh fails with 401
**Solution**: Check if refresh token is valid and not expired on backend

### Issue: Multiple token refresh attempts
**Solution**: This shouldn't happen due to `_isRefreshing` flag. Check logs for race conditions

### Issue: Loading spinner doesn't disappear
**Solution**: Verify `_loadProjects()` is setting `_isLoadingProjects = false` in both success (line 80) and exception (line 89) cases

### Issue: Loading spinner appears but projects don't load
**Solution**: Check API response format and verify `ProjectsRemoteDataSourceImpl` is working correctly

## Deployment Checklist

- [ ] Backend `/auth/refresh/` endpoint is implemented and tested
- [ ] Backend returns both `access_token` and `refresh_token` on login
- [ ] Access token expiry is set appropriately (15-30 minutes recommended)
- [ ] Refresh token expiry is set appropriately (7-30 days recommended)
- [ ] All API endpoints are using HTTPS in production
- [ ] Error handling is tested for various failure scenarios
- [ ] Loading indicator is visible and responsive
- [ ] Loading indicator stops on both success and exception
- [ ] Toast messages are displaying correctly
- [ ] Navigation to login page works on session expiration
- [ ] Logs are configured appropriately for production

## Code Quality

- ✅ No compilation errors
- ✅ Flutter analyze passes (only info-level warnings)
- ✅ Proper error handling in all code paths
- ✅ Race condition prevention implemented
- ✅ Loading state managed correctly
- ✅ Comprehensive logging for debugging

## Documentation Files

- `TOKEN_REFRESH_401_IMPLEMENTATION.md` - Detailed technical documentation
- `IMPLEMENTATION_SUMMARY.md` - This file
- `memento/activeContext.md` - Current work status
- `memento/progress.md` - Overall project progress
