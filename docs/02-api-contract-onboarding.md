# API Contract — Onboarding & Auth Endpoints

This document specifies the exact request/response data shapes for onboarding and auth endpoints.

---

## Base URL & Headers

- **Base URL**: `http://localhost:5000` (Dev) / Configurable via Environment Variable
- **Default Headers**:
  - `Content-Type: application/json`
  - `Accept: application/json`
  - `Authorization: Bearer <sessionToken>` (For protected endpoints)
  - Cookies: `rf_session=<token>` (Session cookie set by backend)

---

## 1. Send OTP

Initiates a 6-digit SMS verification code challenge for a phone number.

- **HTTP Method**: `POST`
- **Endpoint**: `/api/auth/send-otp`
- **Auth Required**: No

### Request Body
```json
{
  "phoneNumber": "+919876543210"
}
```
*Validation*: `phoneNumber` must be E.164 format. For India (`+91`), input is restricted to exactly 10 digits (`^\+91\d{10}$`).

### Response 200 OK
```json
{
  "success": true,
  "message": "Verification code sent if the phone number can receive messages."
}
```

---

## 2. Verify OTP

Verifies the 6-digit OTP code and creates or retrieves the user session.

- **HTTP Method**: `POST`
- **Endpoint**: `/api/auth/verify-otp`
- **Auth Required**: No

### Request Body
```json
{
  "phoneNumber": "+919876543210",
  "code": "123456"
}
```
*Validation*: `code` must be exactly 6 digits (`^\d{6}$`).

### Response 200 OK
Sets `rf_session` HTTP cookie.
```json
{
  "success": true,
  "message": "Authenticated successfully.",
  "sessionToken": "4e7c3a9f8b2d1e0a5c4b3a2f1e0d9c8b7a6f5e4d3c2b1a0f9e8d7c6b5a4f3e2d",
  "user": {
    "id": "usr_9876543210",
    "phoneNumber": "+919876543210",
    "fullName": "New RedFlag Member",
    "dob": "2000-01-01",
    "gender": "Unspecified",
    "heightCm": 170,
    "location": "",
    "photos": [],
    "instagramUsername": "",
    "status": "pending_verification",
    "isVerified": false,
    "createdAt": "2026-07-30T10:00:00.000Z"
  }
}
```

---

## 3. Create Face Liveness Session

Obtains a temporary AWS Rekognition Face Liveness `sessionId` prior to starting client capture UX.

- **HTTP Method**: `POST`
- **Endpoint**: `/api/onboarding/face-liveness/session`
- **Auth Required**: Yes (`Bearer <sessionToken>` or `rf_session` cookie)

### Request Body
None (`{}` or empty).

### Response 200 OK
```json
{
  "success": true,
  "sessionId": "aws_rekognition_liveness_session_123"
}
```

---

## 4. Verify Face (Biometric Liveness Check)

Marks the authenticated user's profile as identity verified after successful Rekognition Face Liveness and face comparison.

- **HTTP Method**: `POST`
- **Endpoint**: `/api/onboarding/verify-face`
- **Auth Required**: Yes (`Bearer <sessionToken>` or `rf_session` cookie)

### Request Body
```json
{
  "sessionId": "aws_rekognition_liveness_session_123"
}
```

### Response 200 OK
```json
{
  "success": true,
  "verified": true,
  "badge": "Identity Verified",
  "message": "Biometric liveness check passed. Your profile is now marked as Identity Verified."
}
```

---

## 5. Complete User Onboarding

Saves the complete user profile attributes and activates the account.

- **HTTP Method**: `POST`
- **Endpoint**: `/api/users/onboarding`
- **Auth Required**: Yes (`Bearer <sessionToken>` or `rf_session` cookie)

### Request Body
```json
{
  "phoneNumber": "+919876543210",
  "fullName": "Raghav Sharma",
  "dob": "2001-04-06",
  "gender": "Female",
  "heightCm": 170,
  "location": "Jaipur",
  "photos": [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80"
  ],
  "instagramUsername": "raghav_rf"
}
```

#### Validation Rules (Zod Schema)
- `phoneNumber`: Must match authenticated user's phone number.
- `fullName`: 1–120 characters string.
- `dob`: ISO date string (`YYYY-MM-DD`). Must calculate to age $\ge 18$.
- `gender`: Enum (`female`, `male`, `non-binary`, `Female`, `Male`, `Non-Binary`).
- `heightCm`: Integer between $120$ and $230$.
- `location`: 1–120 characters string.
- `photos`: Array of **2 to 10 image URLs** (1 Main Profile Photo + at least 1 Secondary Grid Photo; minimum 2 photos required).
- `instagramUsername`: Regex `/^[A-Za-z0-9._]{1,30}$/`.

### Response 201 Created
```json
{
  "success": true,
  "message": "Profile setup complete.",
  "user": {
    "id": "usr_9876543210",
    "phoneNumber": "+919876543210",
    "fullName": "Raghav Sharma",
    "dob": "2001-04-06",
    "gender": "female",
    "heightCm": 170,
    "location": "Jaipur",
    "photos": [
      "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80",
      "https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80"
    ],
    "instagramUsername": "raghav_rf",
    "status": "active",
    "isVerified": false,
    "createdAt": "2026-07-30T10:00:00.000Z"
  }
}
```
