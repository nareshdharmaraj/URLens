// URLens widget tests
import 'package:flutter_test/flutter_test.dart';
import 'package:urlens/main.dart';

void main() {
  testWidgets('URLens app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const URLensApp());

    // Verify that home screen loads
    expect(find.text('URLens'), findsOneWidget);
    expect(find.text('Enter URL'), findsOneWidget);
  });
}
