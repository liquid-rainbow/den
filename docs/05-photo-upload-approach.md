# Photo Upload Approach Specification — S3 & Presigned URLs

This document outlines the secure, scalable photo upload architecture for **DEN** onboarding Step 7 (and post-onboarding profile image editing).

---

## 1. Overview & Presigned Upload Architecture

To ensure high performance and security, the mobile app **NEVER** embeds long-lived AWS IAM credentials nor routes large binary image streams through our primary API server. Instead, it utilizes **S3 Presigned PUT URLs**.

```
┌─────────────────┐             ┌──────────────────┐             ┌────────────────┐             ┌───────────────────┐
│  Flutter Client │             │   Dart Backend   │             │   Amazon S3    │             │  CloudFront CDN   │
└─────────────────┘             └──────────────────┘             └────────────────┘             └───────────────────┘
         │                               │                               │                                │
         │  1. POST /api/uploads/        │                               │                                │
         │     photo-url                 │                               │                                │
         │ ────────────────────────────► │                               │                                │
         │                               │ 2. Generate Presigned         │                                │
         │                               │    S3 PUT URL (5m expiry)    │                                │
         │                               │    Key: users/{id}/{uuid}.jpg │                                │
         │  3. Return uploadUrl,         │                               │                                │
         │     objectKey & publicUrl     │                               │                                │
         │ ◄──────────────────────────── │                               │                                │
         │                                                               │                                │
         │  4. HTTP PUT image bytes directly to uploadUrl                │                                │
         │ ─────────────────────────────────────────────────────────────►│                                │
         │                                                               │                                │
         │  5. Store publicUrl in photos array for onboarding            │                                │
         │                                                                                                │
         │  6. Display image in UI via CloudFront CDN publicUrl                                           │
         │ ──────────────────────────────────────────────────────────────────────────────────────────────►│
```

---

## 2. API Endpoint Specification

### Endpoint: `POST /api/uploads/photo-url`

Obtains a short-lived presigned S3 PUT URL for direct photo uploads.

- **HTTP Method**: `POST`
- **Endpoint**: `/api/uploads/photo-url`
- **Auth Required**: Yes (`Bearer <sessionToken>` or `rf_session` cookie)

#### Request Body
```json
{
  "contentType": "image/jpeg"
}
```

#### Client & Server Validation
- `contentType`: Must be one of `image/jpeg`, `image/png`, or `image/webp`.
- `maxFileSize`: Max $8\text{ MB}$ per photo file.
- `objectKey Scoping`: Object keys are isolated to the authenticated user ID: `users/{userId}/photos/{uuid}.{ext}`.

#### Response 200 OK
```json
{
  "success": true,
  "uploadUrl": "https://den-media-bucket.s3.ap-south-1.amazonaws.com/users/usr_123/photos/a1b2c3d4.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&...",
  "objectKey": "users/usr_123/photos/a1b2c3d4.jpg",
  "publicUrl": "https://cdn.denapp.com/users/usr_123/photos/a1b2c3d4.jpg"
}
```

---

## 3. Step 7 UI Architecture & Validation Rules

### A. UI Layout (HTML-Aligned Design)
1. **Primary Profile Photo Avatar**:
   - Featured circular avatar container (`140px x 140px`) with ambient glow (`#3F2537` shadow) on top.
   - Shows `MAIN PHOTO` label and `add_a_photo` icon when empty.
   - Circular (+) or delete badge button attached to the bottom-right of the avatar.
   - Label below: **Profile Photo**.

2. **Secondary Photo Grid ("Add Photos")**:
   - Section header **Add Photos**.
   - Info callout badge with `info_outline` icon: *"Add at least one photo to continue"*.
   - 2x2 grid of secondary photo cards with `add_circle_outline` icons, light brand tint background (`Color(0xFF3F2537).withValues(alpha: 0.05)`), and rounded borders.
   - Dynamic expansion: Starts at 4 slots (2x2) and dynamically expands up to 9 secondary slots as photos are uploaded!

### B. Validation Rules
- **Main Profile Photo**: Mandatory (`photos.isNotEmpty`).
- **Secondary Grid Photo**: Mandatory at least 1 photo (`photos.length >= 2`).
- **Minimum Required to Proceed**: **2 photos** (1 Main Profile Photo + at least 1 Secondary Grid Photo).
- **Maximum Capacity**: Up to **10 photos total** (1 Main Profile Photo + 9 Secondary Grid Photos).

### C. Local Testing Fallback
- During local UI development/testing when the backend presigned URL server is offline, `uploadPhoto()` catches connection errors and gracefully falls back to the picked image's local path (`image.path`).
- Image rendering helper `_buildPhotoImage` dynamically handles both network/blob URLs (`Image.network`) and local device files (`Image.file`), allowing full UI testing without server dependencies.
