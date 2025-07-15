# Open Eats Journal
Open Eats Journal is a free and open source eats, nutrition and calories journal.

## Getting Started With Development
### Android development with Windows 11
This IDE setup is tested on Windows 11.

For setup first you need the following things:
- Android SDK and Android Emulator
- Flutter
- IDE like Android Studio or VS Code with Flutter Plugin installed.

Use paths for SDKs without spaces and sepcial characers.

#### Setup Android SDK and Emulator
1. Download Android Studio from https://developer.android.com/studio and install. Keep "Android Virtual Device" checked. Start Android Studio after installation.
2. Install the Android SDK when asked.
3. After finishing the SDK installation you should the "Welcome to Android Studio" Screen. Click on "More Actions" -> "SDK Manager", switch to "SDK Tools" tab and check "Android SDK Command-line Tools (latest)", click "OK" and install the tools. 
4. Check under "More Actions" -> "Virtual Device Manager" if a virtual phone was set up, if not create one, e.g. a Medium Phone with Default Settings.
5. Close Android Studio.

#### Setup Flutter SDK
1. Download Flutter (currently 3.32.6 is used) from https://docs.flutter.dev/install/archive and extract.

#### Setup the Workspace in Visual Studio Code (VSC)
1. Create a new folder, open the folder in VSC.
2. Configure the Flutter SDK: In the bottom left will pop up an error, that the Flutter SKD could not be found. Click "Locate SDK" and select the Flutter SDK folder.
3. Configure the Android SDK path for Flutter:  
`flutter config --android-sdk "c:\path\to\androidSDK"`
4. ⁠Clone the repository with git in a VSC terminal (make sure the active folder in the terminal is your created folder from step 1):  
`git clone https://github.com/Drexel2k/OpenEatsJournal .` 
5. ⁠Get Dependencies. Switch to the src folder first.  
`cd src`
`flutter pub get` 
6. ⁠Restart VSC, VSC detects now that this is a flutter project. On the Bottom Right "No Device" ist displayed, click on it, then select "Start Medium Phone" on the command Palette on the top. Wait for the phone to boot up.
7. Press F5 to start a debug session (may taka a while on the first time). Keep the virtual phone running all the time, just start and stop Debugging.