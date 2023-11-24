// テストコード
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app_by_supabase/pages/chat_page.dart';

void main() {
  group('ChatPage', () {
    testWidgets('renders chat interface', (WidgetTester tester) async {
      // チャットページが正しく描画されることをテスト
      await tester.pumpWidget(ChatPage());
      expect(find.text('チャット'), findsOneWidget);
    });

    testWidgets('logs out when log out button is pressed', (WidgetTester tester) async {
      // ログアウトボタンが押されたときにログアウト処理が実行されることをテスト
      await tester.pumpWidget(ChatPage());
      await tester.tap(find.text('ログアウト'));
      await tester.pump();
      expect(find.text('ログアウト'), findsNothing);
    });

    testWidgets('sends message when send button is pressed', (WidgetTester tester) async {
      // メッセージ送信ボタンが押されたときにメッセージが送信されることをテスト
      await tester.pumpWidget(ChatPage());
      await tester.enterText(find.byType(TextFormField), 'Test message');
      await tester.tap(find.text('送信'));
      await tester.pump();
      expect(find.text('Test message'), findsOneWidget);
    });
  });
}
