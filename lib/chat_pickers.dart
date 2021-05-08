library chat_pickers;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'src/emoji_picker/emoji_picker.dart';
import 'src/giphy_picker/giphy_picker.dart';
import 'src/hooks/use_page_controller.dart';
// import 'src/hooks/use_page_controller.dart';

export 'src/emoji_picker/emoji_picker.dart';
export 'src/giphy_picker/giphy_picker.dart';

class EmojiPickerConfig {
  /// Number of columns in keyboard grid
  final int? columns;

  /// The background color of the keyboard
  final Color? bgColor;

  /// The background color of the categories bar
  final Color? bgBarColor;

  /// The color of the keyboard page indicator
  final Color indicatorColor;

  /// A list of keywords that are used to provide the user with recommended emojis in [Category.RECOMMENDED]
  final List<String> recommendKeywords;

  /// The maximum number of emojis to be recommended
  final int? numRecommended;

  /// The string to be displayed if no recommendations found
  final String? noRecommendationsText;

  /// The text style for the [noRecommendationsText]
  final TextStyle? noRecommendationsStyle;

  /// The string to be displayed if no recent emojis to display
  final String? noRecentsText;

  /// The text style for the [noRecentsText]
  final TextStyle? noRecentsStyle;

  /// Determines the icon to display for each [Category]
  final CategoryIcons? categoryIcons;

  /// Determines the style given to the keyboard keys
//  final ButtonMode buttonMode;

  EmojiPickerConfig({
    this.columns,
    this.bgColor,
    this.bgBarColor,
    this.indicatorColor = Colors.white,
    this.recommendKeywords = const [],
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
  final String? rating;

  /// Language of searching gifs
  final String? lang;

  ///
  final Widget? title;

  ///
  final ErrorListener? onError;

  ///
  final bool? showPreviewPage;

  ///
  final String? searchText;

  ///
  Function(GiphyGif)? onSelected;

  GiphyPickerConfig(
      {required this.apiKey,
      this.rating,
      this.lang,
      this.title,
      this.onError,
      this.onSelected,
      this.showPreviewPage,
      this.searchText});
}

class ChatPickers extends HookWidget {
  final TextEditingController? chatController;
  final EmojiPickerConfig? emojiPickerConfig;
  final GiphyPickerConfig giphyPickerConfig;

  const ChatPickers(
      {Key? key,
      this.chatController,
      this.emojiPickerConfig,
      required this.giphyPickerConfig})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _tabSelected = useState<int>(0);
    PageController _pageController = useMyPageController(_tabSelected);

    Widget gifKeyboard() {
      return GiphyPicker.pickerGifWidget(
          context: context,
          apiKey: giphyPickerConfig.apiKey,
          onClose: () {},
          onSelected: (gif) {
            // todo: upload gif to chat
            ///_uploadGif(gif.images.original.url);

            giphyPickerConfig.onSelected!(gif);

            // show back keyboard
            FocusScope.of(context).unfocus(); //?
          });
    }

    Widget buildSticker() {
      return EmojiPicker(
        //context: context,
        rows: 150,
        columns: emojiPickerConfig!.columns,
        buttonMode: ButtonMode.MATERIAL,
        numRecommended: emojiPickerConfig!.numRecommended,
        bgBarColor: emojiPickerConfig!.bgBarColor,
        bgColor: emojiPickerConfig!.bgColor,
        indicatorColor: emojiPickerConfig!.indicatorColor,
        onEmojiSelected: (emoji, category) {
          // setState(() {
          chatController!.text += emoji.emoji!;
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
      color: emojiPickerConfig!.bgBarColor,
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
                      color: _tabSelected.value == 0
                          ? Colors.white
                          : Colors.grey[500],
                      icon: Icon(Icons.insert_emoticon),
                      onPressed: () {
                        _pageController.animateToPage(0,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.linear);
                      },
                    ),
                    IconButton(
                      color: _tabSelected.value == 1
                          ? Colors.white
                          : Colors.grey[500],
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
                  right: 35 / 4,
                  bottom: 35 / 4,
                  child: Column(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          child: Icon(
                            MdiIcons.backspace,
                            size: 18,
                            color: Colors.white,
                          ),
                          onTap: () {
                            try {
                              chatController!.text = chatController!.text
                                  .substring(0, chatController!.text.length - 2);
                            } catch (e) {
                              chatController!.clear();
                            }
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
