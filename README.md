# Photography Toolbox

A companion app for analog photography, built with Flutter. Works on Android, iOS, Windows, macOS, Linux, and Web.

## Features

### Flash Calculator
Calculate flash power or subject distance using guide number, ISO, and aperture. Supports standard flash power steps (1/1 to 1/64) and common f-stop values. Sliders snap to standard stops for quick adjustments.

### Depth of Field Calculator
Compute near focus, far focus, depth of field, and hyperfocal distance from focal length, aperture, subject distance, and circle of confusion. Uses standard photographic formulas.

### Film Quick Note
Log your film rolls and individual shots. Each roll stores brand, model, ISO, comments, and a list of shots. Shots can include a sequence number, photo (from camera or gallery), and notes. Data is saved locally as JSON.

### Lightpad
Turn your screen into a light source with adjustable color, brightness, and transparency. Includes a fullscreen mode — long-press for 2 seconds to exit. Color picker supports hex input and HSV sliders.

### Darkroom Clock
_Coming soon._

### Settings
Configure the maximum aperture stop available across calculators (e.g., f/0.95, f/1.0, f/1.4). The selected value is persisted and shared by Flash Calculator and Depth of Field Calculator.

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.3 or later)

### Run
```bash
flutter pub get
flutter run
```

### Build
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Windows
flutter build windows
```

## Project Structure

```
lib/
  main.dart                       # App entry point and route definitions
  pages/
    home_page.dart                # Home screen with feature grid
    flash_calculator_page.dart    # Flash calculator
    dof_calculator_page.dart      # Depth of field calculator
    film_quick_note_page.dart     # Film roll list
    roll_detail_page.dart         # Single roll view with shots
    shot_page.dart                # Add/edit a shot
    lightpad_page.dart            # Lightpad with color picker
    darkroom_clock_page.dart      # Darkroom clock (placeholder)
    settings_page.dart            # App settings
  services/
    aperture_settings.dart        # Shared aperture stop configuration
    film_storage.dart             # JSON-based local storage for film rolls
  widgets/
    app_drawer.dart               # Navigation drawer for feature pages
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Author

[@f1shcake_onegai](https://github.com/F1shcake-onegai)
