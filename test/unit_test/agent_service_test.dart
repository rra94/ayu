import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/agent_service.dart';

void main() {
  group('AgentSuggestion', () {
    test('has required fields', () {
      final s = AgentSuggestion(
        type: 'test',
        title: 'Test Title',
        message: 'Test message',
      );
      expect(s.type, 'test');
      expect(s.title, 'Test Title');
      expect(s.message, 'Test message');
      expect(s.actionLabel, isNull);
      expect(s.onAction, isNull);
    });

    test('supports optional action', () {
      final s = AgentSuggestion(
        type: 'test',
        title: 'Title',
        message: 'Msg',
        actionLabel: 'Do it',
        onAction: () {},
      );
      expect(s.actionLabel, 'Do it');
      expect(s.onAction, isNotNull);
    });
  });
}
