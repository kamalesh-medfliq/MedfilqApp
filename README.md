# MedFliq Frontend 🏥

MedFliq is a modern, multi-tenant enterprise healthcare platform. This repository contains the Flutter frontend application, designed for seamless user experience across mobile and web platforms. It supports various roles including Doctors, Nurses, Receptionists, and Clinic Administrators.

## 🚀 Getting Started

This project is a starting point for the MedFliq Flutter application.

### Prerequisites

Ensure you have the following installed on your local machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development - macOS only)
- [Git](https://git-scm.com/)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/kamalesh-medfliq/MedfilqApp.git
   cd MedfilqApp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## 🏗️ Architecture & Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: *To be decided (e.g., Riverpod, Bloc, Provider)*
- **Backend**: NestJS, PostgreSQL, Prisma ORM (Running in a separate repository)

## 🔐 Environment Setup

*Note: Never commit your `.env` file to version control.*

1. Create a `.env` file in the root directory.
2. Add your required API keys and configuration (e.g., backend API URL, Firebase config).

```env
API_BASE_URL=http://localhost:3000
```

## 🤝 Contributing

When contributing to this repository, please ensure you follow the standard Git workflow:
1. Create a feature branch (`git checkout -b feature/your-feature`)
2. Commit your changes (`git commit -m 'feat: add some feature'`)
3. Push to the branch (`git push origin feature/your-feature`)
4. Open a Pull Request

---
*Built with ❤️ for better healthcare management.*
