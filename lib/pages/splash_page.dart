// ignore_for_file: use_build_context_synchronously

import 'package:chat_app_by_supabase/pages/chat_page.dart';
import 'package:chat_app_by_supabase/pages/register_page.dart';
import 'package:chat_app_by_supabase/util/constants.dart';
import 'package:flutter/material.dart';

/// ログイン状態に応じてユーザーをリダイレクトするページ
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // widgetがmountするのを待つ
    await Future.delayed(Duration.zero);

    /// ログイン状態に応じて適切なページにリダイレクト
    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.of(context).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(ChatPage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
