/// Social sign-in configuration.
///
/// Google: Web client ID from Firebase / google-services.json (client_type 3).
/// Facebook: Set [facebookAppId] and [facebookClientToken] from
/// Firebase Console > Authentication > Sign-in method > Facebook,
/// and mirror the same values in android/app/src/main/res/values/strings.xml.
class SocialAuthConfig {
  SocialAuthConfig._();

  static const googleWebClientId =
      '16471229960-44orc7bnk00tsqvbmcus2s0g3mlcpqjp.apps.googleusercontent.com';

  static const facebookAppId = '1920610358630835';
  static const facebookClientToken = '2d184f3b9f520e86a088975136aa1833';
}
