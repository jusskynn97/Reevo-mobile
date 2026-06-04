# Token Auto-Refresh Testing Guide

## 📋 Changes Made

Fixed token auto-refresh issue by:
1. **Anti-Loop Protection**: Track refreshed requests to prevent infinite retry loops
2. **Header Cleanup**: Remove old Authorization header before retry so new token is set
3. **Enhanced Logging**: Detailed logs to track every step of token refresh

## 🧪 Testing Steps

### Step 1: Monitor Logcat
```bash
flutter logs
# Filter for print statements:
# - "Refreshing token..."
# - "Token refreshed successfully"
# - "Retrying request..."
# - "Refresh token request failed..."
```

### Step 2: Set Short Token Expiry (Backend)
- Configure access token to expire in 1-2 minutes for testing
- Keep refresh token validity longer (e.g., 7 days)

### Step 3: Test Scenario

**Test 1: Normal Token Refresh**
1. Login successfully
2. Wait for access token to expire
3. Make an API call (e.g., fetch video feed)
4. ✅ Expected: 
   - Log: "Refreshing token..."
   - Log: "Token refreshed successfully"
   - Log: "Retrying request..."
   - API call completes successfully

**Test 2: Refresh Token Expired**
1. Wait for both tokens to expire
2. Make an API call
3. ✅ Expected:
   - Log: "Refreshing token..."
   - Log: "Refresh token request failed: Status: 401" or similar
   - User logged out automatically

## 🔍 Debugging Output

### Successful Refresh Flow:
```
I/flutter: Refreshing token...
I/flutter: Token refreshed successfully
I/flutter: Retrying request: /api/videos/feed
I/flutter: Retry request succeeded
```

### Failed Refresh (Refresh Token Expired):
```
I/flutter: Refreshing token...
I/flutter: Refresh token request failed:
I/flutter:   Status: 401
I/flutter:   Error: 401
I/flutter:   Response data: {message: 'Invalid refresh token', ...}
```

### Anti-Loop Protection Triggered:
```
I/flutter: Refreshing token...
I/flutter: Token refreshed successfully
I/flutter: Retrying request: /api/videos/feed
I/flutter: Retry request failed: ...
I/flutter: Request already refreshed, skip: GET:/api/videos/feed
```

## 🎯 Key Points to Verify

1. **Refresh endpoint works**: `/api/auth/refresh` accepts `{"refreshToken": "..."}`
2. **Response format**: Returns `{"success": true, "data": {accessToken, refreshToken, userId}}`
3. **Tokens are saved**: New tokens stored in SharedPreferences before retry
4. **onRequest interceptor runs**: Authorization header set with new token

## ⚠️ Common Issues

### Issue 1: "Refresh token request failed: Status: 401"
- ✓ Refresh token expired → User needs to login again
- ✓ Backend validation issue → Check refresh token is sent as `{"refreshToken": "..."}`

### Issue 2: No logs appearing
- Check if access token actually expired
- Verify authDio is using correct baseUrl: `http://10.0.2.2:8080`
- Check network connectivity

### Issue 3: User logged out without retry
- Token refresh request failed (see Issue 1)
- Check Android emulator network settings

## 💡 Next Steps After Testing

1. ✅ Verify logs show correct token refresh flow
2. ✅ Check that refresh token request is sent correctly
3. ✅ Confirm new token is used for retry request
4. 📌 If still failing, share the error logs from Logcat

