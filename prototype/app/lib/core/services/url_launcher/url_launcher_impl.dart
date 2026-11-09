import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studio_app/core/services/url_launcher/url_launcher.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherImpl implements UrlLauncher {
  @override
  Future<void> launchExternalAppUrl(String url) async {
    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> sendWppMessage(String number, {String? message}) async {
    final Uri link;

    if (Platform.isAndroid) {
      link = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: number,
        queryParameters: message != null ? {'text': message} : null,
      );
    } else {
      link = Uri(
        scheme: 'https',
        host: 'api.whatsapp.com',
        path: 'send',
        queryParameters: {
          'phone': number,
          if (message != null) 'text': message
        },
      );
    }

    try {
      await launchUrl(link, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> redirectToStore() async {
    try {
      // CHANGE APP ID'S
      return await StoreRedirect.redirect(
        iOSAppId: '123456',
        androidAppId: 'com.example.flutterMvvmLeap',
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
