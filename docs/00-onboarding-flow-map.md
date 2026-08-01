# Onboarding Flow Map — DEN Project

This document maps out the exact onboarding and pre-onboarding authentication flow for **DEN**.

---

## 1. High-Level Flow Sequence Diagram

```
[ Unauthenticated User ]
          │
          ▼
┌──────────────────┐
│  Phase 1: Portal │ ── (1.1 Enter Phone) ──► POST /api/auth/send-otp (India +91 exact 10 digits)
│    (OTP Auth)    │ ── (1.2 Enter OTP)   ──► POST /api/auth/verify-otp ──► Returns Session Token / Cookie (rf_session)
└──────────────────┘
          │
          ▼
┌─────────────────────┐
│ Phase 2: Guardrail  │ ── Checkboxes: Media Release & Anonymity Guidelines
│   (Ground Rules)    │ ── Enable 'Enter RedFlag' button
└─────────────────────┘
          │
          ▼
┌────────────────────────────────────────────────────────────────────────┐
│                      Phase 3: Onboarding Funnel                        │
│                                                                        │
│ Step 1: Full Name          ──► [Input Text] (Mandatory)                │
│ Step 2: Date of Birth      ──► [Wheel Picker: DD/MM/YYYY] (Must be 18+)│
│ Step 3: Gender Selection   ──► ['Female' | 'Male' | 'Non-Binary']      │
│ Step 4: Height             ──► [Wheel Picker: Feet / Inches]           │
│ Step 5: City Location      ──► [OSM Map Embed + Geolocation API]      │
│ Step 6: Instagram Handle   ──► [@ Input Text]                          │
│ Step 7: Photos Upload      ──► [Main Avatar + Grid: Min 2, Max 10]     │
│ Step 8: Face Verification  ──► (Optional) 'Verify Now' or 'Skip'      │
│                                    │                                   │
│                                    ▼                                   │
│                         Navigates to Profile Screen                    │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Detailed Step-by-Step Flow Specification

### Phase 1: Authentication (`PhoneEntryScreen` & `OtpVerificationScreen`)

#### Screen 1.1 — Phone Number Entry
- **Screen UI**: Dark gradient background (`#3F2537`), DEN branding title, glassmorphism login card. Clean, borderless input fields.
- **Fields Collected**:
  - `countryCode`: Dropdown selector defaulting to `+91` (`+91`, `+1`, `+44`, `+971`, `+61`, `+65`, `+49`, `+33`).
  - `phone`: Telephone text input.
- **Client Validation Rules**:
  - For `+91` (India): Restricted to **exact 10 digits** using `FilteringTextInputFormatter.digitsOnly` and `LengthLimitingTextInputFormatter(10)`.
  - Validation error displayed if input contains non-digit characters or is fewer than 10 digits (`"Please enter a valid 10-digit mobile number."`).
- **API Call Executed**:
  - `POST /api/auth/send-otp`
  - Body: `{ phoneNumber: "+<countryCode><digitsOnly>" }` (E.164 format).
- **Transitions / Triggers**:
  - On success: State transitions to OTP Verification view, 30-second countdown timer starts.

#### Screen 1.2 — OTP Verification
- **Screen UI**: Top header with back button and editable full phone number, 6 distinct OTP box indicators, 30s countdown timer, "Resend OTP" button.
- **Fields Collected**:
  - `otp`: 6-digit verification code string.
- **Client Validation Rules**: `fullCode.length === 6` digits.
- **API Call Executed**:
  - `POST /api/auth/verify-otp`
  - Body: `{ phoneNumber: "<fullE164Phone>", code: "<6digitCode>" }`
- **Transitions / Triggers**: On success: proceeds to Onboarding Funnel.

---

### Phase 2: Ground Rules (`GuardrailScreen`)

#### Screen 2.1 — Network Consent & Guidelines
- **Screen UI**: Dark full-screen view (`#0A0A0C`), title "The RedFlag Ground Rules", policy cards.
- **Fields / Checkboxes Collected**: Media release & strict anonymity consent.
- **Transitions / Triggers**: "Enter RedFlag" -> Navigates to Onboarding Funnel (Step 1).

---

### Phase 3: Onboarding Funnel (`OnboardingFlowScreen`)

Progress Header: Displays "STEP X OF 8" with an 8-segment visual progress indicator bar. Steps 1 through 7 are mandatory profile collection steps. Step 8 (Face Verification) is explicitly **optional** and auto-navigates upon completion or skip directly to the completed Profile Screen.

#### Funnel Step 1 — Full Name (Mandatory)
- **UI Element**: Borderless single underline text input.
- **Fields Collected**: `fullName` (string).
- **Client Validation**: Non-empty trim string.

#### Funnel Step 2 — Date of Birth (Mandatory)
- **UI Element**: Custom `_SingleValuePicker` using `ListWheelScrollView` with multi-pointer gesture listening (`PointerScrollEvent` for mouse wheel, `onVerticalDragUpdate` for touch/drag).
- **Theme & Layout**: Darker `#3F2537` theme tint (`18%` opacity) with active center digit bold (`fontSize: 22`) and clean faded upper/lower digits (`fontSize: 15`, opacity `0.35`).
- **Fields Collected**: `day`, `month`, `year` -> Formats `dob` (`YYYY-MM-DD`).
- **Client Validation**: Age $\ge 18$ required.

#### Funnel Step 3 — Gender (Mandatory)
- **UI Element**: Centered vertical stack of borderless text buttons (`Female`, `Male`, `Non-Binary`).
- **Selection Interaction**: Tapping an option highlights it with 1.15x back-ease scale animation, `#3F2537` light background tint, 0.5s delay, and auto-navigates to Step 4. Bottom continue button hidden.
- **Fields Collected**: `gender` (`'Female' | 'Male' | 'Non-Binary'`).

#### Funnel Step 4 — Height (Mandatory)
- **UI Element**: Dual `_SingleValuePicker` wheel pickers for Feet (`4'-7'`) and Inches (`0"-11"`).
- **Fields Collected**: `feet`, `inches` -> Real-time $cm$ calculation (`heightCm`).

#### Funnel Step 5 — City Location (Mandatory)
- **UI Element**: OpenStreetMap preview + "Current Location" action button using real device GPS via `geolocator` & reverse geocoding via `geocoding` (`Placemark.locality`).
- **Display Behavior**:
  - Initial state: `location = ''` (no city text displayed before user action/permission).
  - On GPS allow: displays detected city (e.g. `CITY: Jaipur`).
  - On GPS deny/failure: fallback city `Delhi` pops up after 3s delay (`CITY: Delhi`).
  - Display text `CITY: <Name>` is positioned 28px below the "Current Location" button.
- **Fields Collected**: `location` (string city name), `lat` (latitude), `lng` (longitude).

#### Funnel Step 6 — Instagram Username (Mandatory)
- **UI Element**: Underline text input with static `@` prefix.
- **Fields Collected**: `instagramUsername` (string).

#### Funnel Step 7 — Photos Upload (Mandatory)
- **UI Element**: HTML-aligned design featuring a **Featured Main Profile Photo Avatar** (`140px x 140px` circular card with badge button) on top + "Profile Photo" title + "Add Photos" header + Info callout badge + 2x2 Secondary Photo Grid.
- **Capacity**: Minimum 4 grid slots displayed initially; grid expands dynamically up to **9 secondary photos** as photos are uploaded (total maximum 10 photos: 1 Main Profile Photo + 9 Secondary Grid Photos).
- **Client Validation**:
  - Main Profile Photo is mandatory (`photos.isNotEmpty`).
  - At least 1 Secondary Photo in the grid is mandatory (`photos.length >= 2`).
  - Minimum **2 photos total required** to proceed.

#### Funnel Step 8 — Face Verification (Optional & Final Step)
- **UI Element**: Biometric face prompt card offering two clear actions:
  1. **"VERIFY NOW"**: Executes AWS Rekognition Face Liveness SDK workflow -> Marks identity verified -> Completes onboarding.
  2. **"SKIP FOR NOW"**: Bypasses verification immediately -> Completes onboarding.
- **Transitions / Triggers**: On either "VERIFY NOW" or "SKIP FOR NOW", onboarding is completed (`updateAuth(isAuthenticated: true, isOnboardingComplete: true)`) and the user is navigated directly to their **Profile Screen** (`ProfilePageScreen` / `/home`).
