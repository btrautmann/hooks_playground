import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_playground/src/sample_feature/sample_item.dart';

ValueNotifier<Response> useItems() {
  final response = useState(
    Response(
      List.empty(),
      () async => throw Exception(
        'Refetch called prior to successful call',
      ),
    ),
  );
  final refetch = useCallback(() async {
    final items = await _fetchItems().first;
    print('refetch setting items $items');
    response.value = Response(items, response.value.refetch);
  }, []);

  useEffect(() {
    final streamSubscription = _fetchItems().listen((event) {
      print('_fetchItems stream emitted $event');
      response.value = Response(event, refetch);
    }, onDone: () => print('DONE!'), onError: (_, __) => print('ERROR'));
    return streamSubscription.cancel;
  }, []);

  return response;
}

class Response {
  final List<SampleItem> items;
  final Future<void> Function() refetch;

  Response(this.items, this.refetch);
}

int _called = 0;

Stream<List<SampleItem>> _fetchItems() async* {
  await Future.delayed(const Duration(seconds: 1));
  print('_fetchItems stream yielding');
  yield _produceItems();
  while (true) {
    print('_fetchItems stream open');
    await Future.delayed(const Duration(seconds: 15));
  }
}

List<SampleItem> _produceItems() {
  _called++;
  return List.generate(_called, (index) => SampleItem(index));
}
