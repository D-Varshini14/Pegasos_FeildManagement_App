# Pegasos Field Management App

A comprehensive mobile and web application designed for field executives and managers to streamline daily operations, track visits, manage leads, and monitor team performance.

## 🌟 Key Features

- **Role-Based Access**: Dedicated panels for Admins and Executives.
- **Dynamic Dashboard**: Real-time metrics and charts for monthly visits, targets, and feedback.
- **Task & Visit Management**: Check-in with GPS tracking, create/update visits, and view client history.
- **Lead Management**: Complete 6-stage pipeline (New, Contacted, Qualified, Proposal, Won, Lost) with classifications.
- **Dark/Light Mode**: Full theme customization available across the app.
- **Notifications & Reminders**: Email notifications for password resets and visit updates.
- **Offline & Cache**: Saves login credentials and preferences securely on the device.

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart) - supports Android, iOS, and Web.
- **Backend**: Node.js + Express.js.
- **Database**: MySQL.
- **State Management**: Provider.
- **Authentication**: JWT & OTP-based password resets.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- [Node.js](https://nodejs.org/) (v16 or higher)
- [MySQL](https://www.mysql.com/) Server (v8 or higher)

## 🚀 Setup Instructions

### 1. Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd field_management_backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Setup the database:
   - Create a MySQL database (e.g. `pegasos_db`).
   - Import the database schema (if provided).
4. Configure environment variables:
   - The `.env` file is intentionally ignored by git for security.
   - Create a new `.env` file in the `field_management_backend` folder using the following template:
     ```env
     PORT=3000
     DB_HOST=localhost
     DB_USER=your_db_user
     DB_PASSWORD=your_db_password
     DB_NAME=pegasos_db
     JWT_SECRET=your_super_secret_jwt_key
     EMAIL_HOST=smtp.gmail.com
     EMAIL_PORT=587
     EMAIL_SECURE=false
     EMAIL_USER=your_email@gmail.com
     EMAIL_PASS=your_app_password
     EMAIL_FROM="Pegasos Field App <your_email@gmail.com>"
     ```
   *(Note: If using Gmail, you must generate an **App Password**; your regular password will not work).*
5. Start the server:
   ```bash
   node server.js
   ```

### 2. Frontend Setup

1. Navigate to the root of the flutter project:
   ```bash
   cd ..
   ```
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
   *(To run on a specific device, use `flutter run -d chrome` or select your mobile emulator).*

## 🔒 Git & Security Guidelines

- **`.gitignore`**: The repository is pre-configured with `.gitignore` files in both the root and the backend directories. This ensures that sensitive files like `.env`, database dumps, and heavy directories like `node_modules/` or `build/` are never accidentally committed.
- **Never push secrets**: Never commit your `EMAIL_PASS`, `JWT_SECRET`, or `DB_PASSWORD` to GitHub.

## 📦 Deployment

### Backend
- Can be deployed to services like Render, Heroku, or an AWS EC2 instance.
- Make sure to add your `.env` variables in your hosting provider's dashboard.

### Frontend
- **Android**: `flutter build apk` or `flutter build appbundle`.
- **iOS**: `flutter build ipa`.
- **Web**: `flutter build web`.

---
*Developed for the Pegasos Field Management Team.*
