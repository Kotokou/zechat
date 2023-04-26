import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zechat/configs/constants/firestore_constants.dart';

class UserChat {
  String id;
  String photoURL;
  String nickname;
  String aboutMe;
  String phoneNumber;

  UserChat({
    required this.id,
    required this.photoURL,
    required this.nickname,
    required this.aboutMe,
    required this.phoneNumber,
  });

  Map<String, String> toJson() {
    return {
      FirestoreConstants.id: id,
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.photoUrl: photoURL,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.phoneNumber: phoneNumber,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String nickname = "";
    String photoURL = "";
    String aboutMe = "";
    String phoneNumber = "";

    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}

    try {
      photoURL = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}

    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}

    try {
      phoneNumber = doc.get(FirestoreConstants.phoneNumber);
    } catch (e) {}

    return UserChat(
      id: doc.id,
      photoURL: photoURL,
      nickname: nickname,
      aboutMe: aboutMe,
      phoneNumber: phoneNumber,
    );
  }
}
