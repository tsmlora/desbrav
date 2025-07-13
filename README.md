# Flutter

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. **CONFIGURAÇÃO OBRIGATÓRIA DO SUPABASE**:

   Antes de executar o app, você DEVE configurar as credenciais do Supabase:

   a. Copie o arquivo `env.json` e substitua os valores:
   ```json
   {
     "SUPABASE_URL": "https://seu-projeto.supabase.co",
     "SUPABASE_ANON_KEY": "sua-chave-publica-anonima"
   }
   ```

   b. Para obter essas credenciais:
   - Acesse [supabase.com](https://supabase.com)
   - Entre no seu projeto
   - Vá em Settings > API
   - Copie a URL e a chave `anon/public`

3. Run the application:

To run the app with environment variables defined in an env.json file, follow the steps mentioned below:

**IMPORTANTE: SEMPRE execute com o arquivo env.json:**

1. Through CLI
    ```bash
    flutter run --dart-define-from-file=env.json
    ```
2. For VSCode
    - Open .vscode/launch.json (create it if it doesn't exist).
    - Add or modify your launch configuration to include --dart-define-from-file:
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch",
                "request": "launch",
                "type": "dart",
                "program": "lib/main.dart",
                "args": [
                    "--dart-define-from-file",
                    "env.json"
                ]
            }
        ]
    }
    ```
3. For IntelliJ / Android Studio
    - Go to Run > Edit Configurations.
    - Select your Flutter configuration or create a new one.
    - Add the following to the "Additional arguments" field:
    ```bash
    --dart-define-from-file=env.json
    ```

## 🚀 Deployment / Build

**CRÍTICO: Para builds de produção, SEMPRE inclua as variáveis de ambiente:**

```bash
# Para Android APK
flutter build apk --release --dart-define-from-file=env.json

# Para Android App Bundle
flutter build appbundle --release --dart-define-from-file=env.json

# Para iOS
flutter build ios --release --dart-define-from-file=env.json

# Para Web
flutter build web --dart-define-from-file=env.json
```

## 🔧 Troubleshooting Supabase

Se aparecer erro "Supabase não está configurado corretamente":

1. **Verifique se o env.json existe e tem as credenciais corretas**
2. **Sempre execute com --dart-define-from-file=env.json**
3. **Para deployment, configure as variáveis no CI/CD:**
   ```bash
   export SUPABASE_URL="https://seu-projeto.supabase.co"
   export SUPABASE_ANON_KEY="sua-chave-anonima"
   flutter build apk --release
   ```

4. **Para Rocket.new ou outros serviços de deploy:**
   - Configure as variáveis de ambiente no painel de controle
   - Ou use build commands que incluem as variáveis

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── env.json            # 🔧 Environment variables (REQUIRED!)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```

## 📦 Deployment

Build the application for production:

```bash
# For Android (WITH environment variables)
flutter build apk --release --dart-define-from-file=env.json

# For iOS (WITH environment variables)
flutter build ios --release --dart-define-from-file=env.json
```

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new