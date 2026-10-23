# Login Error Handling - Testing Guide

## Overview
This guide provides step-by-step instructions to test the fixed login error handling behavior in the ClientVisitApp.

## Prerequisites

1. **Flutter Environment**: Ensure Flutter is installed and configured
2. **Emulator/Device**: Android emulator or physical device running
3. **Backend API**: Local backend server running on `http://localhost:3000` (or configured URL)
4. **Test Credentials**:
   - Valid: `superadmin@valuelabs.com` / `YourPassword123`
   - Invalid: Any other email/password combination

## Test Scenarios

### Test 1: Successful Login Flow ✅

**Objective**: Verify that correct credentials allow successful login

**Steps**:
1. Launch the app
2. Navigate through splash screen and welcome screen
3. Select a role (e.g., Super Admin)
4. On login screen, enter:
   - Email: `superadmin@valuelabs.com`
   - Password: `YourPassword123`
5. Click "Sign In" button

**Expected Results**:
- ✅ Loading spinner appears immediately
- ✅ Spinner shows for 2-3 seconds while API call is made
- ✅ On success, app navigates to home screen
- ✅ Spinner disappears
- ✅ User data is displayed on home screen
- ✅ Tokens are saved to local storage

**Verification**:
```bash
# Check local storage (via Flutter DevTools or logcat)
# Should contain:
# - auth_token: <jwt_token>
# - refresh_token: <jwt_token>
# - employee_id: <uuid>
# - employee_email: superadmin@valuelabs.com
# - employee_name: Super Admin
# - user_role: SUPER_ADMIN
# - is_logged_in: true
```

---

### Test 2: Login with Incorrect Email ❌

**Objective**: Verify error handling when wrong email is provided

**Steps**:
1. On login screen, enter:
   - Email: `wrong@example.com`
   - Password: `YourPassword123`
2. Click "Sign In" button

**Expected Results**:
- ✅ Loading spinner appears
- ✅ Spinner shows for 2-3 seconds
- ✅ API returns 401/400 error
- ✅ Loading spinner **disappears** (THIS IS THE FIX)
- ✅ Error toast appears: "Invalid email or password"
- ✅ Toast disappears after 3 seconds
- ✅ User remains on login screen
- ✅ Email and password fields are still populated
- ✅ "Sign In" button is enabled and clickable

**Verification**:
- User can immediately enter new credentials
- No infinite loading state
- Can retry without app restart

---

### Test 3: Login with Incorrect Password ❌

**Objective**: Verify error handling when wrong password is provided

**Steps**:
1. On login screen, enter:
   - Email: `superadmin@valuelabs.com`
   - Password: `WrongPassword123`
2. Click "Sign In" button

**Expected Results**:
- ✅ Loading spinner appears
- ✅ Spinner shows for 2-3 seconds
- ✅ API returns 401 error
- ✅ Loading spinner **disappears** (THIS IS THE FIX)
- ✅ Error toast appears: "Invalid email or password"
- ✅ Toast disappears after 3 seconds
- ✅ User remains on login screen
- ✅ Email field shows correct email
- ✅ Password field is cleared (security feature)
- ✅ "Sign In" button is enabled and clickable

**Verification**:
- User can immediately retry with correct password
- No infinite loading state
- Password field is cleared for security

---

### Test 4: Rapid Retry After Error ⚡

**Objective**: Verify that user can quickly retry after an error

**Steps**:
1. On login screen, enter:
   - Email: `wrong@example.com`
   - Password: `WrongPassword123`
2. Click "Sign In" button
3. Wait for error toast to appear
4. Immediately clear email field and enter: `superadmin@valuelabs.com`
5. Clear password field and enter: `YourPassword123`
6. Click "Sign In" button again

**Expected Results**:
- ✅ First attempt shows loading spinner
- ✅ Error toast appears after 2-3 seconds
- ✅ Spinner disappears
- ✅ User can immediately enter new credentials
- ✅ Second attempt shows loading spinner
- ✅ Second attempt succeeds and navigates to home
- ✅ No state conflicts or errors

**Verification**:
- Smooth retry experience
- No app crashes
- No state management issues

---

### Test 5: Empty Email Field ⚠️

**Objective**: Verify client-side validation

**Steps**:
1. On login screen, leave email empty
2. Enter password: `YourPassword123`
3. Click "Sign In" button

**Expected Results**:
- ✅ No API call is made
- ✅ Toast appears: "Please enter email and password"
- ✅ No loading spinner
- ✅ User remains on login screen

**Verification**:
- Client-side validation works
- No unnecessary API calls

---

### Test 6: Empty Password Field ⚠️

**Objective**: Verify client-side validation

**Steps**:
1. On login screen, enter email: `superadmin@valuelabs.com`
2. Leave password empty
3. Click "Sign In" button

**Expected Results**:
- ✅ No API call is made
- ✅ Toast appears: "Please enter email and password"
- ✅ No loading spinner
- ✅ User remains on login screen

**Verification**:
- Client-side validation works
- No unnecessary API calls

---

### Test 7: Network Error Handling 🌐

**Objective**: Verify handling of network/connection errors

**Steps**:
1. Disconnect device from network (or stop backend server)
2. On login screen, enter:
   - Email: `superadmin@valuelabs.com`
   - Password: `YourPassword123`
3. Click "Sign In" button

**Expected Results**:
- ✅ Loading spinner appears
- ✅ Spinner shows for 5-10 seconds (timeout)
- ✅ Loading spinner **disappears** (THIS IS THE FIX)
- ✅ Error toast appears: "Login failed: ..." or connection error
- ✅ User remains on login screen
- ✅ "Sign In" button is enabled

**Verification**:
- Network errors don't cause infinite loading
- User can retry when connection is restored

---

### Test 8: Logout and Re-login ↩️

**Objective**: Verify complete login/logout cycle

**Steps**:
1. Login with correct credentials
2. Navigate to home screen
3. Click logout button (top right)
4. Confirm logout in dialog
5. Wait for logout to complete
6. On login screen, enter wrong credentials
7. Verify error handling
8. Enter correct credentials and login again

**Expected Results**:
- ✅ First login succeeds
- ✅ Logout clears all session data
- ✅ Error handling works on second login attempt
- ✅ Second login with correct credentials succeeds
- ✅ All tokens and user data are properly managed

**Verification**:
- Complete auth cycle works
- Session data is properly cleared
- No residual state from previous session

---

## Debugging Tips

### Check Loading State
```dart
// In login_page.dart
print('Loading state: $_isLoading');
print('Current BLoC state: ${context.read<AuthBloc>().state}');
```

### Monitor BLoC State Changes
```dart
// Add logging to auth_bloc.dart
Future<void> _onCleanLoginRequested(...) async {
  print('🔵 AuthLoading emitted');
  emit(const AuthLoading());
  
  try {
    // ... login logic ...
    print('🟢 AuthAuthenticated emitted');
    emit(AuthAuthenticated(employee));
  } catch (e) {
    print('🔴 AuthFailure emitted: $e');
    emit(AuthFailure(msg));
    await Future.delayed(const Duration(milliseconds: 500));
    print('🟡 AuthUnauthenticated emitted (retry allowed)');
    emit(const AuthUnauthenticated());
  }
}
```

### Check Local Storage
```bash
# Via Flutter DevTools
# Navigate to Storage tab
# Check SharedPreferences for:
# - auth_token
# - refresh_token
# - employee_id
# - employee_email
# - employee_name
# - user_role
# - is_logged_in
```

### Monitor API Calls
```bash
# Check network logs in Android Studio Logcat
# Filter: "http" or "dio"
# Verify:
# - POST /api/auth/login/ is called
# - Request body contains email and password
# - Response contains tokens and user data
```

---

## Success Criteria

All tests should pass with these criteria:

| Test | Status | Notes |
|------|--------|-------|
| Successful login | ✅ | Navigates to home |
| Incorrect email error | ✅ | Shows error, allows retry |
| Incorrect password error | ✅ | Shows error, allows retry |
| Rapid retry | ✅ | No state conflicts |
| Empty email validation | ✅ | Client-side check |
| Empty password validation | ✅ | Client-side check |
| Network error | ✅ | Shows error, allows retry |
| Logout and re-login | ✅ | Complete cycle works |

---

## Common Issues and Solutions

### Issue: Loading spinner still shows after error

**Solution**:
- Ensure auth_bloc.dart emits `AuthUnauthenticated` after `AuthFailure`
- Check that login_page.dart BlocListener handles all states
- Verify `setState(() => _isLoading = false)` is called for error states

### Issue: Error toast doesn't appear

**Solution**:
- Check that `AppToast.showError()` is called in listener
- Verify toast duration is sufficient (default 3 seconds)
- Check that context is valid when showing toast

### Issue: User can't retry after error

**Solution**:
- Ensure BLoC emits `AuthUnauthenticated` state
- Check that "Sign In" button is enabled (not disabled by loading state)
- Verify state listener properly resets `_isLoading` flag

### Issue: App crashes on retry

**Solution**:
- Add `if (mounted)` check before calling `setState()`
- Ensure all resources are properly disposed
- Check for null pointer exceptions in error handling

---

## Performance Metrics

**Expected Timings**:
- Loading spinner display: 2-3 seconds (API call time)
- Error toast display: 3 seconds
- State reset delay: 500ms (for smooth UX)
- Total error flow: ~3.5 seconds

**Memory**:
- No memory leaks on repeated login attempts
- Proper cleanup of resources on logout
- No accumulation of BLoC listeners

---

## Conclusion

This testing guide ensures that the login error handling fix works correctly across all scenarios. The key improvement is that users no longer experience infinite loading states when entering incorrect credentials - they can immediately see the error and retry.
