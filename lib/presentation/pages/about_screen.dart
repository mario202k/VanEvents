import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/repositories/my_user_repository.dart';
import 'package:van_events_project/presentation/widgets/model_body.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';

class AboutScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final about = useProvider(aboutFutureProvider);
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('À propos'),
        ),
        body: ModelBody(
          child: Consumer(builder: (context, watch, child) {
            return Column(
              children: [
                about.when(
                    data: (data) {
                      final about = data.isEmpty ? null : data?.first;
                      if (about == null) {
                        return Row(
                          children: [
                            Center(
                                child: Text(
                              'À faire',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                          ],
                        );
                      }

                      final SplayTreeMap<int,int> myContent = SplayTreeMap.from(
                          about.content,
                          (key1, key2) => key1
                              .compareTo(key2));

                      return Column(
                        children: [
                          Text(
                            about.title,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          ...myContent.keys?.map((keys) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  keys.toString(),
                                  style:
                                  Theme.of(context).textTheme.headline5,
                                ),
                                Text(
                                  about.content[keys],
                                  style: Theme.of(context).textTheme.bodyText1,
                                  textAlign: TextAlign.justify,
                                )
                              ],
                            );
                          }),
                        ],
                      );
                    },
                    loading: () => Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary)),
                        ),
                    error: (e, s) {
                      debugPrint(e.toString());
                      debugPrint(s.toString());
                      return Center(
                          child: Text(
                        'Erreur$e',
                        style: Theme.of(context).textTheme.bodyText1,
                      ));
                    }),
              ],
            );
          }),
        ),
      ),
    );
  }
}
