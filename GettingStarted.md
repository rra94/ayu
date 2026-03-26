# Getting Started

## Prerequisites
- Flutter 3.27.1+
- Xcode 15+ with iOS 17 SDK
- CocoaPods (`gem install cocoapods`)

## Steps to run App

1. Clone the repository

```bash
git clone https://github.com/rra94/ayu.git
cd ayu
```

2. Get dependencies

```bash
flutter pub get
```

3. Install iOS pods

```bash
cd ios && pod install && cd ..
```

4. Run build runner to generate ObjectBox + JSON files

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. Run on iPhone / Simulator

```bash
flutter run
```

> **Note:** Ayu is iOS-only. Android, Web, and macOS are not supported.
