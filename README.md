# The Curator

The Curator is a cross-platform mobile blog application for reading and writing posts. It is built using Flutter and connects to a backend API to manage user authentication and content.

---

## Download Android APK

You can test the application directly on an Android device or emulator without building the source code.

[Download the Latest Release APK](../../releases/latest)

Note: To install the file, you must enable "Install from Unknown Sources" in your Android device security settings.

---

## Features

* **Profile Management:** Users can update their display name and bio. The Save and Cancel buttons dynamically enable or disable based on whether the text has changed.
* **Secure Token Storage:** User authentication tokens are saved locally using the `flutter_secure_storage` package.
* **OTP Email Verification:** Secure registration flow that verifies users via a one-time password sent to their email.
* **Custom UI Components:** Clean layout using custom app bars and responsive text fields.

---

## Tech Stack & Architecture

The project uses a client-server architecture split into two core layers:

### Mobile Frontend
* **Framework:** Flutter & Dart - Used to compile the mobile app for both iOS and Android from a single codebase.
* **State Management:** Provider - Manages user authentication states and profile data across different screens.
* **Navigation:** GoRouter - Handles declarative routing and screen transitions.
* **Networking:** Dio - HTTP client configured with interceptors to automatically attach authentication headers and handle server response status codes.

### Backend API
* **Runtime Environment:** Node.js - Powers the backend services and handles network business logic.
* **Routing Framework:** Express - Manages backend endpoint pathways like `/authenticate`, `/register`, `/verify-otp`, `/getinfo`, and `/update-profile`.

---

## Getting Started

### Prerequisites
* Flutter SDK >= 3.19.0
* Dart SDK

### Installation and Setup

1. Clone the repository and navigate into the project folder:
   ```bash
   git clone [https://github.com/yourusername/service_management_app.git](https://github.com/yourusername/service_management_app.git)
   cd service_management_app

   Get the required project dependencies:

   Bash
   flutter pub get
   Run the application on a connected device or emulator:

   Bash
   flutter run

   Set up and start the Node.js backend server:

2.  Navigate to your backend directory (replace with your actual backend folder name if different)
```bash
    cd backend
    npm install
    npm start
    Get the frontend mobile dependencies and run the app:

3.  Open a new terminal window and navigate back to the root project folder
```bash
    flutter pub get
    flutter run