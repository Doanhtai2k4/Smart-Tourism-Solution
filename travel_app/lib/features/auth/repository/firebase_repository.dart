import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:travel_app/core/failure.dart';

import 'package:travel_app/core/type_def.dart';

import 'package:travel_app/core/constants/firebase_constant.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseStorage _storage;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _auth = auth,
       _googleSignIn = googleSignIn,
       _storage = storage;


  CollectionReference get _users =>
      _firestore.collection(FirebaseConstant.userCollection);

  FirebaseAuth get auth => _auth;

  Stream<User?> get authStateChange => _auth.authStateChanges();
  FutureEither<(UserModel, bool)> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        googleAuthProvider.addScope('https://www.googleapis.com/screens/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleAuthProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return left(Failure('Đăng nhập bị hủy.'));
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final uid = userCredential.user!.uid;
      final userDoc = await _users.doc(uid).get();
      final bool isNewUser = !userDoc.exists || userDoc.data() == null;

      late UserModel userModel;

      if (isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName,
          email: userCredential.user!.email!,
          profilePic: userCredential.user!.photoURL,
          uid: uid,
          isAuthenticated: true,
          createdAt: DateTime.now(),
        );
        await _users.doc(uid).set(userModel.toMap());
      } else {
        userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }

      return right((userModel, isNewUser));
    } on FirebaseAuthException catch (e) {
      return left(Failure(_getFirebaseAuthErrorMessage(e.code)));
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('10') || errorStr.contains('sign_in_failed')) {
        return left(Failure('Lỗi cấu hình Google Sign-In (API Exception 10). Hãy đảm bảo bạn đã cấu hình mã vân tay SHA-1 của thiết bị trong Firebase Console.'));
      }
      return left(Failure(errorStr));
    }
  }


  FutureEither<UserModel> signin(String email, String password) async {
    try {
      debugPrint('AuthRepository: Attemping signin for $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('AuthRepository: Firebase Auth success for ${userCredential.user?.uid}');
      UserModel userModel = await getUserData(userCredential.user!.uid).first;
      debugPrint('AuthRepository: Firestore data success for ${userModel.name}');
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthRepository: FirebaseAuthException code=${e.code}, msg=${e.message}');
      return left(Failure(_getFirebaseAuthErrorMessage(e.code)));
    } catch (e) {
      debugPrint('AuthRepository: General error: $e');
      return left(Failure(e.toString()));
    }
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-email':
        return 'Định dạng Email không hợp lệ hoặc tài khoản không tồn tại.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Sai mật khẩu hoặc email.';
      case 'user-disabled':
        return 'Tài khoản này đã bị khóa.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại đường truyền internet.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng bởi một tài khoản khác.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng nhập mật khẩu tối thiểu 6 ký tự.';
      default:
        return 'Lỗi xác thực: $code';
    }
  }

  FutureEither<UserModel> signup(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        isAuthenticated: true,
        createdAt: DateTime.now(),
      );
      
      // Create initial skeleton document
      await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(_getFirebaseAuthErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Lỗi Firebase'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signUpWithProfile({
    required String email,
    required String password,
    required String name,
    required DateTime? dateOfBirth,
    required String? gender,
    required String? country,
    required String? occupation,
    required List<String> hobbies,
  }) async {
    try {
      // 1. Create Auth Account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 2. Prepare Full UserModel
      final userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
        country: country,
        occupation: occupation,
        hobbies: hobbies,
        isAuthenticated: true,
        createdAt: DateTime.now(),
      );

      // 3. Save to Firestore
      await _users.doc(uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(_getFirebaseAuthErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Lỗi Firebase'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<void> saveUserProfile(UserModel user) async {
    try {
      await _users.doc(user.uid).update({
        'name': user.name,
        'dateOfBirth': user.dateOfBirth,
        'gender': user.gender,
        'country': user.country,
        'occupation': user.occupation,
        'hobbies': user.hobbies,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return right(null);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> updateUserData(UserModel user) async {
    await _users.doc(user.uid).update(user.toMap());
  }

  /// Chuyển đổi và lưu ảnh đại diện dưới dạng chuỗi Base64 trên Firestore (không cần Firebase Storage)
  FutureEither<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // 1. Đọc file dưới dạng bytes
      final bytes = await imageFile.readAsBytes();
      
      // Giới hạn kích thước ảnh đại diện tối đa là 1MB để tránh tràn dung lượng tài liệu Firestore
      if (bytes.length > 1024 * 1024) {
        return left(Failure('Kích thước ảnh đại diện quá lớn (tối đa 1MB). Vui lòng chọn ảnh khác.'));
      }

      // 2. Mã hóa thành chuỗi Base64
      final base64String = base64Encode(bytes);

      // 3. Cập nhật Firestore
      await _users.doc(userId).update({'profilePic': base64String});

      return right(base64String);
    } catch (e) {
      return left(Failure('Lỗi cập nhật ảnh đại diện: $e'));
    }
  }

  /// Đổi mật khẩu với Re-authentication
  FutureEither<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return left(Failure('Người dùng chưa đăng nhập.'));
      }

      // Bước 1: Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Bước 2: Cập nhật mật khẩu mới
      await user.updatePassword(newPassword);

      return right(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return left(Failure('Mật khẩu cũ không chính xác.'));
      }
      return left(Failure(_getFirebaseAuthErrorMessage(e.code)));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Cập nhật thông tin chi tiết (Name, Phone, Bio)
  FutureEither<void> updateProfile({
    required String uid,
    required String name,
    required String? phoneNumber,
    required String? bio,
  }) async {
    try {
      await _users.doc(uid).update({
        'name': name,
        'phoneNumber': phoneNumber,
        'bio': bio,
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }


  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) {
      if (!event.exists || event.data() == null) {
        // Return a basic model if the document doesn't exist yet
        return UserModel(
          uid: uid,
          email: '',
          isAuthenticated: false,
        );
      }
      return UserModel.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  Future<void> signout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
