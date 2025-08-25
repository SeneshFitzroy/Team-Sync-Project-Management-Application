# ✓ TaskSync - Project Management Application

A clean, professional Flutter application for project management with task tracking, team collaboration, and real-time chat functionality.

## 🚀 Features

- **Authentication System**: Secure login and registration with Firebase Authentication
- **Dashboard**: Project overview with statistics and quick actions  
- **Task Management**: Create, assign, and track tasks with priority levels
- **Team Chat**: Real-time messaging system for team collaboration
- **Calendar Integration**: View and manage project deadlines
- **User Profiles**: Manage personal information and settings

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider pattern
- **UI/UX**: Material Design 3
- **Platform**: Cross-platform (Windows, iOS, Android, Web)

## 📱 Screens

### Core Navigation
- Splash Screen
- Welcome Pages
- Authentication (Login/Register)
- Main App Navigator with 5 tabs:
  - Dashboard
  - Task Manager  
  - Calendar
  - Chat
  - Profile

### Additional Features
- Forgot Password flow
- Profile management
- Settings and preferences
- Help and support

## 🎨 Design

The app follows Material Design 3 principles with:
- Clean, modern interface
- Consistent color scheme
- Smooth animations and transitions
- Responsive layout for all screen sizes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Firebase project setup
- IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository
```bash
git clone https://github.com/SeneshFitzroy/Team-Sync-Project-Management-Application.git
```

2. Navigate to the project directory
```bash
cd Team-Sync-Project-Management-Application
```

3. Get dependencies
```bash
flutter pub get
```

4. Configure Firebase
   - Add your `google-services.json` for Android
   - Add your `GoogleService-Info.plist` for iOS
   - Update `lib/firebase_options.dart` with your configuration

5. Run the app
```bash
flutter run
```

### Building for Production

#### Windows
```bash
flutter build windows --release
```

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── Screens/                  # All UI screens
├── widgets/                  # Reusable widgets
├── Services/                 # Business logic and API calls
├── models/                   # Data models
├── theme/                    # App theming
└── utils/                    # Helper utilities
```

## 🔥 Firebase Setup

This project uses Firebase for:
- **Authentication**: User registration and login
- **Firestore**: Real-time database for tasks and projects
- **Storage**: File uploads and user avatars
- **Cloud Functions**: Server-side logic

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions, please open an issue in the GitHub repository.

---

**Built with ❤️ using Flutter and Firebase**
   
2. **Project Management**:
   - Kanban boards for task management. 📊
   - Assign and track tasks with dependencies. 🔗
   - Set deadlines and milestones. 📆
   - Visualize project progress and team activities. 👀
   
3. **Communication**:
   - Group chat for team discussions. 💬
   - Threaded discussions for specific tasks or topics. 🗣️
   - Audio and video calls for meetings. 🎥📞
   - Real-time collaborative whiteboard for brainstorming and planning. 🧠

4. **File & Code Sharing**:
   - Upload project files directly. 📤
   - Integration with cloud storage (Google Drive). ☁️
   - Manage code repositories for project-related development work. 💻

5. **Calendar & Notifications**:
   - Schedule meetings and tasks. 📅
   - Track deadlines and milestones. ⏳
   - Receive automated reminders for important events and tasks. ⏰

## Wireframe Diagram 🖼️

A visual representation of the user interface and interactions within the app can be viewed here:

[**Wireframe Diagram**](https://www.figma.com/design/J49r9ciNtafSqTI8xhv8nA/Team-01---Project-Management?t=31ijVBPP23iKFRgg-1)

## Getting Started 🚀

These instructions will help you set up the project locally for development and testing purposes.

### Prerequisites 🛠️

To run this project, you need to have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable version) 🦄
- [Dart](https://dart.dev/get-dart) (included with Flutter) 🐦
- An IDE like [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio) 💻
- Android/iOS Simulator or physical device for testing 📱

### Installation 🔧

1. **Clone the repository:**

   ```bash
   git clone https://github.com/SeneshFitzroy/Team-Sync-Project-Management-Application.git

2. **Navigate to the project directory:**

   ```bash
   cd Team-Sync-Project-Management-Application
   ```

3. **Install the dependencies:**

   Run the following command in your terminal to install the Flutter dependencies:

   ```bash
   flutter pub get
   ```

4. **Run the project:**

   To run the application on a device or emulator:

   ```bash
   flutter run
   ```

## Usage 📊

Once the app is running, you can access the following features:

1. **Create or Join a Team**  
   Sign up or log in to create a new team or join an existing team. 👥

2. **Assign Tasks Using Kanban Boards**  
   Assign tasks to team members using the Kanban boards and track task progress. 📋

3. **Communicate with Your Team**  
   Stay connected with your team via group chats, threaded discussions, and audio/video calls. 💬

4. **Upload and Manage Project Documents**  
   Upload project-related documents, manage files, and share them with team members. 📂

5. **Track Your Project’s Progress**  
   View the project’s progress through a dashboard and get notified about tasks and deadlines. 📈

## Contributing 🤝

We welcome contributions from the community! To contribute to this project, follow the steps below:

1. **Fork the repository**  
   Click on the "Fork" button at the top-right of the repository page to fork the repository to your GitHub account. 🍴

2. **Create a new branch**  
   Create a new branch for your feature or bug fix:

   ```bash
   git checkout -b feature-branch
   ```

3. **Make changes**  
   Implement your changes and ensure they are properly tested. 🧑‍💻

4. **Commit your changes**  
   Once your changes are made, commit them with a descriptive message:

   ```bash
   git commit -m "Added feature XYZ"
   ```

5. **Push to your forked repository**  
   Push your changes to your forked repository:

   ```bash
   git push origin feature-branch
   ```

6. **Create a pull request**  
   From your forked repository, open a pull request to the `main` branch of the original repository. 📝

Please ensure your code adheres to our coding guidelines and includes proper documentation. 📚

## License 📄

This project is licensed under the **Apache 2.0 License**. See the [LICENSE](LICENSE) file for details. 🔓
```

---

I added emojis for better visual appeal and engagement, as well as for clarity in each section. You can now copy and paste the entire block into your `README.md` file on GitHub. Let me know if you need any further adjustments! 😊
