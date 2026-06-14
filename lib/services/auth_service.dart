import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _i = AuthService._();
  factory AuthService() => _i;
  AuthService._();

  final _auth         = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Stream<User?> get userStream => _auth.authStateChanges();
  User?   get currentUser => _auth.currentUser;
  String? get uid         => _auth.currentUser?.uid;
  String? get userEmail   => _auth.currentUser?.email;
  String? get userName    => _auth.currentUser?.displayName;
  String? get userPhoto   => _auth.currentUser?.photoURL;
  bool    get isLoggedIn  => _auth.currentUser != null;

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}