import 'dart:convert';
import 'dart:io';

import 'package:ably_cryptocurrency/config_example.dart';
import 'package:http/http.dart' as http;

class TwitterAPIService {
  TwitterAPIService({this.queryTag});

  final String queryTag;

  static const String host = "api.twitter.com";
  static const String path = "/1.1/search/tweets.json";

  Uri _twitterSearchUri(String query) => Uri(
        scheme: 'https',
        host: host,
        path: path,
        queryParameters: {'q': '$query'},
      );

  getTweetsQuery() async {
    String query = _twitterSearchUri(queryTag).toString();
    String timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toString();
    String authHeader =
        'OAuth oauth_consumer_key="$OAuthConsumerKey", oauth_nonce="$OAuthConsumerSercert", oauth_signature="OAUTH_SIGNATURE", oauth_signature_method="HMAC-SHA1", oauth_timestamp="$timestamp", oauth_token="$OAuthToken", oauth_version="1.0"';

    http.Response response = await http.get('$query', headers: {HttpHeaders.authorizationHeader: '$authHeader'});

    final decodedResponse = json.decode(response.body);

    return decodedResponse;
  }
}
