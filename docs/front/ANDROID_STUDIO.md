# Android Studio — run the Flutter app

## Error: "Entrypoint isn't within the current project"

This almost always means Android Studio opened the **wrong folder**.

The Flutter project root must be **`front/`** (the folder that contains `pubspec.yaml`), **not** the repo root `regicide/`.

```
regicide/          ← NOT a Flutter project (no pubspec here)
  back/
  docs/
  front/           ← OPEN THIS in Android Studio
    pubspec.yaml
    lib/main.dart
```

## Your layout looks correct

If the Project pane root is **`front`** and you see `pubspec.yaml` + `lib/main.dart`, the folder is right.

Common causes when it still fails:

1. **Running the wrong file** — You have `home_page.dart` open. Android Studio may try to run the **current tab**, not `main.dart`.
   - Fix: In the project tree, **right-click `lib/main.dart`** → **Run 'main.dart'**
   - Or use the run-configuration dropdown (top toolbar) and pick **`main.dart`**, not a generic Dart config.

2. **Missing `front.iml`** — Regenerate IDE files:
   ```powershell
   cd front
   flutter pub get
   flutter create .
   ```
   Then **File → Invalidate Caches → Restart**.

3. **Stale parent path** — If you recently opened `regicide` then `front`, restart Android Studio after opening only `front`.

## Fix (recommended)

1. **File → Close Project**
2. **Open** → select:
   `C:\Users\leoG\Documents\repos\regicide\front`
3. Wait for **Pub get** to finish (banner or `flutter pub get` in terminal).
4. Confirm the run configuration targets **`lib/main.dart`**:
   - Run → Edit Configurations → Flutter → Dart entrypoint: `lib/main.dart`
5. Choose a device:
   - **Chrome** (matches web MVP), or **Windows**, or an Android emulator
6. Click **Run**

## If you need the whole monorepo in one IDE

- **Cursor / VS Code:** open `regicide` and use the terminal:
  ```powershell
  cd front
  flutter run -d chrome
  ```
- **Android Studio:** open **`front`** only for Flutter; open `back` in another window or use the terminal for Node.

Do not point the Flutter entrypoint at `front/lib/main.dart` while the project root is `regicide/` — that causes this error.

## Backend for 4A

The app calls `http://localhost:3000`. On **Android emulator**, use `http://10.0.2.2:3000` instead (see below when you test on emulator).

For **Chrome / Windows** desktop run, `localhost:3000` is correct if `npm run dev` is running in `back/`.

## Command line (always works)

```powershell
cd C:\Users\leoG\Documents\repos\regicide\front
flutter pub get
flutter run -d chrome
```
