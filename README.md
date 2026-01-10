# Open Eats Journal
Open Eats Journal is a free and open source eats, nutrition and calories journal app for Android and iOS.

## Getting Started With Development
### Android development with Windows 11
This IDE setup is tested on Windows 11.

For setup first you need the following things:
- Android SDK and Android Emulator
- Flutter
- Git
- VS Code with Flutter Plugin installed.

Use paths for SDKs without spaces and sepcial characers.

#### Setup Android SDK and Emulator
1. Download Android Studio from https://developer.android.com/studio and install. Keep "Android Virtual Device" checked. Start Android Studio after installation.
2. Install the Android SDK when asked.
3. After finishing the SDK installation you should the "Welcome to Android Studio" Screen. Click on "More Actions" -> "SDK Manager", check that Android 16.0 API Level 36.0 is installed. Switch to "SDK Tools" tab and check "Android SDK Command-line Tools (latest)", click "Apply" and install the tools. 
4. Check under "More Actions" -> "Virtual Device Manager" if a virtual phone was set up, if not create one, e.g. a Medium Phone with Default Settings. To copy files from or to a virtual device with adb (see [Tips for Developing](#tips-for-developing) -> 2.) you nee a rooted virtual device, therefore create a virtual device without Google Play Store, in the "Configure virtual device" screen select Google APIs under "Services". Alternatively you can access the file system also via Android Studio, then you dont need the rooted device.
5. Close Android Studio.
6. When debugging and setting the focus on a text field for the first time, click on the 3 line menu on the appearing bar. Then click on "Settings", then "Write in text fields" and disable "Use stylus to write in text fields". Go back, click "Physical keyboard" and enable "Show on-screen keyboard". This enforces the virtual keyboard on the emulator, which triggers rebuilding of widgets when it opens, which happens on a real phone all the time. So errors due to rebuilding the widgets will be noticed during development.

#### Setup Flutter SDK
1. Download Flutter (currently 3.38.5 is used) from https://docs.flutter.dev/install/archive and extract.

#### Setup the Workspace in Visual Studio Code (VSC)
1. Download and install git.
2. Create a new folder, open the folder in VSC.
3. ⁠Clone the repository with git in a VSC terminal (make sure the active folder in the terminal is your created folder from step 1):  
`git clone https://github.com/Drexel2k/OpenEatsJournal .` 
4. Configure the Flutter SDK: Edit the path of "dart.flutterSdkPath" in ".vscode\settings.json" file.
5. Configure the Android SDK path for Flutter:  
`flutter config --android-sdk "c:\path\to\androidSDK"`
6. ⁠Get Dependencies. Switch to the src folder first.  
`cd src`
`flutter pub get` 
7. ⁠Restart VSC, VSC detects now that this is a flutter project. On the Bottom Right "No Device" ist displayed, click on it, then select "Start Medium Phone" on the command Palette on the top. Wait for the phone to boot up.
8. Press F5 to start a debug session (may take a while on the first time). Keep the virtual phone running all the time, just start and stop Debugging.

#### Tips for developing
1. If you want to test barcode scanning, you need to add a barcode to the virtual camera environment on the virtual device. On the bar beside the virtual device click the 3 dots at the bottom, then "Camera", and upload a barcode image on the "Wall" section. When using the camera to scan a barcode, walk to that wall with the camera controls.
2. To copy files from or to the virtual device e.g. the database file, you can use the adb command from the SDK, therefore you need a rooted device (see [Setup Android SDK and Emulator](#setup-android-sdk-and-emulator) -> 5.). From a command line you can root and access the device.  
List device names:  
`c:\path\to\android\sdk\platform-tools\adb devices`  
Root with the device name:  
`c:\path\to\android\sdk\platform-tools\adb -s device-name root`  
Copy database file e.g. (push for the other directioon):  
`c:\path\to\android\sdk\platform-tools\adb -s device-name pull /data/data/com.drexeldevelopment.openeatsjournal/databases/oej.db c:\target\path`  
Connect to shell to browse the file system e.g.:  
`c:\path\to\android\sdk\platform-tools\adb -s device-name shell`  
Exit:  
`exit`  
 &nbsp;   
 Alternatively you can access files via Android Studio, therefore open a new project in Android Studio and open the "Device Explorer", while the virtual device is running. If the Device Explorer isn't on the right bar, click the 3 dots on the left bar and select "Device Explorer". In the Device Explorer right click the file and select "Save As...".