library chat_pickers;

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'src/custom_icons.dart';
import 'src/emoji_picker/emoji_picker.dart';
import 'src/giphy_picker/giphy_picker.dart';


class EmojiPickerConfig {

  /// Number of columns in keyboard grid
  final int columns;

  /// The background color of the keyboard
  final Color bgColor;

  /// The background color of the categories bar
  final Color bgBarColor;

  /// The color of the keyboard page indicator
  final Color indicatorColor;

  /// A list of keywords that are used to provide the user with recommended emojis in [Category.RECOMMENDED]
  final List<String> recommendKeywords;

  /// The maximum number of emojis to be recommended
  final int numRecommended;

  /// The string to be displayed if no recommendations found
  final String noRecommendationsText;

  /// The text style for the [noRecommendationsText]
  final TextStyle noRecommendationsStyle;

  /// The string to be displayed if no recent emojis to display
  final String noRecentsText;

  /// The text style for the [noRecentsText]
  final TextStyle noRecentsStyle;

  /// Determines the icon to display for each [Category]
  final CategoryIcons categoryIcons;

  /// Determines the style given to the keyboard keys
//  final ButtonMode buttonMode;

  EmojiPickerConfig(
      {this.columns,
      this.bgColor,
      this.bgBarColor,
      this.indicatorColor,
      this.recommendKeywords,
      this.numRecommended,
      this.noRecommendationsText,
      this.noRecommendationsStyle,
      this.noRecentsText,
      this.noRecentsStyle,
      this.categoryIcons,
//      this.buttonMode,
      });
}

class GiphyPickerConfig {
  /// API key for interaction with the Giphy API
  final String apiKey;

  ///
  final String rating;

  /// Language of searching gifs
  final String lang;

  ///
  final Widget title;

  ///
  final ErrorListener onError;

  ///
  final bool showPreviewPage;

  ///
  final String searchText;

  GiphyPickerConfig(
      {@required this.apiKey,
      this.rating,
      this.lang,
      this.title,
      this.onError,
      this.showPreviewPage,
      this.searchText});
}

class ChatPickers extends StatefulWidget {
  final TextEditingController chatController;
  final EmojiPickerConfig emojiPickerConfig;
  final GiphyPickerConfig giphyPickerConfig;

  const ChatPickers(
      {Key key,
      this.chatController,
      this.emojiPickerConfig,
      this.giphyPickerConfig
      })
      : super(key: key);

  @override
  _ChatPickersState createState() => _ChatPickersState();
}

class _ChatPickersState extends State<ChatPickers>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  TabController _tabController;
  int _tabSelected = 0;
  bool _isKeyboardOpen = false;

  final _tabs = [
    Tab(icon: Icon(Icons.insert_emoticon)),
    Tab(icon: Icon(MdiIcons.gif)),
    //Tab(icon: Icon(MdiIcons.sticker)),
  ];

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController(keepPage: true);
    _pageController.addListener(() {
      setState(() {
        _tabSelected = _pageController.page.toInt();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    //_tabController.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget gifKeyboard() {
      return GiphyPicker.pickerGifWidget(
          context: context,
          apiKey: "q3KulxGCIKWrOU283I3xM3DWvMnO5zOV", //Constants.GIPHY_API_KEY,
          onClose: () {


          },
          onSelected: (gif) {
            // todo: upload gif to chat
            ///_uploadGif(gif.images.original.url);


            // show back keyboard
            FocusScope.of(context).unfocus(); //?
          });
    }

    Widget buildSticker() {
      return EmojiPicker(
        rows: 150,
        columns: widget.emojiPickerConfig.columns,
        buttonMode: ButtonMode.MATERIAL,
        recommendKeywords: widget.emojiPickerConfig.recommendKeywords,
        numRecommended: widget.emojiPickerConfig.numRecommended,
        bgBarColor: widget.emojiPickerConfig.bgBarColor,
        //Colors.black38,
        bgColor: widget.emojiPickerConfig.bgColor,
        indicatorColor: widget.emojiPickerConfig.indicatorColor,
        onEmojiSelected: (emoji, category) {
          // setState(() {
          widget.chatController.text += emoji.emoji;
          //});

          // print(_messageText);
        },
      );
    }

    final pages = [
      buildSticker(),
      gifKeyboard(),
//      Container(
//        child: Text("Stickers"),
//      )
    ];

    return Container(
      color: widget.emojiPickerConfig.bgBarColor,
      child: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: pages,
            ),
          ),
          Container(
            height: 35,
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      color:
                          _tabSelected == 0 ? Colors.white : Colors.grey[500],
                      icon: Icon(Icons.insert_emoticon),
                      onPressed: () {
                        _pageController.animateToPage(0,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.linear);
                      },
                    ),
                    IconButton(
                      color:
                          _tabSelected == 1 ? Colors.white : Colors.grey[500],
                      icon: Icon(MdiIcons.gif),
                      onPressed: () {
                        _pageController.animateToPage(1,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.linear);
                      },
                    ),
//                    IconButton(
//                      color:
//                          _tabSelected == 2 ? Colors.white : Colors.grey[500],
//                      icon: Icon(MdiIcons.sticker),
//                      onPressed: () {
//                        _pageController.animateToPage(2,
//                            duration: Duration(milliseconds: 200),
//                            curve: Curves.linear);
//                      },
//                    ),
                  ],
                ),

//              Container(
//                width: MediaQuery.of(context).size.width,
//                //padding: const EdgeInsets.symmetric(horizontal: 128.0),
//                child: Container(
//                  constraints: BoxConstraints.tight(Size(_tabs.length * 20.toDouble(), 40)),
//                  child: TabBar(
//                    unselectedLabelColor: Colors.grey[500],
//                    labelColor: Colors.white,
//                    tabs: _tabs,
//                    controller: _tabController,
//                    indicatorColor: Colors.white,
//                    indicatorWeight: 0.01,
//                    indicatorSize: TabBarIndicatorSize.label,
//                    ),
//                ),
//              ),
                Positioned(
                  right: 35/4,
                  bottom: 35/4,
                  child: Column(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          child: Icon(
                            CustomIcons.remove_char,
                            size: 18,
                            color: Colors.white,
                          ),
                          onTap: () {
                            if (widget.chatController.text.isNotEmpty)
                              widget.chatController.text =
                                  widget.chatController.text.substring(
                                      0, widget.chatController.text.length - 2);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
