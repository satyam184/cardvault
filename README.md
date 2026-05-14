# CardVault

A premium business card scanner built with Flutter, featuring on-device OCR and AI-powered parsing.

## Features
- **Dual-Side Scanning**: Capture both front and back of business cards.
- **On-Device OCR**: Fast, private text recognition using Google ML Kit.
- **AI Extraction**: Instant JSON parsing via Groq (Llama 3.3 70B).
- **Organization**: Categorize cards into custom folders.
- **Excel Export**: Download your contact collections as professional Excel files.

## Tech Stack
- **Flutter**: Cross-platform mobile framework.
- **BLoC**: State management.
- **Groq SDK**: High-speed AI inference.
- **ML Kit**: Google's machine learning SDK for mobile.
- **Excel**: Professional document generation.

## Documentation
- [Backend Specification](BACKEND_SPECIFICATION.md): Detailed guide for building the Supabase infrastructure.

## Getting Started
1. Run `flutter pub get`.
2. Create a `.env` file in the root and add `GROQ_API_KEY=your_key_here`.
3. Run the app using `flutter run`.
