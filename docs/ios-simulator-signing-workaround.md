# iOS simulator exit 255: generated framework metadata

The saved Xcode activity log identified the underlying error:

```
Failed to codesign .../build/ios/Debug-iphonesimulator/Flutter.framework/Flutter
resource fork, Finder information, or similar detritus not allowed
Failed to copy Flutter framework.
Exited with status code 255
```

This failure occurs in the Prepare Flutter Framework pre-action, before application compilation. It is separate from the earlier Swift package lockfile mismatch and from the ECS backend.

The generated Flutter.framework directory had `com.apple.FinderInfo`. After removal it reappeared while the output lived under the iCloud checkout. The binary's normal ad-hoc simulator signature passes after removing the offending directory metadata. Provenance/file-provider attributes were not broadly stripped, and code signing was not disabled.

For the current debugging session, generated output was moved to:

```
/private/tmp/den-ios-build-20261020
```

The project's ignored `build` entry is a symbolic link to that local directory. App source, database files, and ECS were not moved or deployed. Existing downloaded packages were retained rather than deleted/downloaded again.

This is a temporary workaround. macOS may clear temporary files; deleting/recreating `build` or running `flutter clean` may remove the link and restore an iCloud-backed output directory. For a durable setup, use a fresh checkout/consolidated working copy outside iCloud, preserving and reviewing the current uncommitted changes before moving anything. Do not overwrite the existing other DEN checkout, which has its own local changes.

Verification: direct signing and verification of generated Flutter.framework passed. The full arm64 simulator Xcode build succeeded. The resulting app was installed and launched on the already-booted iPhone 15 Pro Max (iOS 17.0); a local screenshot confirmed the login screen rendered. Sign-in, chat and face verification were not exercised. Logs/result bundles are under `/tmp/den-ios-255-review`.

Apple's explanation: https://developer.apple.com/library/archive/qa/qa1940/_index.html .
