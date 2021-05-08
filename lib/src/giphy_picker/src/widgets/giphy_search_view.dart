import 'dart:async';

import 'package:flutter/material.dart';
import '../../src/model/giphy_repository.dart';
import '../../src/widgets/giphy_context.dart';
import '../../src/widgets/giphy_thumbnail_grid.dart';

/// Provides the UI for searching Giphy gif images.
class GiphySearchView extends StatefulWidget {
  final Function? onClose;

  const GiphySearchView({Key? key, this.onClose}) : super(key: key);

  @override
  _GiphySearchViewState createState() => _GiphySearchViewState();
}

class _GiphySearchViewState extends State<GiphySearchView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _repoController = StreamController<GiphyRepository>();

  @override
  void initState() {
    // initiate search on next frame (we need context)
    Future.delayed(Duration.zero, () {
      final giphy = GiphyContext.of(context);
      _search(giphy);
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
    final giphy = GiphyContext.of(context);

    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: giphy.searchText,
            suffixIcon: IconButton(
              icon: Icon(Icons.keyboard),
              onPressed: widget.onClose as void Function()?,
            ),
          ),
          onChanged: (value) => _delayedSearch(giphy, value),
        ),
      ),
      Expanded(
          child: StreamBuilder(
              stream: _repoController.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<GiphyRepository> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.totalCount! > 0
                      ? NotificationListener(
                          child: RefreshIndicator(
                              child: GiphyThumbnailGrid(
                                  key: Key('${snapshot.data.hashCode}'),
                                  repo: snapshot.data,
                                  scrollController: _scrollController),
                              onRefresh: () =>
                                  _search(giphy, term: _textController.text)),
                          onNotification: (dynamic n) {
                            // hide keyboard when scrolling
                            if (n is UserScrollNotification) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              return true;
                            }
                            return false;
                          },
                        )
                      : Center(child: Text('No results'));
                } else if (snapshot.hasError) {
                  return Center(child: Text('An error occurred'));
                }
                return Center(child: CircularProgressIndicator());
              }))
    ]);
  }

  void _delayedSearch(GiphyContext giphy, String term) => Future.delayed(
      Duration(milliseconds: 500), () => _search(giphy, term: term));

  Future _search(GiphyContext giphy, {String term = ''}) async {
    // skip search if term does not match current search text
    if (term != _textController.text) {
      return;
    }

    try {
      // search, or trending when term is empty
      final repo = await (term.isEmpty
          ? GiphyRepository.trending(
              apiKey: giphy.apiKey,
              rating: giphy.rating,
              onError: giphy.onError)
          : GiphyRepository.search(
              apiKey: giphy.apiKey,
              query: term,
              rating: giphy.rating,
              lang: giphy.language,
              onError: giphy.onError));

      // scroll up
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _repoController.add(repo);
    } catch (error) {
      _repoController.addError(error);
      giphy.onError!(error);
    }
  }
}
