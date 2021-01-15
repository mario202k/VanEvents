import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:van_events_project/providers/toggle_bool.dart';

class GalleryPage extends StatelessWidget {
  final List imageList;

  final int initialPage;

  const GalleryPage({@required this.imageList, @required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Gallery'),
      ),
      body: PhotoViewGallery.builder(
        pageController: PageController(initialPage: initialPage),
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: context.read(boolToggleProvider).imageProviderDetail[index],
            initialScale: PhotoViewComputedScale.contained * 0.8,
            heroAttributes: PhotoViewHeroAttributes(
                tag: imageList[index]
                    .substring(imageList[index].indexOf('token='))),
          );
        },
        itemCount: imageList.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
//        pageController: widget.pageController,
//        onPageChanged: onPageChanged,
      ),
    );
  }
}
