library giphy_picker;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'src/widgets/giphy_context.dart';
import 'src/widgets/giphy_search_page.dart';
import 'src/widgets/giphy_search_view.dart';
import 'src/widgets/top_dialog.dart';

export 'src/widgets/giphy_image.dart';

typedef ErrorListener = void Function(dynamic error);

/// Provides Giphy picker functionality.
class GiphyPicker {
  /// Renders a full screen modal dialog for searching, and selecting a Giphy image.
  static Future<GiphyGif> pickGif({
    @required BuildContext context,
    @required String apiKey,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
    Widget title,
    ErrorListener onError,
    bool showPreviewPage = true,
    String searchText = 'Search GIPHY',
  }) async {
    GiphyGif result;

    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              GiphyContext(
                child: GiphySearchPage(),
                apiKey: apiKey,
                rating: rating,
                language: lang,
                onError: onError ?? (error) => _showErrorDialog(context, error),
                onSelected: (gif) {
                  result = gif;

                  // pop preview page if necessary
                  if (showPreviewPage) {
                    Navigator.pop(context);
                  }
                  // pop giphy_picker
                  Navigator.pop(context);
                },
                showPreviewPage: showPreviewPage,
                searchText: searchText,
              ),
          fullscreenDialog: false),
    );

    return result;
  }

  static Widget pickerGifWidget({
    @required BuildContext context,
    @required String apiKey,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
    Widget title,
    Function onClose,
    Function(GiphyGif) onSelected
  }) {
    return SingleChildScrollView(
      child: GiphyContext(
        child: SafeArea(
            child: Container(width: 400, height: 280, child: GiphySearchView(onClose: onClose), color: Colors.white,),
            bottom: false
        ),
        apiKey: apiKey,
        rating: rating,
        language: lang,
        onError: (error) => _showErrorDialog(context, error),
        onSelected: onSelected,
        showPreviewPage: false,
//      searchText: searchText,
      ),
    );
  }

  static Future<GiphyGif> pickGifSmallScreen({
    @required BuildContext context,
    @required String apiKey,
    String rating = GiphyRating.g,
    String lang = GiphyLanguage.english,
    Widget title,
    ErrorListener onError,
    bool showPreviewPage = true,
    String searchText = 'Search GIPHY',

  }) async {
    GiphyGif result;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // todo: using BottomDialog instead
        return PositionedDialog(
          //contentPadding: const EdgeInsets.all(4),
          position: DialogPosition.BOTTOM,
          //title: Text('Giphy Search', style: TextStyle(fontWeight: FontWeight.bold),),
          content: GiphyContext(
            child: SafeArea(
                child: Container(
                    width: 400, height: 500, child: GiphySearchView()),
                bottom: false),
            apiKey: apiKey,
            rating: rating,
            language: lang,
            onError: onError ?? (error) => _showErrorDialog(context, error),
            onSelected: (gif) {
              result = gif;

              // pop preview page if necessary
              if (showPreviewPage) {
                Navigator.pop(context);
              }
              // pop giphy_picker
              Navigator.pop(context);
            },
            showPreviewPage: showPreviewPage,
            searchText: searchText,
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return result;
  }

  static void _showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text('Giphy error'),
          content: new Text('An error occurred. $error'),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
