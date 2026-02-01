import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    // Check if running on a platform that supports the native Google Sign In SDK
    final bool isNativePlatform = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isNativePlatform) {
      /// Perform Native Google Sign-In (Android/iOS)
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Google Sign In was aborted by user';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } else {
      // For Desktop (Linux, Windows, MacOS) and Web
      // Linux Desktop browsers don't support custom schemes (like io.supabase.flutter://) 
      // well without complex OS registration.
      // We use a localhost redirect which suggests the app or a local listener handles it.
      // For Web, we let Supabase handle the current URL.
      
      // For Desktop (Linux, Windows, MacOS)
      // We spin up a local server to catch the callback
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 54321);
        
        // Launch the OAuth flow
        final bool success = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:54321/auth/callback',
        );

        if (!success) {
          await server.close();
          throw 'Could not launch Google Sign In';
        }

        // Wait for the callback
        try {
          await for (final HttpRequest request in server) {
            final uri = request.uri;
            if (uri.path == '/auth/callback') {
              final code = uri.queryParameters['code'];
              if (code != null) {
                // Exchange code for session
                await _supabase.auth.exchangeCodeForSession(code);
                
                // Show success to user
                request.response
                  ..statusCode = HttpStatus.ok
                  ..headers.contentType = ContentType.html
                  ..write('<html><body><h1>Login Successful!</h1><p>You can close this tab and return to the app.</p><script>window.close();</script></body></html>');
                await request.response.close();
                break; // Stop listening
              } else {
                 request.response
                  ..statusCode = HttpStatus.badRequest
                  ..write('No code found');
                 await request.response.close();
              }
            }
          }
        } finally {
          await server.close();
        }
        
      } else {
        // Web fallback (handled by Supabase lib automatically)
        final bool success = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: null, 
        );
        if (!success) {
          throw 'Could not launch Google Sign In';
        }
      }
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    // Check if running on a platform that supports the native Google Sign In SDK
    final bool isNativePlatform = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    
    if (isNativePlatform) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    }
    
    await _supabase.auth.signOut();
  }
}
