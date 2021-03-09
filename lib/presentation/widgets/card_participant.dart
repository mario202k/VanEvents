import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/formule.dart';
import 'package:van_events_project/domain/models/my_user.dart';
import 'package:van_events_project/domain/routing/route.gr.dart';
import 'package:van_events_project/providers/formul_vtc.dart';

class CardParticipant extends StatefulWidget {
  final Formule formule;
  final int index;
  final bool isToDestroy;

  const CardParticipant({this.formule, this.index, this.isToDestroy});

  @override
  _CardParticipantState createState() => _CardParticipantState();
}

class _CardParticipantState extends State<CardParticipant>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final TextEditingController _textEditingController = TextEditingController();
  String _isUserBuyingFor;

  @override
  void initState() {
    _isUserBuyingFor = '';
    context.read(formuleVTCProvider).onChangeParticipant(widget.formule, _fbKey,
        widget.index, widget.isToDestroy, true, _isUserBuyingFor);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer(builder: (context, watch, child) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            // gradient: LinearGradient(colors: [
            //   Theme.of(context).colorScheme.primary,
            //   Theme.of(context).colorScheme.secondary
            // ]),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Participant',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                FormBuilder(
                  key: _fbKey,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        controller: _textEditingController,
                        valueTransformer: (value) => value.toString().trim(),
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        name: 'prenom_nom',
                        decoration: InputDecoration(
                          labelText: 'Prénom Nom',
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                  Theme.of(context).colorScheme.onPrimary,
                                  width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                  Theme.of(context).colorScheme.onPrimary,
                                  width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          labelStyle: Theme.of(context).textTheme.bodyText2,
                          counterStyle: const TextStyle(color: Colors.white),
                        ),
                        onChanged: (val) {

                          final String userId = context
                              .read(formuleVTCProvider)
                              .isUserBuyingFor(widget.formule, val);

                          if (userId.isNotEmpty) {
                            setState(() {
                              _isUserBuyingFor = userId;
                            });
                          } else if (_isUserBuyingFor.isNotEmpty) {
                            setState(() {
                              _isUserBuyingFor = '';
                            });
                          }

                          context.read(formuleVTCProvider).onChangeParticipant(
                              widget.formule,
                              _fbKey,
                              widget.index,
                              widget.isToDestroy,
                              false,
                              _isUserBuyingFor);
                        },
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context,errorText: 'Champs requis'),
                          FormBuilderValidators.match(context,
                              r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ -]{2,60}$',errorText: 'Erreur de saisie')
                        ]),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
                if (_isUserBuyingFor.isNotEmpty)
                  const Text('Le billet lui sera directement envoyé')
                else
                  const SizedBox(),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlineButton(
                        onPressed: () {
                          _textEditingController.text =
                              context.read(myUserProvider).nom;
                        },
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary),
                        child: Text(
                          'Pour moi',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      const Text('ou'),
                      OutlineButton(
                        onPressed: () {
                          context.read(formuleVTCProvider).setCurrent(
                              widget.formule,
                              _textEditingController);
                          ExtendedNavigator.of(context).push(
                              Routes.searchUserEvent,
                              arguments: SearchUserEventArguments(
                                  isEvent: false,
                                  fromBilletForm: true,
                                  fromTransport: false));
                        },
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary),
                        child: Text(
                          'Payer pour...',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}