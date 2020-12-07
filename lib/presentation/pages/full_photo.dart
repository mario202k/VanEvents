import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullPhoto extends StatelessWidget {
  final String url;
  final File file;

  FullPhoto({Key key, @required this.url, this.file}) : super(key: key);

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

class FullPhotoScreen extends StatefulWidget {
  final String url;
  final File file;

  FullPhotoScreen({Key key, @required this.url, this.file}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
            imageProvider: widget.url == null
                ? FileImage(widget.file)
                : NetworkImage(url)));
  }
}
