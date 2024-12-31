import 'package:firebase_auth/firebase_auth.dart';

class Auth{
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  String? get userDisplayName => currentUser==null?'Guest':currentUser?.displayName;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  Future<void> signInWithEmalAndPassword({required String email,required String password}) async{
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserWithEmalAndPassword({required String email,required String password}) async{
    await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  Future<void> updateProfile({String? photoURL}) async{
    try{
      currentUser?.updatePhotoURL(photoURL);
    }
    on FirebaseAuthException catch(e){
    }
  }
}