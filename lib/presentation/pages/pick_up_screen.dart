import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';

class PickupScreen extends StatelessWidget {

  final String imageUrl;
  final String nom;

  const PickupScreen({this.imageUrl, this.nom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 50),
            if (imageUrl != null) Image.network(imageUrl) else Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary,
                backgroundImage: const AssetImage(
                    'assets/img/normal_user_icon.png'),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              nom,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    ExtendedNavigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 25),
                IconButton(
                  icon: const Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async {

                    ExtendedNavigator.of(context).push(
                        Routes.callScreen,
                        arguments: CallScreenArguments(
                            imageUrl: imageUrl,
                            nom: nom));

                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
