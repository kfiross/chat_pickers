import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import '../../src/model/giphy_repository.dart';
import '../../src/widgets/giphy_context.dart';
import '../../src/widgets/giphy_preview_page.dart';
import '../../src/widgets/giphy_thumbnail.dart';

/// A selectable grid view of gif thumbnails.
class GiphyThumbnailGrid extends StatelessWidget {
  final GiphyRepository? repo;
  final ScrollController? scrollController;

  const GiphyThumbnailGrid(
      {Key? key, required this.repo, this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        controller: scrollController,
        itemCount: repo!.totalCount,
        itemBuilder: (BuildContext context, int index) => GestureDetector(
            child: GiphyThumbnail(key: Key('$index'), repo: repo, index: index),
            onTap: () async {
              // display preview page
              final giphy = GiphyContext.of(context);
              final GiphyGif? gif = await repo!.get(index);
              if (giphy.showPreviewPage) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => GiphyPreviewPage(
                      gif: gif ?? GiphyGif(),
                      onSelected: giphy.onSelected,
                    ),
                  ),
                );
              } else {
                if(gif != null)
                  giphy.onSelected!(gif);
              }
            }),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? 2
                    : 3,
            childAspectRatio: 1.6,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5));
  }
}
