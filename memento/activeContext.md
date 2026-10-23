# Active Context

## Current Status
**401 Token Refresh Implementation Complete.** The app now automatically attempts to refresh the access token when a 401 Unauthorized response is received. If refresh fails, a session expired toast is shown and the user is navigated to the login page.

## What Was Just Completed (This Session)

### 1. **Token Refresh Infrastructure**
- Added `prefKeyRefreshToken` constant to [`lib/core/constants/app_constants.dart`](lib/core/constants/app_constants.dart)
- Enhanced [`lib/core/network/api_client.dart`](lib/core/network/api_client.dart) with:
  - Refresh token storage (`_refreshToken`)
  - Session expired callback mechanism (`_onSessionExpired`)
  - Race condition prevention (`_isRefreshing` flag)
  - `_refreshAccessToken()` method to obtain new tokens
  - Error interceptor enhancement to handle 401 responses

### 2. **Authentication Repository Updates**
- Updated [`lib/features/auth/data/auth_repository.dart`](lib/features/auth/data/auth_repository.dart):
  - `_saveSession()` now accepts and saves refresh token
  - `login()` extracts and saves refresh token from response
  - `signup()` extracts and saves refresh token from response
  - `logout()` clears both access and refresh tokens
  - `currentEmployee` getter restores refresh token on app startup
  - Added `_extractRefreshToken()` helper method

### 3. **Auth BLoC Enhancement**
- Updated [`lib/features/auth/presentation/bloc/auth_bloc.dart`](lib/features/auth/presentation/bloc/auth_bloc.dart):
  - Added `SessionExpiredEvent` to trigger session expiration
  - Added `AuthSessionExpired` state for UI navigation
  - Added `_onSessionExpired()` handler to log out user

### 4. **UI/UX Components**
- Created [`lib/core/utils/toast_utils.dart`](lib/core/utils/toast_utils.dart) for toast notifications
- Updated [`lib/main.dart`](lib/main.dart):
  - Changed `AppRouter` from `StatelessWidget` to `StatefulWidget`
  - Added `BlocListener` to handle session expired state
  - Shows error toast: "Session expired, please login again"
  - Navigates to login page on session expiration
  - Registered session expired callback in ApiClient

### 5. **Documentation**
- Created comprehensive [`TOKEN_REFRESH_401_IMPLEMENTATION.md`](TOKEN_REFRESH_401_IMPLEMENTATION.md) with:
  - Architecture overview and flow diagrams
  - Implementation details for each component
  - Token refresh flow (success and failure paths)
  - Race condition prevention explanation
  - Response format support documentation
  - Backend requirements
  - Testing strategies
  - Logging details

## Active Decisions
- Refresh token is stored in SharedPreferences alongside access token
- Session expired callback is set up in `main.dart` during app initialization
- Toast messages use `SnackBar` with floating behavior for better visibility
- Multiple simultaneous refresh attempts are prevented with `_isRefreshing` flag
- Failed refresh attempts trigger immediate logout and navigation to login

## How It Works

### 401 Response Flow
1. API request receives 401 Unauthorized
2. Error interceptor detects 401 status code
3. Checks if refresh is already in progress (prevents race conditions)
4. Attempts to refresh token using saved refresh token
5. **On Success**: Updates token, retries original request, user continues
6. **On Failure**: Invokes session expired callback → emits `SessionExpiredEvent` → shows toast → navigates to login

### Token Refresh Endpoint
```
POST /auth/refresh/
{
  "refresh_token": "<saved_refresh_token>"
}

Response (200 OK):
{
  "access_token": "<new_token>",
  "token": "<new_token>"
}
```

## Ready to Test
The implementation is complete and ready for testing:
1. Ensure backend has `/auth/refresh/` endpoint
2. Backend should return both `access_token` and `refresh_token` on login
3. Test with expired access token to verify automatic refresh
4. Test with invalid refresh token to verify session expiration flow

## Next Steps
1. **Backend Integration**: Verify backend `/auth/refresh/` endpoint returns correct token format
2. **End-to-end Testing**: Test token refresh flow with real API
3. **Error Scenarios**: Test various failure scenarios (invalid refresh token, network errors, etc.)
4. **Optional Enhancements**:
   - Implement proactive token refresh (before expiry)
   - Add exponential backoff for refresh retries
   - Implement refresh token rotation
   - Add analytics for token refresh metrics

## Known Limitations
- Toast messages require `ScaffoldMessenger` context (works in pages with Scaffold)
- Refresh token must be provided by backend on login/signup
- No offline support for token refresh (requires network)
