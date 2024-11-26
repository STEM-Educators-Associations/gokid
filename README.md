# GoKid Mobile Application

**GoKid** is a mobile application developed to enhance **communication** between parents and children with special
needs. This app provides a safe, controlled environment where children can interact with familiar images, promoting
engagement and understanding, while offering parents tools to manage and personalize the experience.

---

### Now, GoKid is Live!

<p >
  <a href="https://apps.apple.com/tr/app/gokid/id6654923599?l=tr">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" height="50">
  </a>
  <a href="https://play.google.com/store/apps/details?id=dev.erenmalkoc.pecs">
    <img src="https://upload.wikimedia.org/wikipedia/commons/7/78/Google_Play_Store_badge_EN.svg" alt="Get it on Google Play" height="50">
  </a>
</p>

---

## How to Contribute 

Before starting, [visit our official webpage](https://gokid.stemegitimciler.org) for detailed project information.

### (completely set-up)

To contribute:

1. Fork the repository.
2. Make your changes.
3. Submit a pull request.
4. For significant changes, open an issue to discuss your ideas before starting work.

---

### Prerequisites

1. **Install Flutter SDK**:
    - Follow the [Flutter Installation Guide](https://flutter.dev/docs/get-started/install) to install Flutter SDK.
    - Verify the installation:
      ```bash
      flutter doctor
      ```

2. **Install Dart SDK**:
    - Dart comes pre-installed with Flutter. Verify the Dart installation:
      ```bash
      dart --version
      ```

3. **Install VS Code**:
    - Install Visual Studio Code from the [official website](https://code.visualstudio.com/).
    - Install the Flutter and Dart extensions from the VS Code Marketplace.
    - Ensure VS Code recognizes the Flutter installation:

4. **Install Android Studio** (for Android builds):
    - Install Android Studio and set up the emulator. Ensure `adb` (Android Debug Bridge) is accessible in your
      terminal.
    - Add the Android SDK to your system path (if not done automatically).

5. **Install Firebase CLI** (optional but recommended for Firebase project management):
    - Follow the [Firebase CLI Setup Guide](https://firebase.google.com/docs/cli).

### 6. **Setting up Firebase Functions (JavaScript)**

- Firebase Functions are used for backend operations, such as sending notifications.

### 7. **Deploy the Function**

- Deploy the function to Firebase using the following command:

  ```bash
  firebase deploy --only functions
  ```

- After deployment, Firebase will provide a URL for your function. Use this URL to make HTTP requests and send notifications.

### 8. **Testing the Function**

- You can test the above function by making a `POST` request:

  #### Example POST Request
  ```bash
  curl -X POST https://<your-region>-<your-project>.cloudfunctions.net/sendNotification \
  -H "Content-Type: application/json" \
  -d '{
    "token": "DEVICE_FCM_TOKEN",
    "title": "Hello!",
    "body": "This is a test notification."
  }'
  ```

---

### Notes:
- **Firebase Admin SDK**: The Firebase Admin SDK is used to send notifications. This SDK allows backend operations like sending notifications, reading/writing to the database, etc.
- **FCM Token**: The FCM token of the device receiving the notification is required. This token is obtained on the client side and sent to the backend.


---

### Step-by-Step Setup Instructions

1. **Clone the Repository**
    - Clone the project repository from GitHub:
      ```bash
      git clone https://github.com/erenmalkoc/gokid.git
      ```

2. **Install Dependencies**
    - Fetch all required Flutter packages:
      ```bash
      flutter pub get
      ```

3. **Set Up Firebase**
   Firebase is a critical part of the GoKid application. Follow these steps to configure it properly:

   #### a. Create a Firebase Project
    - Go to the [Firebase Console](https://console.firebase.google.com/) and sign in with your Google account.
    - Click **Add Project** and enter a project name (e.g., `GoKid`).
    - Disable Google Analytics (optional) and click **Create Project**.

   #### b. Enable Required Firebase Services
    - In your Firebase project, enable the following services:
        - **Authentication**:
            - Go to the **Authentication** tab.
            - Click **Get Started**.
            - Enable the **Email/Password** sign-in method under the **Sign-in method** tab.
        - **Firestore Database**:
            - Go to the **Firestore Database** tab.
            - Click **Create Database**.
            - Start in **Test Mode** for development purposes (you can update rules later).

   #### c. Add Your App to Firebase
    - Add an **Android App**:
        1. Click the **Add App** button and select **Android**.
        2. Enter your app's package name (e.g., `com.gokid.mobile`).
        3. Download the `google-services.json` file after configuration and place it in the `android/app/` folder of
           your project.

    - Add an **iOS App**:
        1. Click the **Add App** button and select **iOS**.
        2. Enter your app’s bundle ID (e.g., `com.gokid.mobile`).
        3. Download the `GoogleService-Info.plist` file after configuration and place it in the `ios/Runner/` folder of
           your project.

4. **Configure Environment Variables**
    - Create a `.env` file in the project root with your Firebase credentials. Use the format below:
      ```plaintext
      FIREBASE_API_KEY=your_api_key
      FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
      FIREBASE_PROJECT_ID=your_project_id
      FIREBASE_STORAGE_BUCKET=your_project.appspot.com
      FIREBASE_MESSAGING_SENDER_ID=your_sender_id
      FIREBASE_APP_ID=your_app_id
      ```
    - Refer to the example file `env.example` for guidance.
    - --OR--
    - Just Copy-Paste google-services.json file from Firebase.(Basic Setup)


5. **Run the Application**
    - Open the project in **VS Code**:
        1. Open VS Code and click **File > Open Folder**.
        2. Navigate to the `GoKid` project folder and select it.
    - **Run the App**:
        1. Press `F5` or go to the **Run and Debug** menu in VS Code.
        2. Select the desired emulator/device from the device selection dropdown.
        3. Run the app.

6. **Build the Application**
    - Build the app for deployment:
        - **Android (APK)**:
          ```bash
          flutter build apk --release
          ```

---

## License

GoKid is licensed under the [GPLv3 License](LICENSE.md).  
This license allows others to freely use, modify, and distribute the application under the terms defined in the license.

For full details, refer to the [LICENSE file](LICENSE.md).

---

## Wiki

The **GoKid Wiki** provides additional resources, guides, and community contributions. Here you can find:

- **User Guide**: Step-by-step instructions on how to set up and use the app.
- **Developer Documentation**: Information for developers looking to contribute, including setup instructions and coding
  standards.
- **FAQ**: Common questions and answers about the app and its features.

Visit the [GoKid Wiki](https://github.com/erenmalkoc/gokid/wiki) for more details and resources.

---

## Support and Community

For additional information, feedback, or support, please reach out through the following channels:

- **Email**: [mobil@stemegitimciler.org](mailto:mobil@stemegitimciler.org)
- **Website**: [GoKid Official Website](https://gokid.stemegitimciler.org)
- **Terms & Privacy**: [GoKid Terms & Privacy](https://gokid.stemegitimciler.org/terms)

---

**© 2024 STEM Educators Associations. All Rights Reserved.**
