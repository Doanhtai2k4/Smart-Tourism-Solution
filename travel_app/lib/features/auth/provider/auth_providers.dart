import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/failure.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/auth/repository/firebase_repository.dart';
import '../../../core/services/realtime_recommender_service.dart';
import '../models/user_model.dart';
part 'auth_providers.g.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
UserModel? userInfo(Ref ref) {
  final authState = ref.watch(authStateProvider);
  debugPrint('userInfoProvider: authState.value is ${authState.value?.uid}');
  return authState.value;
}

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
FirebaseStorage firebaseStorage(Ref ref) {
  return FirebaseStorage.instance;
}

@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

@riverpod
GoogleSignIn googleSignIn(Ref ref) {
  return GoogleSignIn();
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
}


@riverpod
Stream<UserModel> userData(Ref ref) {
  final user = ref.watch(userInfoProvider);
  if (user == null) throw Exception("User not logged in");
  return ref.read(authRepositoryProvider).getUserData(user.uid);
}

@riverpod
Stream<UserModel> anyUserData(Ref ref, String uid) {
  return ref.read(authRepositoryProvider).getUserData(uid);
}

@riverpod
Future<UserModel> anyUserFuture(Ref ref, String uid) async {
  return ref.read(authRepositoryProvider).getUserData(uid).first;
}

@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AsyncValue<UserModel?> build() {
    final authRepository = ref.watch(authRepositoryProvider);
    final firebaseUser = authRepository.auth.currentUser;
    debugPrint('AuthStateNotifier.build() called, firebaseUser: ${firebaseUser?.uid}');
    final authStateChange = authRepository.authStateChange;

    final sub = authStateChange.listen((firebaseUser) async {
      debugPrint(
        'AuthStateNotifier: authStateChange emitted: ${firebaseUser?.uid}',
      );

      if (firebaseUser == null) {
        if (state.value != null) {
          debugPrint('AuthStateNotifier: Setting state to null (sign out)');
          // Reset Recommender on sign out
          ref.read(realtimeRecommenderProvider.notifier).reset();
          state = const AsyncValue.data(null);
        }
      } else {
        // Only fetch if we don't have this user's data yet or it's currently null
        if (state.value == null || state.value?.uid != firebaseUser.uid) {
          debugPrint(
            'AuthStateNotifier: Fetching user data for ${firebaseUser.uid}',
          );
          try {
            final userData = await ref
                .read(authRepositoryProvider)
                .getUserData(firebaseUser.uid)
                .first;
            debugPrint(
              'AuthStateNotifier: Fetched user data: ${userData.name}',
            );
            
            // Load Real-time Recommender Profile from Cloud (Bulletproof)
            debugPrint('AuthStateNotifier: Triggering bulletproof profile init for ${firebaseUser.uid}');
            ref.read(realtimeRecommenderProvider.notifier).initProfile(firebaseUser.uid);
            
            state = AsyncValue.data(userData);
          } catch (e) {
            debugPrint('AuthStateNotifier: Error fetching user data: $e');
          }
        }
      }
    });

    ref.onDispose(() {
      debugPrint('AuthStateNotifier disposed');
      sub.cancel();
    });

    return const AsyncValue.data(null);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final result = await ref.read(authRepositoryProvider).signInWithGoogle();

      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (data) {
          final user = data.$1;
          
          state = AsyncValue.data(user);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signIn(String email, String password) async {
    debugPrint('AuthStateNotifier: signIn start for $email');
    state = const AsyncValue.loading();
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .signin(email, password);

      result.fold(
        (failure) {
          debugPrint('AuthStateNotifier: signIn failure: ${failure.message}');
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (user) {
          debugPrint('AuthStateNotifier: signIn success: ${user.uid}');
          state = AsyncValue.data(user);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('AuthStateNotifier: signIn exception: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .signup(email, password);

      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (user) {
          state = AsyncValue.data(user);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> saveUserProfile(UserModel user) async {
    state = const AsyncValue.loading();
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .saveUserProfile(user);

      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (_) async {
          // Get updated user data
          final userData = await ref
              .read(authRepositoryProvider)
              .getUserData(user.uid)
              .first;
          state = AsyncValue.data(userData);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void updateUserData(String name, String email) {
    final user = ref.read(userInfoProvider);
    if (user != null) {
      final updatedUser = user.copyWith(name: name, email: email);
      ref.read(authRepositoryProvider).updateUserData(updatedUser);
    }
  }

  void signOut() async {
    ref.read(authRepositoryProvider).signout();
  }

  /// Cập nhật ảnh đại diện
  Future<Either<Failure, String>> uploadProfileImage(File file) async {
    final user = state.value;
    if (user == null) return left(Failure('Người dùng chưa đăng nhập.'));

    final result = await ref.read(authRepositoryProvider).uploadProfileImage(file, user.uid);
    
    return result.fold(
      (failure) => left(failure),
      (url) {
        state = AsyncValue.data(user.copyWith(profilePic: url));
        return right(url);
      },
    );
  }

  /// Đổi mật khẩu
  Future<Either<Failure, void>> changePassword(String oldPassword, String newPassword) async {
    return ref.read(authRepositoryProvider).changePassword(
      oldPassword: oldPassword, 
      newPassword: newPassword,
    );
  }

  /// Cập nhật thông tin chi tiết
  Future<Either<Failure, void>> updateProfile({
    required String name,
    required String? phoneNumber,
    required String? bio,
  }) async {
    final user = state.value;
    if (user == null) return left(Failure('Người dùng chưa đăng nhập.'));

    final result = await ref.read(authRepositoryProvider).updateProfile(
      uid: user.uid,
      name: name,
      phoneNumber: phoneNumber,
      bio: bio,
    );

    return result.fold(
      (failure) => left(failure),
      (_) async {
        final updatedUser = await ref.read(authRepositoryProvider).getUserData(user.uid).first;
        state = AsyncValue.data(updatedUser);
        return right(null);
      },
    );
  }

}
