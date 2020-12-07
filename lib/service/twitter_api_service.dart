import 'dart:convert';

import 'package:ably_cryptocurrency/config.dart';
import 'package:twitter_api/twitter_api.dart';

class TwitterAPIService {
  TwitterAPIService({this.queryTag});

  final String queryTag;

  static const String path = "search/tweets.json";

// todo: What is the return type if this function? We won't do it like that twitter package and
// make everything dynamic
  getTweetsQuery() async {
    try {
      final _twitterOauth = new twitterApi(
        consumerKey: OAuthConsumerKey,
        consumerSecret: OAuthConsumerSercert,
        token: OAuthToken,
        tokenSecret: OAuthTokenSecret,
      );

// todo: The Twitter package is very sloppy in on defining a return type to its functions. In reallity
// the return type is a `Future<Response>` where Response is from the package http. We should use the correct
// return type even if that means we have to add the http package
      // Make the request to twitter
      Future twitterRequest = _twitterOauth.getTwitterRequest(
        // Http Method
        "GET",
        // Endpoint you are trying to reach
        path,
        // The options for the request
        options: {
          "q": queryTag,
        },
      );
// Possibly we should limit the amount of tweets that we can get returned. Probably that's something
// that can be set by using the options

      /// todo: why do you separate the wait from the call to the function above?
      final response = await twitterRequest;

      return json.decode(response.body);
    } catch (error) {
      rethrow;
    }
  }
}
