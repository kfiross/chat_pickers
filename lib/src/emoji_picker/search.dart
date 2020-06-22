import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'emoji_picker.dart';

/// Provides the UI for searching emojies.
class EmojiSearchView extends StatefulWidget {
  final Function onClose;
  final Function(String) onSearch;
  final Function onEmojiSelected;
  final Function addRecentEmoji;

  final int numRecommended;

  final List<String> allNames;
  final List<String> allEmojis;

  final buttonMode;

  final selectedCategory;

  final int columns;

  final Color bgColor;

  const EmojiSearchView({Key key, this.onClose, this.onSearch, this.allNames, this.allEmojis, this.buttonMode, this.numRecommended = 10, this.onEmojiSelected, this.addRecentEmoji, this.selectedCategory, this.columns, this.bgColor}) : super(key: key);

  @override
  _EmojiSearchViewState createState() => _EmojiSearchViewState();


}

class _EmojiSearchViewState extends State<EmojiSearchView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _repoController = StreamController<List>();

  List<Recommended> recommendedEmojis = [];

  @override
  void initState() {
    // initiate search on next frame (we need context)
    Future.delayed(Duration.zero, () {
      //_search();
    });

    super.initState();
  }

  @override
  void dispose() {
    _repoController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Container(
      child: Column(
        children: <Widget>[
          Expanded(child: _results()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              style: TextStyle(color: Colors.white),
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Search Emojies",
                hintStyle: TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(Icons.keyboard, color: Colors.white,),
                  onPressed: widget.onClose,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _search(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _search(String t){
    recommendedEmojis.clear();

    var recommendKeywords = [t];

    if(t.isEmpty)
      return;

    widget.allNames.forEach((name) {
      int numSplitEqualKeyword = 0;
      int numSplitPartialKeyword = 0;

      recommendKeywords.forEach((keyword) {
        if (name.toLowerCase() == keyword.toLowerCase()) {
          recommendedEmojis.add(Recommended(
              name: name, emoji: widget.allEmojis[widget.allNames.indexOf(name)], tier: 1));
        } else {
          List<String> splitName = name.split(" ");

          splitName.forEach((splitName) {
            if (splitName.replaceAll(":", "").toLowerCase() ==
                keyword.toLowerCase()) {
              numSplitEqualKeyword += 1;
            } else if (splitName
                .replaceAll(":", "")
                .toLowerCase()
                .contains(keyword.toLowerCase())) {
              numSplitPartialKeyword += 1;
            }
          });
        }
      });

      if (numSplitEqualKeyword > 0) {
        if (numSplitEqualKeyword == name.split(" ").length) {
          recommendedEmojis.add(Recommended(
              name: name, emoji: widget.allEmojis[widget.allNames.indexOf(name)], tier: 1));
        } else {
          recommendedEmojis.add(Recommended(
              name: name,
              emoji: widget.allEmojis[widget.allNames.indexOf(name)],
              tier: 2,
              numSplitEqualKeyword: numSplitEqualKeyword,
              numSplitPartialKeyword: numSplitPartialKeyword));
        }
      } else if (numSplitPartialKeyword > 0) {
        recommendedEmojis.add(Recommended(
            name: name,
            emoji: widget.allEmojis[widget.allNames.indexOf(name)],
            tier: 3,
            numSplitPartialKeyword: numSplitPartialKeyword));
      }
    });

    recommendedEmojis.sort((a, b) {
      if (a.tier < b.tier) {
        return -1;
      } else if (a.tier > b.tier) {
        return 1;
      } else {
        if (a.tier == 1) {
          if (a.name.split(" ").length > b.name.split(" ").length) {
            return -1;
          } else if (a.name.split(" ").length < b.name.split(" ").length) {
            return 1;
          } else {
            return 0;
          }
        } else if (a.tier == 2) {
          if (a.numSplitEqualKeyword > b.numSplitEqualKeyword) {
            return -1;
          } else if (a.numSplitEqualKeyword < b.numSplitEqualKeyword) {
            return 1;
          } else {
            if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
              return -1;
            } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
              return 1;
            } else {
              if (a.name.split(" ").length < b.name.split(" ").length) {
                return -1;
              } else if (a.name.split(" ").length >
                  b.name.split(" ").length) {
                return 1;
              } else {
                return 0;
              }
            }
          }
        } else if (a.tier == 3) {
          if (a.numSplitPartialKeyword > b.numSplitPartialKeyword) {
            return -1;
          } else if (a.numSplitPartialKeyword < b.numSplitPartialKeyword) {
            return 1;
          } else {
            return 0;
          }
        }
      }

      return 0;
    });

    if (recommendedEmojis.length > widget.numRecommended) {
      recommendedEmojis =
          recommendedEmojis.getRange(0, widget.numRecommended).toList();
    }
  }

  Widget _results() {
    return Container(
      color: widget.bgColor,
      child: GridView.count(
        shrinkWrap: true,
        primary: true,
        crossAxisCount: widget.columns,
        children: List.generate(recommendedEmojis.length, (index) {
          if (index < recommendedEmojis.length) {
            switch (widget.buttonMode) {
              case ButtonMode.MATERIAL:
                return Center(
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          recommendedEmojis[index].emoji,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      onPressed: () {
                        Recommended recommended = recommendedEmojis[index];
                        widget.onEmojiSelected(
                            Emoji(
                                name: recommended.name,
                                emoji: recommended.emoji),
                            widget.selectedCategory);
                        widget.addRecentEmoji(Emoji(
                            name: recommended.name, emoji: recommended.emoji));
                      },
                    ));
                break;
              case ButtonMode.CUPERTINO:
                return Center(
                    child: CupertinoButton(
                      pressedOpacity: 0.4,
                      padding: EdgeInsets.all(0),
                      child: Center(
                        child: Text(
                          recommendedEmojis[index].emoji,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      onPressed: () {
                        Recommended recommended = recommendedEmojis[index];
                        widget.onEmojiSelected(
                            Emoji(
                                name: recommended.name,
                                emoji: recommended.emoji),
                            widget.selectedCategory);
                        widget.addRecentEmoji(Emoji(
                            name: recommended.name, emoji: recommended.emoji));
                      },
                    ));

                break;
              default:
                return Container();
                break;
            }
          } else {
            return Container();
          }
        }),
      ),
    );
  }

//
//  Future _search({String term = ''}) async {
//    // skip search if term does not match current search text
//    if (term != _textController.text) {
//      return;
//    }
//
//    try {
//      // search, or trending when term is empty
//
//      // scroll up
//      if (_scrollController.hasClients) {
//        _scrollController.jumpTo(0);
//      }
//      _repoController.add(["repo"]);
//    } catch (error) {
//      _repoController.addError(error);
//    }
//  }
}