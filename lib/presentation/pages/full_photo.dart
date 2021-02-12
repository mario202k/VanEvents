import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
  final String url;
  final File file;

  const FullPhoto({Key key, @required this.url, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: FullPhotoScreen(
            url: url,
            file: file,
          ),
        ),
      ),
    );
  }
}

class FullPhotoScreen extends StatelessWidget {
  final String url;
  final File file;


  const FullPhotoScreen({this.url, this.file});

  @override
  Widget build(BuildContext context) {
    return PhotoView(
        imageProvider: url == null
            ? FileImage(file)
            : NetworkImage(url) as ImageProvider);
  }
}
