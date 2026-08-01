# Flutter Architecture Specification — DEN Onboarding Module

This document outlines the Flutter project architecture for the **DEN** mobile onboarding flow across **iOS** and **Android**.

---

## 1. Hard UI/Theme Design Constraints

> [!IMPORTANT]
> **Hard Design Constraint — Editorial Minimalist Aesthetic**:
> No boxed, enclosed, or heavily-outlined input containers are allowed anywhere in the onboarding UI. All text input fields, selection drop-downs, and prompt controls MUST be clean, borderless, or utilize minimal bottom underline styling only. This ensures a sleek, high-end editorial aesthetic across iOS and Android views.

---

## 2. State Management Evaluation & Recommendation

### Recommendation: **flutter_riverpod** (v2.x with Notifier API)
- **Wizard Step Isolation**: Temporary UI state in onboarding steps auto-disposes upon completion.
- **Async State Handling**: `Notifier` and `AsyncNotifier` provide clean loading, error, and data states for API requests.
- **Testability**: Decoupled state without `BuildContext` requirements.

---

## 3. Directory & Folder Structure

```
den/
├── android/                   # Android native project (coreLibraryDesugaring enabled)
├── ios/                       # iOS native project
├── docs/                      # Specification & Mapping documents
├── lib/
│   ├── main.dart              # App entrypoint & ProviderScope
│   └── src/
│       ├── app.dart           # MaterialApp.router bound to routerProvider
│       ├── core/
│       │   ├── theme/         # DEN design system tokens & colors (#3F2537)
│       │   ├── widgets/       # MobileDeviceShell, DenButtons, UnderlineField
│       │   └── utils/         # E.164 phone formatting & age helpers
│       ├── features/
│       │   ├── auth/          # Phone entry (10-digit validation) & 6-digit OTP verification
│       │   ├── guardrail/     # Ground rules & consent
│       │   ├── onboarding/    # Profile setup funnel (Steps 1-8)
│       │   └── profile/       # ProfilePageScreen (Post-onboarding home target)
```

---

## 4. Navigation Strategy (`go_router` + Riverpod Integration)

To handle dynamic authentication state redirects cleanly without scoping errors, the `GoRouter` instance is declared inside a Riverpod `Provider` and refreshed via a `Listenable` linked to `authStateProvider`.

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<AuthState>(ref.read(authStateProvider));
  
  ref.listen<AuthState>(authStateProvider, (_, next) {
    authListenable.value = next;
  });

  ref.onDispose(authListenable.dispose);

  return GoRouter(
    initialLocation: '/auth/phone',
    refreshListenable: authListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final auth = authListenable.value;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!auth.isAuthenticated) {
        return isAuthRoute ? null : '/auth/phone';
      }
      if (!auth.isOnboardingComplete) {
        return state.matchedLocation == '/onboarding' ? null : '/onboarding';
      }
      return '/home';
    },
    routes: [
      GoRoute(path: '/auth/phone', builder: (c, s) => const PhoneEntryScreen()),
      GoRoute(path: '/auth/otp', builder: (c, s) => const OtpVerificationScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingFlowScreen()),
      GoRoute(path: '/home', builder: (c, s) => const ProfilePageScreen()),
    ],
  );
});
```

---

## 5. Native Build & Hardware Configurations

### A. Android Build Configuration (`android/app/build.gradle.kts`)
- **Java Core Library Desugaring**: Required for AWS Amplify & Rekognition Face Liveness SDK compatibility:
  ```kotlin
  android {
      compileOptions {
          isCoreLibraryDesugaringEnabled = true
          sourceCompatibility = JavaVersion.VERSION_17
          targetCompatibility = JavaVersion.VERSION_17
      }
  }

  dependencies {
      coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
  }
  ```

### B. Photo Selection & Upload
- **Package**: `image_picker: ^1.1.2`
- **Behavior**: Pick photos from gallery/camera. Supports **1 Main Profile Photo + up to 9 Secondary Grid Photos** (maximum 10 total photos, minimum 2 required). Renders a Featured Main Avatar card and an expanding 2x2 grid in DEN brand theme (`#3F2537`). Provides local image path preview fallback when backend API is offline during local testing.

### C. AWS Rekognition Face Liveness SDK (Step 8)
- **Integration**: Bridges client capture session with AWS Rekognition Face Liveness. Step 8 offers "VERIFY NOW" and "SKIP FOR NOW", both auto-navigating upon completion to `ProfilePageScreen` (`/home`).

### D. Location & Maps
- **Packages**: `geolocator: ^13.0.4`, `geocoding: ^3.0.0`, `flutter_map: ^8.1.1`
- **Behavior**: Embeds OpenStreetMap preview centered at Delhi (`28.7041`, `77.1025`) by default, reverse geocodes city name on GPS permission, and positions resolved `CITY: <Name>` text below the location button.
