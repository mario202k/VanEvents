import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen/screen.dart';
import 'package:van_events_project/domain/models/billet.dart';
import 'package:van_events_project/domain/repositories/my_billet_repository.dart';
import 'package:van_events_project/presentation/widgets/show.dart';


class QrCode extends StatefulWidget {
  final String data;

  QrCode(this.data);

  @override
  _QrCodeState createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  double brightness;
  Stream<Billet> streamBillet;
  bool isValidated = false;
  bool isCancel = false;
  final GlobalKey<ScaffoldState> scaffolKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // Set the brightness:
    setBrightness();
    super.initState();
  }

  Future setBrightness() async {
    brightness = await Screen.brightness;
    Screen.setBrightness(1);
  }

  @override
  void dispose() {
    if (brightness != null) {
      Screen.setBrightness(brightness);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read(myBilletRepositoryProvider);
    streamBillet = db.streamBillet(widget.data);
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
          key: scaffolKey,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          body: Center(
            child: StreamBuilder<Billet>(
                stream: streamBillet,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.secondary)),
                    );
                  } else if (snapshot.hasError) {
                    print('Erreur de connexion${snapshot.error.toString()}');
                    Show.showSnackBar(
                        'Erreur de connexion${snapshot.error.toString()}',
                        scaffolKey);
                    print('Erreur de connexion${snapshot.error.toString()}');
                    return Center(
                      child: Text(
                        'Erreur de connexion',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    print("pas data");
                    return Center(
                      child: Text('Erreur de connexion'),
                    );
                  }

                  Billet ticket = snapshot.data;

                  if (ticket.status == 'Validé' && !isValidated) {
                    isValidated = true;
                  } else if (ticket.status == 'Annulé' && !isCancel) {
                    isCancel = true;
                  }

                  return Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: QrImage(
                          data: widget.data,
                          version: QrVersions.auto,
                          size: 320,
                          gapless: false,
                        ),
                      ),
                      Visibility(
                        visible: isValidated,
                        child: FlareActor(
                          'assets/animations/ok.flr',
                          alignment: Alignment.center,
                          animation: 'Checkmark Appear',
                        ),
                      )
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
