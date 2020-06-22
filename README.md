# chat_pickers

A Flutter package that provides a Keyboard widget for using Emojis and gifs.

Heavily based on the awesome(!) packages:

[giphy_picker](https://pub.dev/packages/giphy_picker)<br>
[emoji_picker](https://pub.dev/packages/emoji_picker)

## Getting Started

For using the GIFs page you have to use GIPHY API key
You need to register an app at the [Giphy Developers Portal](https://developers.giphy.com/) in order to retrieve an API key.


To use the keyboard define the widget `ChatPickers`:
The minimum required is:
```dart
var picker = ChatPickers(
  chatController: _chatController,
  emojiPickerConfig: EmojiPickerConfig(
    //optional configure  (as below)
  ),
  giphyPickerConfig: GiphyPickerConfig(
      apiKey: "some API Key",
      // other optional configure (as below)
      
);
```

## Usage
If you want to have your own config, follow the below:

#### EmojiPickerConfig
configuration to customize the look& behaviour of the emoji page
```dart
EmojiPickerConfig(
    columns: <int>,     // default is 7
    bgBarColor: <Color>,    // top/bottom bar color
    bgColor:<Color>,
    indicatorColor: <Color>,
);
```

#### GiphyPickerConfig
configuration to customize the look & behaviour of the gif page
```dart
GiphyPickerConfig(
    apiKey: <Your Giphy API key>,
    lang : "EN",
    onError: (error) => print(error),
    onSelected: (gif) => sendGif(gif),
    showPreviewPage: true/false,
    searchText: "Search GIPHY"
   
);
```