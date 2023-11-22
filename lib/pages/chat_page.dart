import 'package:chat_app_by_supabase/model/message.dart';
import 'package:chat_app_by_supabase/util/constants.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final Stream<List<Message>> _messageStream;

  @override
  void initState() {
    final userId = supabase.auth.currentUser!.id;
    _messageStream = supabase
        .from('message')
        .stream(
          primaryKey: ['id'],
        )
        .order('created_at')
        .map((maps) {
          return maps.map((map) => Message.fromMap(map: map, myUserId: userId)).toList();
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
