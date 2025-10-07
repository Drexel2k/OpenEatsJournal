# Open Eats Journal
Open Eats Journal is a free and open source eats, nutrition and calories journal.

## Getting Started With Development
### Android development with Windows 11
This IDE setup is tested on Windows 11.

For setup first you need the following things:
- Android SDK and Android Emulator
- Flutter
- Git
- IDE like Android Studio or VS Code with Flutter Plugin installed.

Use paths for SDKs without spaces and sepcial characers.

#### Setup Android SDK and Emulator
1. Download Android Studio from https://developer.android.com/studio and install. Keep "Android Virtual Device" checked. Start Android Studio after installation.
2. Install the Android SDK when asked.
3. After finishing the SDK installation you should the "Welcome to Android Studio" Screen. Click on "More Actions" -> "SDK Manager", check that Android 16.0 API Level 36.0 is installed. Switch to "SDK Tools" tab and check "Android SDK Command-line Tools (latest)", click "Apply" and install the tools. 
4. Also in the "SDK Manager" check "Show Package Details" (bottom right), switch to "SDK Tools", in the section NDK (Side by side) check version 28.2.13676358 and click "Apply" to install it. The default NDK version that is configured with Flutter is too low for sqflite, therefore the NDK version was overriden in this project in src/android/app/build.gradle.kts (ndkVersion = "28.2.13676358"). Click "OK".
5. Check under "More Actions" -> "Virtual Device Manager" if a virtual phone was set up, if not create one, e.g. a Medium Phone with Default Settings.
6. Close Android Studio.

#### Setup Flutter SDK
1. Download Flutter (currently 3.35.5 is used) from https://docs.flutter.dev/install/archive and extract.

#### Setup the Workspace in Visual Studio Code (VSC)
1. Create a new folder, open the folder in VSC.
2. ⁠Clone the repository with git in a VSC terminal (make sure the active folder in the terminal is your created folder from step 1):  
`git clone https://github.com/Drexel2k/OpenEatsJournal .` 
3. Configure the Flutter SDK: Edit the path of "dart.flutterSdkPath" in ".vscode\settings.json" file.
4. Configure the Android SDK path for Flutter:  
`flutter config --android-sdk "c:\path\to\androidSDK"`
5. ⁠Get Dependencies. Switch to the src folder first.  
`cd src`
`flutter pub get` 
6. ⁠Restart VSC, VSC detects now that this is a flutter project. On the Bottom Right "No Device" ist displayed, click on it, then select "Start Medium Phone" on the command Palette on the top. Wait for the phone to boot up.
7. Press F5 to start a debug session (may take a while on the first time). Keep the virtual phone running all the time, just start and stop Debugging.
8. If you want to test barcode scanning, you need to add a barcode to the virtual camera environment on the virtual device. On the bar beside the virtual device click the 3 dots at the bottom, then "Camera", and upload a barcode image on the "Wall" section. When using the camera to scan a barcode, walk to that wall with the camera controls.