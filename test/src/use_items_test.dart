import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_playground/src/use_items.dart';

void main() {
  testWidgets('useItems', (tester) async {
    await tester.runAsync(() async {
      final builder = HookBuilder(builder: (context) {
        final response = useItems();
        final items = response.value.items;
        print('builder called with items $items');
        final count = items.length;
        return MaterialApp(
          home: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(count.toString()),
              TextButton(
                onPressed: response.value.refetch,
                child: const Text('Refetch'),
              )
            ],
          ),
        );
      });

      await tester.pumpWidget(builder);
      final hookBuilder = find.byType(HookBuilder);

      // Initial item count is 0, we've built once but we have
      // a pending re-build because the Stream has emitted `1`
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      await Future.delayed(const Duration(seconds: 1));
      expect(hookBuilder.evaluate().single.dirty, isTrue);

      // Trigger a rebuild
      await tester.pump();

      // Now the 1 appears
      expect(find.text('1'), findsOneWidget);

      // Refetch, which leads to a rebuild being *needed* but not performed (yet)
      final button = find.text('Refetch');
      await tester.tap(button);
      await Future.delayed(const Duration(seconds: 1));
      expect(hookBuilder.evaluate().single.dirty, isTrue);

      // Trigger another frame
      await tester.pump();

      // Now the 1 is gone and 2 appears
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
