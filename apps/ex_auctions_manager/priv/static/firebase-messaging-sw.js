importScripts("https://www.gstatic.com/firebasejs/8.6.8/firebase.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.8/firebase-messaging.js");

var firebaseConfig = {
    apiKey: "AIzaSyD2u4eJKNnTrMQ-1diCjRQWTs-p0Dyn0ps",
    authDomain: "test-project-3dada.firebaseapp.com",
    projectId: "test-project-3dada",
    storageBucket: "test-project-3dada.appspot.com",
    messagingSenderId: "664249096512",
    appId: "1:664249096512:web:602ad7ca6979857c4f02a5",
    measurementId: "G-PSYWTR3X5N"
  };
  
// Initialize Firebase
firebase.initializeApp(firebaseConfig);
  
const messaging = firebase.messaging();