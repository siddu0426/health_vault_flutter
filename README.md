# HealthVault Flutter

This is a functional Flutter rebuild of the provided React medical records app.

## Included

- Home dashboard with family switcher, quick actions, emergency card, vitals, medicines, and recent report teaser
- Bottom tab navigation
- Family profiles, selectable form fields, image selection, and validated add-member flow
- Camera, gallery, and PDF selection with upload, extraction, verification, and save states
- Searchable and filterable records with share, download, and record menus
- Filterable health timeline
- Emergency card with callable contacts
- Stateful medication check-offs, refill requests, and add-medication dialog
- Actionable profile and settings screen
- Integrated voice and text assistant with speech recognition, spoken replies, and app navigation

## Voice assistant

Tap the microphone in the header to open the assistant. It can answer common app questions and navigate to records, medications, uploads, family profiles, the timeline, and emergency information. The current response engine is local and deliberately non-diagnostic. A production AI model should be connected through an authenticated backend; never embed provider keys or send private medical data directly from the mobile client.

## Run

Install Flutter, then from this folder run:

```bash
flutter pub get
flutter run
```

Platform folders and mobile microphone, speech, camera, photo-library, and dialing permissions are included. The main interface is in `lib/main.dart`; voice chat is isolated in `lib/voice_assistant.dart` for straightforward backend integration.
