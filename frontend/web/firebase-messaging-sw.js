// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
firebase.initializeApp({
  apiKey: "AIzaSyD43tttY-4A0D70IxDXfbowBAIvD1BMPL0",
  authDomain: "capstone-sss.firebaseapp.com",
  projectId: "capstone-sss",
  storageBucket: "capstone-sss.appspot.com",
  messagingSenderId: "790077578955",
  appId: "1:790077578955:web:d86f9118011ced449a054e",
  measurementId: "G-29SC1Q3G1L"
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});