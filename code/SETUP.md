# Web Server Set-up (Optional)
## Prerequisites
* NodeJS & npm
* Python 3
* Firebase Account
* Text Editor (Sublime Text, Atom, etc.)
## Instructions
1. Run the following command inside the `webserver` directory to install required packages:
```
npm install
```
2. Create a .env file to securely store API keys with the command:
```
touch .env
```
3. Get your Firebase service account keys by following the instructions from `https://firebase.google.com/docs/admin/setup`
4. Populate the .env file with required variables such as : 
```
ACCESS_SECRET is the string for making the JWT access keys for authentication
REFRESH_SECRET is the string for making the JWT refresh keys
FIREBASE_BUCKET is the url of your Firebase project's storage, without the gs://
FIREBASE_PRIVATE_KEY, FIREBASE_CLIENT_EMAIL, FIREBASE_PROJECT_ID can all be found in the Firebase Admin SDK .json file
```

5. Run the web server on localhost with port 5000 using the command : 
```
nodejs app.js
```

6. Schedule to run the Python script `sp_script.py` using your preferred scheduler (cron or Windows Task Scheduler)

7. Optionally, you can deploy the webserver using Heroku by following the instructions at `https://devcenter.heroku.com/articles/git`

# Mobile Application Set-up
## Prerequisites
* Flutter 1.22.5
* IDE of choice (preferably Android Studio or IntelliJ IDEA)
## Instructions
1. Install required Flutter version from link `https://flutter.dev/docs/development/tools/sdk/releases`
2. Set up the SDK with your preferred IDE by following the instructions at the official Flutter page `https://flutter.dev/docs/get-started/install`
3. Navigate to the `mobile_app/sp_phase_two` directory and choose between different commands :
`flutter run` to run the mobile app in your machine's emulator or an attached external device
`flutter build apk --debug` to build an APK file of the application
`flutter install` to install the built APK file to your machine's emulator or attached external device

Note that a copy of the generated APK file can be found by navigating to the `sp_phase_two/build/app/outputs/apk/debug` folder
