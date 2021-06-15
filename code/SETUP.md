# Web Server Set-up
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

5. Run the web server using the command 
```
nodejs app.js
```

6. Optionally, you can deploy the webserver using Heroku by following the instructions at `https://devcenter.heroku.com/articles/git`

# Mobile Application Set-up
