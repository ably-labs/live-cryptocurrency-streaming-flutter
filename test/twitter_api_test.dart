import 'package:ably_cryptocurrency/service/twitter_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test('Calling twitter API to get tweets', () async {
    final api = TwitterAPIService(queryTag: 'bitcoin');

    final  response = await api.getTweetsQuery();

    expect(response.statusCode, 200);
  });
}