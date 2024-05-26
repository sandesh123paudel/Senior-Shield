import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

import '../models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:seniorshield/models/user_model.dart';

import 'notification_access_token.dart';


class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

//for accessing the cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static get user => auth.currentUser!;

  static FirebaseStorage storage = FirebaseStorage.instance;


  static FirebaseMessaging fMessaging=FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async{
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t){
      if(t!=null)
        {

          me.pushToken=t;
          log("Push token: $t");

        }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }


  static Future<void> sendPushNotification(UserModel user, String msg) async {

    try {

      final body = {
        "message": {
          "token": user.pushToken,
          "notification": {
            "title": me.fullName,
            "body": msg,
          },
        }
      };

      const projectID = 'seniorshieldapp-a65aa';
      final bearerToken = await NotificationAccessToken.getToken;

      log('bearerToken: $bearerToken');

      // Handle null token
      if (bearerToken == null) return;

      var res = await post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }




  //for storing self info
  static late UserModel me;

  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = UserModel.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        await APIs.updateActiveStatus(true);
      } else {}
    });
  }

  //getting all users from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String>userIds) {
    return firestore
        .collection("users")
    .where('uid',whereIn: userIds.isEmpty?['']:userIds)
        // .where('uid', isNotEqualTo: user.uid)
        .snapshots();
  }


  static Future<void> sendFirstMessage(UserModel chatUser, String msg, Type type) async {

    firestore.collection('users').doc(chatUser.uid.toString()).collection('my_users').doc(user.uid).set({}).then((value) => sendMessage(chatUser, msg, type));

  }




  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection("users")
    .doc(user.uid)
    .collection('my_users')
        .snapshots();
  }

  static Future<void> updateProfilePicture(File file) async {
    // Ensure 'me' is initialized
    await getSelfInfo();

    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //get conversation id

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //Chat Screen Apis

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      UserModel user) {
    return firestore
        .collection("chats/${getConversationID(user.uid.toString())}/messages/")
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //for sending message

  static Future<void> sendMessage(
      UserModel chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        msg: msg,
        read: '',
        toId: chatUser.uid.toString(),
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore.collection(
        'chats/${getConversationID(chatUser.uid.toString())}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser,type==Type.text?msg:'Image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent.toString())
        .update({'read': time});
  }

  //last message of chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      UserModel user) {
    return firestore
        .collection("chats/${getConversationID(user.uid.toString())}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(UserModel chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.uid.toString())}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      UserModel chatUser) {
    return firestore
        .collection('users')
        .where('uid', isEqualTo: chatUser.uid)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken // Use '!' since we've checked for nullity
    });
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
       firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id).set({});
      return true;
    } else {
      return false;
    }
  }


  static Future<void> updateUserData(UserModel updatedUser) async {
    try {
      await firestore.collection('users').doc(user.uid).update(updatedUser.toJson());
      print('User data updated successfully');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }


}
