//import 'dart:io';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:universal_io/io.dart';
import 'emoji_lists.dart' as emojiList;

import 'package:shared_preferences/shared_preferences.dart';

import 'search_emoji_widget.dart';

/// All the possible categories that [Emoji] can be put into
///
/// All [Category] are shown in the keyboard bottombar with the exception of [Category.RECOMMENDED]
/// which only displays when keywords are given
enum Category {
  RECOMMENDED,
  RECENT,
  SMILEYS,
  ANIMALS,
  FOODS,
  TRAVEL,
  ACTIVITIES,
  OBJECTS,
  SYMBOLS,
  FLAGS
}

/// Enum to alter the keyboard button style
enum ButtonMode {
  /// Android button style - gives the button a splash color with ripple effect
  MATERIAL,

  /// iOS button style - gives the button a fade out effect when pressed
  CUPERTINO
}

/// Callback function for when emoji is selected
///
/// The function returns the selected [Emoji] as well as the [Category] from which it originated
typedef void OnEmojiSelected(Emoji emoji, Category? category);

/// The Emoji Keyboard widget
///
/// This widget displays a grid of [Emoji] sorted by [Category] which the user can horizontally scroll through.
///
/// There is also a bottombar which displays all the possible [Category] and allow the user to quickly switch to that [Category]
class EmojiPicker extends StatefulWidget {
  /// Number of columns in keyboard grid
  final int? columns;

  /// Number of rows in keyboard grid
  final int rows;

  /// The function called when the emoji is selected
  final OnEmojiSelected onEmojiSelected;

  /// The background color of the keyboard
  final Color? bgColor;

  /// The background color of the categories bar
  final Color? bgBarColor;

  /// The color of the keyboard page indicator
  final Color indicatorColor;

  static const Color _defaultBgColor = const Color.fromRGBO(242, 242, 242, 1);

  /// The maximum number of emojis to be recommended
  final int? numRecommended;

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
  final ButtonMode buttonMode;

  EmojiPicker({
    Key? key,
    required this.onEmojiSelected,
    this.columns = 7,
    this.rows = 3,
    this.bgColor = _defaultBgColor,
    this.indicatorColor = Colors.blue,
    this.numRecommended = 10,
    this.noRecommendationsText = "No Recommendations",
    this.noRecommendationsStyle =
        const TextStyle(fontSize: 20, color: Colors.black26),
    this.noRecentsText = "No Recents",
    this.noRecentsStyle = const TextStyle(fontSize: 20, color: Colors.black26),
    this.categoryIcons = const CategoryIcons(),
    this.bgBarColor,
    this.buttonMode = ButtonMode.MATERIAL,
    //this.unavailableEmojiIcon,
  }) : super(key: key);

  @override
  _EmojiPickerState createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  static const platform = const MethodChannel("emoji_picker_flutter");

  /// The currently selected [Category]
  ///
  /// This [Category] will have its button in the bottombar darkened
  Category? selectedCategory;

  List<Widget> pages = [];
  List<String?> allNames = [];
  List<String?> allEmojis = [];
  List<String?> recentEmojis = [];

  Map<String, String?> smileyMap = Map();
  Map<String, String?> animalMap = Map();
  Map<String, String?> foodMap = Map();
  Map<String, String?> travelMap = Map();
  Map<String, String?> activityMap = Map();
  Map<String, String?> objectMap = Map();
  Map<String, String?> symbolMap = Map();
  Map<String, String?> flagMap = Map();

  bool loaded = false;

  /// A list of keywords that are used to provide the user with recommended emojis in [Category.RECOMMENDED]
  List<String> recommendKeywords = [];

  List<Widget> _recommendedPages = [];

  @override
  void initState() {
    super.initState();

//    if (selectedCategory == null) {
//      if (recommendKeywords == null) {
//        selectedCategory = Category.SMILEYS;
//      } else {
//        selectedCategory = Category.RECOMMENDED;
//      }
//    } else if (recommendKeywords == null &&
//        selectedCategory == Category.RECOMMENDED) {
//      selectedCategory = Category.SMILEYS;
//    }
    selectedCategory = Category.SMILEYS;

    updateEmojis().then((_) {
      loaded = true;
    });
  }

  Future<bool?> _isEmojiAvailable(String? emoji) async {
    if (Platform.isAndroid) {
      bool? isAvailable;
      try {
        isAvailable =
            await platform.invokeMethod("checkAvailability", {"emoji": emoji});
      } on PlatformException catch (_) {
        isAvailable = false;
      }
      return isAvailable;
    }

    return true;
  }

  Future<List<String?>> getRecentEmojis() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = "recents";
    recentEmojis = prefs.getStringList(key) ?? [];
    return recentEmojis;
  }

  void addRecentEmoji(Emoji emoji) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "recents";
    getRecentEmojis().then((_) {
      print("adding emoji");
      setState(() {
        recentEmojis.insert(0, emoji.name);
        prefs.setStringList(key, recentEmojis as List<String>);
      });
    });
  }

  Future<Map<String, String>?> getAvailableEmojis(
      Map<String, String> emoji) async {

    if (Platform.isAndroid) {
      Map<String, String>? filtered = {};
      var delimiter = '|';
      try {
        var entries = emoji.values.join(delimiter);
        var keys = emoji.keys.join(delimiter);
        var result = (await platform.invokeMethod<String>('checkAvailability',
            {'emojiKeys': keys, 'emojiEntries': entries})) as String;
        var resultKeys = result.split(delimiter);
        for (var i = 0; i < resultKeys.length; i++) {
          filtered[resultKeys[i]] = emoji[resultKeys[i]]!;
        }
      } on PlatformException catch (_) {
        filtered = null;
      }
      return filtered;
    } else {
      return emoji;
    }

    // Map<String, String?> newMap = Map<String, String?>();
    //
    // for (String key in map.keys) {
    //   bool isAvailable = await _isEmojiAvailable(map[key]) ?? false;
    //   if (isAvailable) {
    //     newMap[key] = map[key];
    //   }
    // }
    //
    // return newMap;
  }

  updateRecommededdEmojies() {
    List<Recommended> recommendedEmojis = [];
    _recommendedPages.clear();

    Widget recommedneedPageResults;
    if (recommendedEmojis.length != 0) {
      recommedneedPageResults = Container(
        color: widget.bgColor,
        child: GridView.count(
          shrinkWrap: true,
          primary: true,
          crossAxisCount: widget.columns!,
          children: List.generate(recommendedEmojis.length, (index) {
            if (index < recommendedEmojis.length) {
              switch (widget.buttonMode) {
                case ButtonMode.MATERIAL:
                  return Center(
                      child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        recommendedEmojis[index].emoji!,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      Recommended recommended = recommendedEmojis[index];
                      widget.onEmojiSelected(
                          Emoji(
                              name: recommended.name,
                              emoji: recommended.emoji),
                          selectedCategory);
                      addRecentEmoji(Emoji(
                          name: recommended.name, emoji: recommended.emoji));
                    },
                  ));

                case ButtonMode.CUPERTINO:
                  return Center(
                      child: CupertinoButton(
                    pressedOpacity: 0.4,
                    padding: EdgeInsets.all(0),
                    child: Center(
                      child: Text(
                        recommendedEmojis[index].emoji!,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    onPressed: () {
                      Recommended recommended = recommendedEmojis[index];
                      widget.onEmojiSelected(
                          Emoji(
                              name: recommended.name,
                              emoji: recommended.emoji),
                          selectedCategory);
                      addRecentEmoji(Emoji(
                          name: recommended.name, emoji: recommended.emoji));
                    },
                  ));
                default:
                  return Container();
              }
            } else {
              return Container();
            }
          }),
        ),
      );
    } else {
      recommedneedPageResults = Container(
          color: widget.bgColor,
          child: Center(
              child: Text(
            widget.noRecommendationsText,
            style: widget.noRecommendationsStyle,
          )));
    }
//      var recommedneedPage = Column(
//        children: <Widget>[
//          Expanded(child: recommedneedPageResults),
//         (onSearch: (keyword) {
//
//
////            updateRecommededdEmojies();
//          },)
//        ],
//      );

    _recommendedPages.add(Container(
        child: EmojiSearchView(
      allEmojis: allEmojis,
      allNames: allNames,
      numRecommended: widget.numRecommended,
      buttonMode: widget.buttonMode,
      onEmojiSelected: widget.onEmojiSelected,
      addRecentEmoji: addRecentEmoji,
      selectedCategory: selectedCategory,
      bgColor: widget.bgColor,
      columns: widget.columns,
    )));

    if (pages.isNotEmpty)
      setState(() {
        pages[0] = _recommendedPages[0];
      });
    else {
      pages.add(_recommendedPages[0]);
    }
  }

  Future updateEmojis() async {
    smileyMap = await getAvailableEmojis(emojiList.smileys)?? {};
    animalMap = await getAvailableEmojis(emojiList.animals)?? {};
    foodMap = await getAvailableEmojis(emojiList.foods)?? {};
    travelMap = await getAvailableEmojis(emojiList.travel)?? {};
    activityMap = await getAvailableEmojis(emojiList.activities) ?? {};
    objectMap = await getAvailableEmojis(emojiList.objects) ?? {};
    symbolMap = await getAvailableEmojis(emojiList.symbols) ?? {};
    flagMap = await getAvailableEmojis(emojiList.flags) ?? {};

    allNames.clear();
    allNames.addAll(smileyMap.keys);
    allNames.addAll(animalMap.keys);
    allNames.addAll(foodMap.keys);
    allNames.addAll(travelMap.keys);
    allNames.addAll(activityMap.keys);
    allNames.addAll(objectMap.keys);
    allNames.addAll(symbolMap.keys);
    allNames.addAll(flagMap.keys);

    allEmojis.addAll(smileyMap.values);
    allEmojis.addAll(animalMap.values);
    allEmojis.addAll(foodMap.values);
    allEmojis.addAll(travelMap.values);
    allEmojis.addAll(activityMap.values);
    allEmojis.addAll(objectMap.values);
    allEmojis.addAll(symbolMap.values);
    allEmojis.addAll(flagMap.values);

//    if (recommendKeywords != null) {
//      allNames.forEach((name) {
//        int numSplitEqualKeyword = 0;
//        int numSplitPartialKeyword = 0;
//
//        recommendKeywords.forEach((keyword) {
//          if (name.toLowerCase() == keyword.toLowerCase()) {
//            recommendedEmojis.add(_Recommended(
//                name: name, emoji: allEmojis[allNames.indexOf(name)], tier: 1));
//          } else {
//            List<String> splitName = name.split(" ");
//
//            splitName.forEach((splitName) {
//              if (splitName.replaceAll(":", "").toLowerCase() ==
//                  keyword.toLowerCase()) {
//                numSplitEqualKeyword += 1;
//              } else if (splitName
//                  .replaceAll(":", "")
//                  .toLowerCase()
//                  .contains(keyword.toLowerCase())) {
//                numSplitPartialKeyword += 1;
//              }
//            });
//          }
//        });
//
//        if (numSplitEqualKeyword > 0) {
//          if (numSplitEqualKeyword == name.split(" ").length) {
//            recommendedEmojis.add(_Recommended(
//                name: name, emoji: allEmojis[allNames.indexOf(name)], tier: 1));
//          } else {
//            recommendedEmojis.add(_Recommended(
//                name: name,
//                emoji: allEmojis[allNames.indexOf(name)],
//                tier: 2,
//                numSplitEqualKeyword: numSplitEqualKeyword,
//                numSplitPartialKeyword: numSplitPartialKeyword));
//          }
//        } else if (numSplitPartialKeyword > 0) {
//          recommendedEmojis.add(_Recommended(
//              name: name,
//              emoji: allEmojis[allNames.indexOf(name)],
//              tier: 3,
//              numSplitPartialKeyword: numSplitPartialKeyword));
//        }
//      });
//
//      recommendedEmojis.sort((a, b) {
//        if (a.tier < b.tier) {
//          return -1;
//        } else if (a.tier > b.tier) {
//          return 1;
//        } else {
//          if (a.tier == 1) {
//            if (a.name.split(" ").length > b.name.split(" ").length) {
//              return -1;
//            } else if (a.name.split(" ").length < b.name.split(" ").length) {
//              return 1;
//            } else {
//              return 0;
//            }
//          } else if (a.tier == 2) {
//            if (a.numSplitEqualKeyword > b.numSplitEqualKeyword) {
//              return -1;
//            } else if (a.numSplitEqualKeyword < b.numSplitEqualKeyword) {
//              return 1;
//            } else {
//              if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
//                return -1;
//              } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
//                return 1;
//              } else {
//                if (a.name.split(" ").length < b.name.split(" ").length) {
//                  return -1;
//                } else if (a.name.split(" ").length >
//                    b.name.split(" ").length) {
//                  return 1;
//                } else {
//                  return 0;
//                }
//              }
//            }
//          } else if (a.tier == 3) {
//            if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
//              return -1;
//            } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
//              return 1;
//            } else {
//              return 0;
//            }
//          }
//        }
//
//        return 0;
//      });
//
//      if (recommendedEmojis.length > widget.numRecommended) {
//        recommendedEmojis =
//            recommendedEmojis.getRange(0, widget.numRecommended).toList();
//      }
//
//      Widget recommedneedPageResults;
//      if (recommendedEmojis.length != 0) {
//        recommedneedPageResults = Container(
//          color: widget.bgColor,
//          child: GridView.count(
//            shrinkWrap: true,
//            primary: true,
//            crossAxisCount: widget.columns,
//            children: List.generate(recommendedEmojis.length, (index) {
//              if (index < recommendedEmojis.length) {
//                switch (widget.buttonMode) {
//                  case ButtonMode.MATERIAL:
//                    return Center(
//                        child: FlatButton(
//                      padding: EdgeInsets.all(0),
//                      child: Center(
//                        child: Text(
//                          recommendedEmojis[index].emoji,
//                          style: TextStyle(fontSize: 24),
//                        ),
//                      ),
//                      onPressed: () {
//                        _Recommended recommended = recommendedEmojis[index];
//                        widget.onEmojiSelected(
//                            Emoji(
//                                name: recommended.name,
//                                emoji: recommended.emoji),
//                            selectedCategory);
//                        addRecentEmoji(Emoji(
//                            name: recommended.name, emoji: recommended.emoji));
//                      },
//                    ));
//                    break;
//                  case ButtonMode.CUPERTINO:
//                    return Center(
//                        child: CupertinoButton(
//                      pressedOpacity: 0.4,
//                      padding: EdgeInsets.all(0),
//                      child: Center(
//                        child: Text(
//                          recommendedEmojis[index].emoji,
//                          style: TextStyle(fontSize: 24),
//                        ),
//                      ),
//                      onPressed: () {
//                        _Recommended recommended = recommendedEmojis[index];
//                        widget.onEmojiSelected(
//                            Emoji(
//                                name: recommended.name,
//                                emoji: recommended.emoji),
//                            selectedCategory);
//                        addRecentEmoji(Emoji(
//                            name: recommended.name, emoji: recommended.emoji));
//                      },
//                    ));
//
//                    break;
//                  default:
//                    return Container();
//                    break;
//                }
//              } else {
//                return Container();
//              }
//            }),
//          ),
//        );
//      }
//      else {
//        recommedneedPageResults = Container(
//            color: widget.bgColor,
//            child: Center(
//                child: Text(
//              widget.noRecommendationsText,
//              style: widget.noRecommendationsStyle,
//            )));
//      }
//      var recommedneedPage = Column(
//        children: <Widget>[
//          Expanded(child: recommedneedPageResults),
//          EmojiSearchView(onSearch: (keyword) {
//            setState(() {
//              print(keyword);
//              recommendKeywords = ["racing"];
//            });
//          },)
//        ],
//      );
//
//
//      recommendedPages.add(recommedneedPage);
//    }

    updateRecommededdEmojies();

    List<Widget> recentPages = [];
    recentPages.add(recentPage());

    List<Widget> smileyPages = [];

    smileyPages.add(Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns!,
        children: List.generate(smileyMap.values.toList().length, (index) {
          if (index < smileyMap.values.toList().length) {
            String? emojiTxt = smileyMap.values.toList()[index];

            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      emojiTxt!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: smileyMap.keys.toList()[index],
                            emoji: smileyMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      emojiTxt!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: smileyMap.keys.toList()[index],
                            emoji: smileyMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              default:
                return Container();
            }
          } else {
            return Container();
          }
        }),
      ),
    ));

    List<Widget> animalPages = [];

    animalPages.add(Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns!,
        children: List.generate(animalMap.values.toList().length, (index) {
          if (index < animalMap.values.toList().length) {
            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      animalMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: animalMap.keys.toList()[index],
                            emoji: animalMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      animalMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: animalMap.keys.toList()[index],
                            emoji: animalMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));

              default:
                return Container();
            }
          } else {
            return Container();
          }
        }),
      ),
    ));

    List<Widget> foodPages = [];

    foodPages.add(Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns!,
        children: List.generate(foodMap.values.toList().length, (index) {
          if (index < foodMap.values.toList().length) {
            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      foodMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: foodMap.keys.toList()[index],
                            emoji: foodMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      foodMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: foodMap.keys.toList()[index],
                            emoji: foodMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              default:
                return Container();
            }
          } else {
            return Container();
          }
        }),
      ),
    ));

    List<Widget> travelPages = [];

    travelPages.add(Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns!,
        children: List.generate(travelMap.values.toList().length, (index) {
          if (index < travelMap.values.toList().length) {
            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      travelMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: travelMap.keys.toList()[index],
                            emoji: travelMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      travelMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: travelMap.keys.toList()[index],
                            emoji: travelMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              default:
                return Container();
            }
          } else {
            return Container();
          }
        }),
      ),
    ));

    List<Widget> activityPages = [];

    activityPages.add(Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns!,
        children: List.generate(activityMap.values.toList().length, (index) {
          if (index < activityMap.values.toList().length) {
            String? emojiTxt = activityMap.values.toList()[index];

            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      activityMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: activityMap.keys.toList()[index],
                            emoji: activityMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      emojiTxt!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: activityMap.keys.toList()[index],
                            emoji: activityMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              default:
                return Container();
            }
          } else {
            return Container();
          }
        }),
      ),
    ));

    List<Widget> objectPages = [];

    objectPages.add(Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns!,
        children: List.generate(objectMap.values.toList().length, (index) {
          if (index < objectMap.values.toList().length) {
            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      objectMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: objectMap.keys.toList()[index],
                            emoji: objectMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      objectMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: objectMap.keys.toList()[index],
                            emoji: objectMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              default:
                return Container();
            }
          } else {
            return Container();
          }
        }),
      ),
    ));

    List<Widget> symbolPages = [];

    symbolPages.add(Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns!,
        children: List.generate(symbolMap.values.toList().length, (index) {
          if (index < symbolMap.values.toList().length) {
            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      symbolMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: symbolMap.keys.toList()[index],
                            emoji: symbolMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      symbolMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: symbolMap.keys.toList()[index],
                            emoji: symbolMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              default:
                return Container();
            }
          } else {
            return Container();
          }
        }),
      ),
    ));

    List<Widget> flagPages = [];

    flagPages.add(Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns!,
        children: List.generate(flagMap.values.toList().length, (index) {
          if (index < flagMap.values.toList().length) {
            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      flagMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: flagMap.keys.toList()[index],
                            emoji: flagMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: Text(
                      flagMap.values.toList()[index]!,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  onPressed: () {
                    widget.onEmojiSelected(
                        Emoji(
                            name: flagMap.keys.toList()[index],
                            emoji: flagMap.values.toList()[index]),
                        selectedCategory);
                  },
                ));
              default:
                return Container();
            }
          } else {
            return Container();
          }
        }),
      ),
    ));

//    pages.addAll(_recommendedPages);
    pages.addAll(recentPages);
    pages.addAll(smileyPages);
    pages.addAll(animalPages);
    pages.addAll(foodPages);
    pages.addAll(travelPages);
    pages.addAll(activityPages);
    pages.addAll(objectPages);
    pages.addAll(symbolPages);
    pages.addAll(flagPages);

    getRecentEmojis().then((_) {
      pages.removeAt(1);
      pages.insert(1, recentPage());
      setState(() {});
    });
  }

  Widget recentPage() {
    if (recentEmojis.length != 0) {
      return Container(
          color: widget.bgColor,
          child: GridView.count(
            shrinkWrap: true,
            primary: true,
            crossAxisCount: widget.columns!,
            children: List.generate(widget.rows * widget.columns!, (index) {
              if (index < recentEmojis.length) {
                switch (widget.buttonMode) {
                  case ButtonMode.MATERIAL:
                    return Center(
                        child: FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          allEmojis[allNames.indexOf(recentEmojis[index])]!,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      onPressed: () {
                        String? emojiName = recentEmojis[index];
                        widget.onEmojiSelected(
                            Emoji(
                                name: emojiName,
                                emoji: allEmojis[allNames.indexOf(emojiName)]),
                            selectedCategory);
                      },
                    ));
                  case ButtonMode.CUPERTINO:
                    return Center(
                        child: CupertinoButton(
                      pressedOpacity: 0.4,
                      padding: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          allEmojis[allNames.indexOf(recentEmojis[index])]!,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      onPressed: () {
                        String? emojiName = recentEmojis[index];
                        widget.onEmojiSelected(
                            Emoji(
                                name: emojiName,
                                emoji: allEmojis[allNames.indexOf(emojiName)]),
                            selectedCategory);
                      },
                    ));

                  default:
                    return Container();
                }
              } else {
                return Container();
              }
            }),
          ));
    } else {
      return Container(
          color: widget.bgColor,
          child: Center(
              child: Text(
            widget.noRecentsText,
            style: widget.noRecentsStyle,
          )));
    }
  }

  Widget defaultButton(CategoryIcon categoryIcon) {
    return SizedBox(
      width: MediaQuery.of(context).size.width /
          (recommendKeywords == null ? 9 : 10),
      height: MediaQuery.of(context).size.width /
          (recommendKeywords == null ? 9 : 10),
      child: Container(
        color: widget.bgColor,
        child: Center(
          child: Icon(
            categoryIcon.icon,
            size: 22,
            color: categoryIcon.color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController;

    int initialPageNumberByCategory(Category? category) {
      if (category == Category.RECOMMENDED) {
        return 0;
      } else if (category == Category.RECENT) {
        return 1;
      } else if (category == Category.SMILEYS) {
        return 1 + 1;
      } else if (category == Category.ANIMALS) {
        return 1 + 1 + 1;
      } else if (category == Category.FOODS) {
        return 1 + 1 + 1 + 1;
      } else if (category == Category.TRAVEL) {
        return 1 + 1 + 1 + 1 + 1;
      } else if (category == Category.ACTIVITIES) {
        return 1 + 1 + 1 + 1 + 1 + 1;
      } else if (category == Category.OBJECTS) {
        return 1 + 1 + 1 + 1 + 1 + 1 + 1;
      } else if (category == Category.SYMBOLS) {
        return 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1;
      } else if (category == Category.FLAGS) {
        return 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1;
      }
      return 0;
    }

    if (loaded) {
      pages.removeAt(1);
      pages.insert(1, recentPage());

      pageController = PageController(
          initialPage: initialPageNumberByCategory(selectedCategory));

      pageController.addListener(() {
        setState(() {});
      });

      CategoryIcon categoryIconByIndex(Category c) {
        switch (c) {
          case Category.RECOMMENDED:
            return widget.categoryIcons.recommendationIcon;
          case Category.RECENT:
            return widget.categoryIcons.recentIcon;
          case Category.SMILEYS:
            return widget.categoryIcons.smileyIcon;
          case Category.ANIMALS:
            return widget.categoryIcons.animalIcon;
          case Category.FOODS:
            return widget.categoryIcons.foodIcon;
          case Category.TRAVEL:
            return widget.categoryIcons.travelIcon;
          case Category.ACTIVITIES:
            return widget.categoryIcons.activityIcon;
          case Category.OBJECTS:
            return widget.categoryIcons.objectIcon;
          case Category.SYMBOLS:
            return widget.categoryIcons.symbolIcon;
          case Category.FLAGS:
            return widget.categoryIcons.flagIcon;
          default:
            return widget.categoryIcons.recentIcon;
        }
      }

      var children = Category.values.map((categoryValue) {
        return SizedBox(
          width: MediaQuery.of(context).size.width /
              (recommendKeywords == null ? 9 : 10),
          height: MediaQuery.of(context).size.width /
              (recommendKeywords == null ? 9 : 10),
          child: widget.buttonMode == ButtonMode.MATERIAL
              ? FlatButton(
                  padding: EdgeInsets.all(0),
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          categoryIconByIndex(categoryValue).icon,
                          //widget.categoryIcons.recentIcon.icon,
                          size: 22,
                          color: selectedCategory ==
                                  categoryValue //Category.RECENT
                              ? widget.indicatorColor
                              : widget.categoryIcons.recentIcon.color,
                        ),
                        SizedBox(height: 6),
                        Container(
                          color: selectedCategory == categoryValue
                              ? widget.indicatorColor
                              : Colors.transparent,
                          height: 2,
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    if (selectedCategory == categoryValue) {
                      //Category.RECENT) {
                      return;
                    }

                    pageController
                        .jumpToPage(initialPageNumberByCategory(categoryValue));
                  },
                )
              : CupertinoButton(
                  pressedOpacity: 0.4,
                  padding: EdgeInsets.all(0),
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                  child: Center(
                    child: Icon(
                      widget.categoryIcons.recentIcon.icon,
                      size: 22,
                      color: selectedCategory == categoryValue //Category.RECENT
                          ? widget.indicatorColor
                          : widget.categoryIcons.recentIcon.color,
                    ),
                  ),
                  onPressed: () {
                    if (selectedCategory == categoryValue) {
                      //Category.RECENT) {
                      return;
                    }

                    pageController
                        .jumpToPage(initialPageNumberByCategory(categoryValue));
                  },
                ),
        );
      }).toList();

      return Column(
        children: <Widget>[
          Container(
            color: widget.bgBarColor,
            child: Row(children: children),
          ),
          Expanded(
//            height: (MediaQuery.of(context).size.width / widget.columns) *
//                widget.rows - 30,
//            width: MediaQuery.of(context).size.width,
            child: PageView(
                children: pages,
                controller: pageController,
                onPageChanged: (index) {
                  if (recommendKeywords != null && index < 1) {
                    selectedCategory = Category.RECOMMENDED;
                  } else if (index < 1 + 1) {
                    selectedCategory = Category.RECENT;
                  } else if (index < 1 + 1 + 1) {
                    selectedCategory = Category.SMILEYS;
                  } else if (index < 1 + 1 + 1 + 1) {
                    selectedCategory = Category.ANIMALS;
                  } else if (index < 1 + 1 + 1 + 1 + 1) {
                    selectedCategory = Category.FOODS;
                  } else if (index < 1 + 1 + 1 + 1 + 1 + 1) {
                    selectedCategory = Category.TRAVEL;
                  } else if (index < 1 + 1 + 1 + 1 + 1 + 1 + 1) {
                    selectedCategory = Category.ACTIVITIES;
                  } else if (index < 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1) {
                    selectedCategory = Category.OBJECTS;
                  } else if (index < 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1) {
                    selectedCategory = Category.SYMBOLS;
                  } else {
                    selectedCategory = Category.FLAGS;
                  }
                }),
          ),
        ],
      );
    } else {
      return Container(
        color: widget.bgColor,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

class Recommended {
  final String? name;
  final String? emoji;
  final int? tier;
  final int numSplitEqualKeyword;
  final int numSplitPartialKeyword;

  Recommended(
      {this.name,
      this.emoji,
      this.tier,
      this.numSplitEqualKeyword = 0,
      this.numSplitPartialKeyword = 0});
}

/// Class that defines the icon representing a [Category]
class CategoryIcon {
  /// The icon to represent the category
  final IconData icon;

  /// The default color of the icon
  final Color color;

  /// The color of the icon once the category is selected
  final Color selectedColor;

  const CategoryIcon({
    required this.icon,
    this.color = const Color.fromRGBO(178, 178, 178, 1),
    this.selectedColor = Colors.white,
  });
}

/// Class used to define all the [CategoryIcon] shown for each [Category]
///
/// This allows the keyboard to be personalized by changing icons shown.
/// If a [CategoryIcon] is set as null or not defined during initialization, the default icons will be used instead
class CategoryIcons {
  /// Icon for [Category.RECOMMENDED]
  final CategoryIcon recommendationIcon;

  /// Icon for [Category.RECENT]
  final CategoryIcon recentIcon;

  /// Icon for [Category.SMILEYS]
  final CategoryIcon smileyIcon;

  /// Icon for [Category.ANIMALS]
  final CategoryIcon animalIcon;

  /// Icon for [Category.FOODS]
  final CategoryIcon foodIcon;

  /// Icon for [Category.TRAVEL]
  final CategoryIcon travelIcon;

  /// Icon for [Category.ACTIVITIES]
  final CategoryIcon activityIcon;

  /// Icon for [Category.OBJECTS]
  final CategoryIcon objectIcon;

  /// Icon for [Category.SYMBOLS]
  final CategoryIcon symbolIcon;

  /// Icon for [Category.FLAGS]
  final CategoryIcon flagIcon;

  const CategoryIcons(
      {this.recommendationIcon = const CategoryIcon(icon: Icons.search),
      this.recentIcon = const CategoryIcon(icon: Icons.access_time),
      this.smileyIcon = const CategoryIcon(icon: Icons.tag_faces),
      this.animalIcon = const CategoryIcon(icon: Icons.pets),
      this.foodIcon = const CategoryIcon(icon: Icons.fastfood),
      this.travelIcon = const CategoryIcon(icon: Icons.location_city),
      this.activityIcon = const CategoryIcon(icon: Icons.directions_run),
      this.objectIcon = const CategoryIcon(icon: Icons.lightbulb_outline),
      this.symbolIcon = const CategoryIcon(icon: Icons.euro_symbol),
      this.flagIcon = const CategoryIcon(icon: Icons.flag)});
}

/// A class to store data for each individual emoji
class Emoji {
  /// The name or description for this emoji
  final String? name;

  /// The unicode string for this emoji
  ///
  /// This is the string that should be displayed to view the emoji
  final String? emoji;

  Emoji({required this.name, required this.emoji});

  @override
  String toString() {
    return "Name: " + name! + ", Emoji: " + emoji!;
  }
}
