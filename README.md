# Flutter Ably Cryptocurrency

This is a FinTech sample application that uses [Coindesk](https://www.ably.io/hub/ably-coindesk/bitcoin) Hub provided by [Ably](https://www.ably.io) to read cryptocurrencyprice changes on realtime.

The app has the following features:
1. Dashboard with realtime graphs for cyptocurrencies prices.
2. Public chat room.
3. Clicking on a currency name would bring up recent tweets on its hashtag.

## Getting Started

This project is a real example on how to use the [Ably Flutter SDK](https://pub.dev/packages/ably_flutter_plugin). To get started:
1. [Signup](https://www.ably.io) to get your Aply API Key.
2. Singup for a a [Twitter Developer account](https://developer.twitter.com), note that you won't be able to see any tweets if you don't have valid keys for Twitter's API.
3. Clone the project.
4. Make sure you have installed Flutter on your machine.
5. Add your keys to `[config_example.dart](lib/config_example.dart)`, and change its name to `config.dart`.
6. For Android, the `minSdkVersion` has been set to `24` as required by Ably's Flutter SDK.
7. Run the app.

## App Screenshots

[realtime dashboard](preview_images/dashboard.gif) [public chat room](preview_images/chat.gif) [twitter feed](preview_images/twitter.gif)

For help getting started with Flutter:
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
