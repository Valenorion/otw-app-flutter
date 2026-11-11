importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

// Ganti konfigurasi ini dengan Firebase config milikmu (bisa dilihat di firebase_options.dart)
const firebaseConfig = {
  apiKey: "API_KEY_MILIKMU",
  authDomain: "DOMAIN_MILIKMU.firebaseapp.com",
  projectId: "PROJECT_ID_MILIKMU",
  storageBucket: "BUCKET_MILIKMU.appspot.com",
  messagingSenderId: "SENDER_ID_MILIKMU",
  appId: "APP_ID_MILIKMU"
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// Menangani notifikasi latar belakang (background)
messaging.onBackgroundMessage((payload) => {
  console.log("Ping diterima di background: ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});