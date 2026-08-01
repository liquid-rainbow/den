# Code Mapping — React to Flutter (Onboarding Module)

This document maps each React TypeScript component/file to its Flutter equivalent in **DEN**, updated for DEN design decisions.

---

## 1. Direct File Mapping Table

| Existing React TSX Component / File | Planned Flutter File Path | Responsibility & Key Widgets |
| :--- | :--- | :--- |
| `frontend/src/features/auth/Portal.tsx` | `lib/src/features/auth/presentation/screens/phone_entry_screen.dart` & `otp_verification_screen.dart` | Phone E.164 input, country code picker (`+91` 10-digit validation limit), 6-digit OTP input grid, countdown timer. Uses borderless styling and `rf_session` cookie auth. |
| `frontend/src/features/auth/Guardrail.tsx` | `lib/src/features/guardrail/presentation/screens/guardrail_screen.dart` | Ground Rules policy cards, media release & anonymity guidelines checkboxes. |
| `frontend/src/features/onboarding/OnboardingFunnel.tsx` | `lib/src/features/onboarding/presentation/screens/onboarding_flow_screen.dart` | Main wizard container, 8-step visual progress bar. |
| `OnboardingFunnel.tsx` (Step 1: Name) | `.../steps/01_name_step.dart` | Auto-focused underline input with dynamic width. |
| `OnboardingFunnel.tsx` (Step 2: DOB) | `.../steps/02_dob_step.dart` & `_SingleValuePicker` | `_SingleValuePicker` wheels with multi-pointer gesture listening, dark `#3F2537` tint, and 18+ age verification logic. |
| `OnboardingFunnel.tsx` (Step 3: Gender) | `.../steps/03_gender_step.dart` | Borderless choice buttons (`Female`, `Male`, `Non-Binary`) with 1.15x back-ease scale animation & auto-navigation. |
| `OnboardingFunnel.tsx` (Step 4: Height) | `.../steps/04_height_step.dart` | Feet & Inches `_SingleValuePicker` wheel pickers with real-time $cm$ calculation. |
| `OnboardingFunnel.tsx` (Step 5: Location) | `.../steps/05_location_step.dart` & `widgets/location_map_preview.dart` | `flutter_map` OSM tiles + `geolocator` reverse geocoding to resolve city. City text hidden initially, displays on GPS allow or fallback `Delhi`. |
| `OnboardingFunnel.tsx` (Step 6: Instagram) | `.../steps/06_instagram_step.dart` | Underline text input with static `@` prefix. |
| `OnboardingFunnel.tsx` (Step 7: Photos) | `.../steps/07_photos_step.dart` | **HTML-aligned Photo Layout**: Featured Main Profile Photo Avatar on top + "Profile Photo" title + "Add Photos" header + Info callout + 2x2 grid (min 2 photos total, max 10 photos total). |
| `frontend/src/features/onboarding/FaceVerificationStep.tsx` | `.../steps/08_face_verification_step.dart` & `widgets/camera_viewfinder_oval.dart` | **AWS Rekognition Face Liveness + CompareFaces**: Skippable step offering "VERIFY NOW" or "SKIP FOR NOW". On completion or skip, auto-navigates directly to `ProfilePageScreen` (`/home`). |
| `frontend/src/features/profile/ProfilePageScreen.tsx` | `lib/src/features/profile/presentation/screens/profile_page_screen.dart` | Post-onboarding home screen displaying user profile, stats, and posts grid. |

---

## 2. Key UX & Architectural Enhancements

### A. Borderless Editorial Aesthetic
- All text inputs and dropdowns adopt a clean, borderless or minimal bottom-underline style. No enclosed box borders.

### B. Dynamic Photo Layout (Main Avatar + Secondary Grid)
- Main Profile Avatar on top + dynamic 2x2 secondary grid below. Requires 1 Main Profile Photo + at least 1 Grid Photo (minimum 2 photos total, up to 10 photos max).

### C. Optional AWS Rekognition Biometric Verification
- Step 8 is optional and skippable. Integrates Amazon Rekognition Face Liveness SDK on client and server-side `CompareFaces` on Dart backend. Completing or skipping Step 8 auto-navigates to `ProfilePageScreen`.
