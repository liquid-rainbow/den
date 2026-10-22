Local runtime copy of face_liveness_detector 0.2.11, imported from the projects/den checkout.

Source pins Amplify 2.58.0, AWS SDK 1.6.71, Smithy 0.191.0 and Face Liveness 1.4.4, with iOS 15 minimum in Package.swift. Uses a local pub override for native compatibility. See https://github.com/smithy-lang/smithy-swift/issues/1146 (later comments narrow the originally reported Xcode version issue).

Excluded: example apps, fixtures, generated build files, Gradle wrapper tools and Xcode user settings. Flutter host Android build supplies Gradle. Removed initialization/session-ID logs; native error logs use static messages only.

Known source limitation: these pins miss later iOS Face Liveness signing fixes. A build does not prove real face verification works. Verify iOS and Android before enabling real capture; the backend still uses a failure stub. No production biometric sign-off is implied.
