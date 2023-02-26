import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth/Model/user_model.dart';
import 'package:phone_auth/Screen/otp_screen.dart';
import 'package:phone_auth/Utilities/utili.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

//AuthProvider class
class AuthProvider extends ChangeNotifier {
  //sign in variable
  bool _isSignin = false;
  bool get isSignin => _isSignin;

  //loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  //userId
  String? _uid;
  String get uid => _uid!;

  //userModel
  UserModel? _userModel;
  UserModel get userModel => _userModel!;

  // Firebase functionality...
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSign();
  }

  //checkSignIn funct...
  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignin = s.getBool("is_signed") ?? false;
    notifyListeners();
  }

  //set signin
  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signed", true);
    _isSignin = true;
    notifyListeners();
  }

  //signing in with your phone
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => otpScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      e.message.toString();
    }
  }

  //verify otp
  void verifyotp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      //
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      //verifying user
      User? user = (await _firebaseAuth.signInWithCredential(creds)).user!;

      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      //error message
      showSnaskBar(
        context,
        e.message.toString(),
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  //DATABASE OPERATION
  Future<bool> checkingExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("Users").doc(_uid).get();

    if (snapshot.exists) {
      print('USER EXITS');
      return true;
    } else {
      print('NEW USER');
      return false;
    }
  }

  //saving user data in firebase
  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel, //from usermodel
    required File profilePic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      //storing it in firestore
      await storeFileToStorage("profilePic/$_uid", profilePic).then((value) {
        //from the model folder
        userModel.profilePic = value;
        userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        userModel.uid = _firebaseAuth.currentUser!.phoneNumber!;
      });
      _userModel = userModel;

      //uploading to database
      await _firebaseFirestore
          .collection("Users")
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        //
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnaskBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  //uploading img to firestorage
  Future<String> storeFileToStorage(String ref, File file) async {
    //uploading img to fireStore
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapShot = await uploadTask;
    String downloadUrl = await snapShot.ref.getDownloadURL();
    return downloadUrl;
  }

  //getting data from firestore
  Future getDataFromFireStore() async {
    await _firebaseFirestore
        .collection("Users")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModel = UserModel(
        name: snapshot['name'],
        email: snapshot['email'],
        bio: snapshot['bio'],
        profilePic: snapshot['profilePic'],
        createdAt: snapshot['createdAt'],
        phoneNumber: snapshot['phoneNumber'],
        uid: snapshot['uid'],
      );
      _uid = userModel.uid;
    });
  }

  //storing the data locally
  Future saveUserDataToSp() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("User_Model", jsonEncode(userModel.toMap()));
  }

  //getting the local storagw
  Future getdataFromSp() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("User_Model") ?? '';
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  //sign out user
  Future signOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignin = false;
    notifyListeners();
    s.clear();
  }
}
