/// Central API configuration.
///
/// ## Build Commands
///
/// All `--dart-define` values are compiled into the binary at build time.
/// They must be passed **every time** you build — they are not cached.
///
/// ### Android (APK / AAB)
/// ```sh
/// # Debug / emulator (uses 10.0.2.2 loopback — no flags needed)
/// flutter run
///
/// # Release APK
/// flutter build apk \
///   --dart-define=API_BASE=https://your-server.com \
///   --dart-define=GROQ_API_KEY=gsk_xxx
///
/// # Release AAB (Play Store)
/// flutter build appbundle \
///   --dart-define=API_BASE=https://your-server.com \
///   --dart-define=GROQ_API_KEY=gsk_xxx
/// ```
///
/// ### iOS (IPA)
/// ```sh
/// # Release IPA — IMPORTANT: API_BASE MUST be https:// on iOS.
/// # Plain http:// URLs are blocked by App Transport Security (ATS).
/// flutter build ipa \
///   --dart-define=API_BASE=https://your-server.com \
///   --dart-define=GROQ_API_KEY=gsk_xxx
/// ```
///
/// > **iOS ATS note**: iOS blocks all plain-HTTP (`http://`) connections by
/// > default. The Groq API is always HTTPS, so AI features are fine. However
/// > your own backend **must** serve over HTTPS for a production IPA, or you
/// > must add an explicit `NSExceptionDomain` entry in `ios/Runner/Info.plist`.
///
/// The value is never committed to source control.
library;



/// The root server URL (no trailing slash).
///
/// Falls back to the Android emulator loopback address on Android,
/// or localhost on Windows, iOS simulator, and web.
///
/// **iOS**: Use an `https://` URL in production — ATS blocks plain HTTP.
String get kApiBase {
  const String envBase = String.fromEnvironment('API_BASE');
  if (envBase.isNotEmpty) {
    return envBase;
  }

  return 'https://lexgo-bc-2.onrender.com';
}

/// The Gemini API Key for the Ask AI tab (optional / legacy).
/// Pass via `--dart-define=GEMINI_API_KEY=your_key`.
const String kGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

/// The Groq API Key for the Ask AI and Quiz generation features.
///
/// Get a FREE key (no credit card) at https://console.groq.com
///
/// The [defaultValue] is a fallback so the app compiles and runs even without
/// the `--dart-define` flag (e.g. during CI or quick local runs). Replace it
/// with your own key or always pass `--dart-define=GROQ_API_KEY=gsk_xxx`.
const String kGroqApiKey = String.fromEnvironment(
  'GROQ_API_KEY',
  defaultValue: '', // Pass via --dart-define=GROQ_API_KEY=gsk_xxx at build time
);
const String kGroqWhisperModel = 'whisper-large-v3';
