import 'dart:convert';
import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        jsonDecode(r'''
{
  "type": "service_account",
  "project_id": "seniorshieldapp-a65aa",
  "private_key_id": "ffb4787db34041890dbdd43bac9ccedccd77091f",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDZYf2V5jOB33Hn\n1s3tZ+n4FHjhwNWcEP5uLazXiSgjZeS3T7Fd8LoJ+4YaxJzeIoDYODNKJOcfc0Dl\nVNnqErvzDLlvOf42uPZuD+LTobsGyi3/ChMSGGLwvAKo7f7G9MzdMgz8Jjn8FVBs\nkAc3/kiimBKdSzCfDI3ofEZX4X7GrPQX81X2M9l/MeYCv2kOW2dA3OeMh8VpJTHr\nYTlgKPWmcDgK8MaoUqHZf6yDmNGGPKr7LzSDrC4y0pS6ZqAEAKrKHIScVZjh8myQ\nevnJSYlZSAGVOVdzVj2pqnzBunt6ogLLZeHkK1DWO6fPusNzzRQoLgTSLTShH9YJ\nvILx+wNxAgMBAAECggEADQAyydXAK9rAtbRfkXy+/fK/fgTp4ZEUnmNF7IgL6f4M\njTgLbApbHgC4dv5eQVy/5u6JhrwpRHTAo1aNR9YB/pm6t1+5B+3M8y0pDC4mgNPz\np0ajeFgUBsC/yfmd3KlEXVBCfYwNuLlPm4aLn/opvuuoZVbbXA/EpuxTyqq2Scxu\n7gtnLBY1yrYi74KKs834cApkvp658tEKxq5P1UL2X4myqy7gLzUCKzhjwfukr2qS\nOVx6WuSUaIr+Tmbx07gRNN+MtQbexZRlaANxn1igXD3/Fj5i42QN0Ta1C84wxz0b\nEgt+6nudhqvQklsN7ydFGaL2GdnuVd1IjLbvcwMJzwKBgQD8uGrI/eMxHBVlLW18\nGSxx39hLvWYdbtxfx3rtp9+S1F32vdNgrPdUTi0yUl9nwox0dCCL6UlsKN+NFavw\ny8CrE8FRcbeKandOWJv+5QN2zTA7a0HMGF6KCCy3GNcXxhW8O/uMtylCMfoBK21D\nVLGZsexVt8uwNpNe3Ionm4N4PwKBgQDcNCzu2CfHYkyyGn1QLjEQvrj9D7q3UuJW\nIE0yomMUFYD7dId6SgxH0HQl+kTEUapK+bQeX5tmCRLyIRJSTJoz98B/UXEZxPcv\nCulr5j/jAcQma/gO6cgKjABRmFklXgONYkdcAKhQhnNnmiu2xrDeXdMwZ75qNLBt\nP7befh0YTwKBgQCWLIBIL5Zx+F4+YWBN/ieLA5lkaIfltZr+z2sdDkSs28V6ehLB\nwAa48jupS4ml/tW33cn5WgdnXmJ5VAd4b5tuDa8y1oBaoCmFROJt9Wi5j/S5WmMf\nBNwo6fKoWvp2Bh+kW4B/fdfmngwR5dxnxkxDKJdn2HARplysYiE2qBLXwQKBgFep\nhcHH134uie3VUdHbsbjC1I4Z9vEIVAaJcXIY52yVavWv3Ec4t07Xk4WS7lFhWXPj\nmGsHEKw8LIir1clhqXnKxZ1p5KannOfjZi2ISiKrD1VkYio9s19PgMj653JSzQM5\n/sKHmHoGLGcwHvryenLr0ylQA6PwOdQkKz7D4f1NAoGAS0gS3K+j6437cU2OI9R8\nH10D0BRp40lJJJeuPPrSi9ZqFbtQHfoF/pCsYhWZbn6svMKp9cS/wQIVf++TyOWg\nvRE/iwzJy7IxsmUD0nO5F73BZav3qopMrfdXkaAz0FdlJOBU2UYyYMDv5B941IV3\nZGg+o5/9hiXEE8TMwsp0Ans=\n-----END PRIVATE KEY-----",
  "client_email": "firebase-adminsdk-elhl4@seniorshieldapp-a65aa.iam.gserviceaccount.com",
  "client_id": "114539601697943318525",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-elhl4%40seniorshieldapp-a65aa.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
'''),
      );

      final client = await clientViaServiceAccount(
        serviceAccountCredentials,
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}