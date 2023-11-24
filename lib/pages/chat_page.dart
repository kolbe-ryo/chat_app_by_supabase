import 'package:chat_app_by_supabase/model/message.dart';
import 'package:chat_app_by_supabase/model/profile.dart';
import 'package:chat_app_by_supabase/pages/register_page.dart';
import 'package:chat_app_by_supabase/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:postgrest/postgrest.dart';

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

  /// プロフィール情報をメモリー内にキャッシュしておくための変数
  final Map<String, Profile> _profileCache = {};

  @override
  void initState() {
    final userId = supabase.auth.currentUser!.id;
    _messageStream = supabase
        .from(messageTableName)
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
        actions: [
          TextButton(
            onPressed: () {
              supabase.auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
            },
            child: Text(
              'ログアウト',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          )
        ],
      ),
      body: StreamBuilder<List<Message>>(
        stream: _messageStream,
        builder: (context, snapShot) {
          if (snapShot.hasData) {
            final messages = snapShot.data!;
            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(
                          child: Text('早速メッセージを送ってみよう！'),
                        )
                      : ListView.builder(
                          reverse: true, // 新しいメッセージが下に来るように表示順を上下逆にする
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _ChatBubble(message: message);
                          },
                        ),
                ),
                const _MessageBar(),
              ],
            );
          } else {
            return preloader;
          }
        },
      ),
    );
  }
}

class _MessageBar extends StatefulWidget {
  const _MessageBar();

  @override
  State<_MessageBar> createState() => __MessageBarState();
}

class __MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[200],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  maxLines: null, // 複数行入力可能にする
                  autofocus: true, // ページを開いた際に自動的にフォーカスする
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'メッセージを入力',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _submitMessage(),
                child: const Text('送信'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitMessage() async {
    final text = _textEditingController.text;
    final myUserId = supabase.auth.currentUser!.id;
    if (text.isEmpty) {
      // 入力された文字がなければ何もしない
      return;
    }
    _textEditingController.clear();

    try {
      await supabase.from(messageTableName).insert({
        'profile_id': myUserId,
        'content': text,
      });
    } on PostgrestException catch (e) {
      context.showErrorSnackBar(message: e.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.profile,
  });

  final Message message;
  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    return Text(message.content);
  }
}
