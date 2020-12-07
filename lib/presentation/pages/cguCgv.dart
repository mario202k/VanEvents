import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';

class CguCgv extends StatefulWidget {
  final String cguOuCgv;

  CguCgv(this.cguOuCgv);

  @override
  _CguCgvState createState() => _CguCgvState();
}

class _CguCgvState extends State<CguCgv> {
  String cg;

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/cgucgv/${widget.cguOuCgv}.txt');
  }

  @override
  Widget build(BuildContext context) {
    loadAsset(context).then((value) {
      setState(() {
        cg = value;
      });
    });
    return ModelScreen(
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.cguOuCgv),
          ),
          body: ModelBody(
            child: Column(
              children: <Widget>[
                Text(
                  cg != null ? cg : '',
                  style: Theme.of(context).textTheme.headline5,
                )
              ],
            ),
          )),
    );
  }
}
