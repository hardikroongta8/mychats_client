# MyChats - Realtime Chatting App

MyChats is a Flutter-based realtime chatting app that allows users to connect and chat with friends, family, and colleagues in real-time. The app provides a seamless messaging experience with features such as instant messaging, photo sharing, online presence and typing indicators.

## Features

- **Realtime Messaging**: Send and receive messages instantly with other users in real-time.
- **User Presence**: See the online/offline status of your contacts.
- **User Authentication**: Sign up and log in securely using phone number.
- **Contact List**: Maintain a list of your contacts and easily find and chat with them.
- **Profile Customization**: Personalize your profile by adding a profile picture and setting a status message.

## Screenshots
You can checkout these [screenshots](https://drive.google.com/drive/folders/1tAkyJa958yoLpkKETplrXkoLEWrGRT9L?usp=sharing) to know about the working of the app.

## Getting Started

Don't forget to start the server before running the app.
- [Github](https://github.com/hardikroongta8/mychats_backend)

To get started with MyChats, follow these steps:

1. Clone the repository:

```shell
git clone https://github.com/hardikroongta8/mychats_client.git
```

2. Navigate to the project directory:

```shell
cd mychats_client
```

3. Install the dependencies by running the following command:

```shell
flutter pub get
```

4. Run the app on a connected device or emulator:

```shell
flutter run
```

5. Start using MyChats and enjoy real-time messaging!

## Technologies Used

- **Flutter**: The app is built using the Flutter framework, which enables cross-platform development for iOS and Android.
- **Flutter Provider**: The Flutter Provider package is used for state management within the app.
- **Firebase Authentication**: Firebase Authentication is used for user authentication and account management.
- **Socket.IO**: Used for implementing real-time messaging.

## Folder Structure

The project follows a standard Flutter project structure:

```
mychats/
  |- lib/
     |- models/
     |- screens/
     |- services/
     |- shared/
     |- widgets/
     |- main.dart
  |- assets/
  |- pubspec.yaml
```

- **lib/models**: Contains the data models used in the app.
- **lib/screens**: Contains the different screens of the app, such as the chat screen, contact list screen, etc.
- **lib/services**: Contains the services responsible for interacting with Firebase and Server.
- **lib/shared**: Contains shared components or utilities that are used across multiple screens or widgets
- **lib/widgets**: Contains widgets for to make the code concise. 
- **assets**: Contains static assets such as images and fonts used in the app.
- **pubspec.yaml**: Defines the app dependencies and configuration.

## Contributing

Contributions to MyChats are welcome! If you find any issues or have suggestions for improvements, please submit an issue or a pull request.

## Contact

If you have any questions or inquiries, please contact us at hardikroongta8@gmail.com.

Happy chatting with MyChats!
