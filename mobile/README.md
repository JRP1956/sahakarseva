# Mobile — SahakarSeva (Flutter)

One app, role picked at login: customer (book → match → pay → rate) and worker (accept → start → complete → earnings → profile). EN / HI / MR.

```bash
cd mobile
flutter pub get
flutter run -d chrome                 # web, quickest to demo
flutter run -d <android-device>       # needs Android SDK licenses accepted
flutter run --dart-define=API_URL=https://your-backend/api/v1
```

Demo logins (password `pass123`): customer `9100000000`, worker `9800000001`.
