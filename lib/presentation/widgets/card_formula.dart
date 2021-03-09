import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:van_events_project/domain/models/formule.dart';
import 'package:van_events_project/presentation/widgets/card_participant.dart';
import 'package:van_events_project/providers/formul_vtc.dart';

class CardFormula extends StatefulWidget {
  final Formule formule;

  const CardFormula(this.formule);

  @override
  _CardFormulaState createState() => _CardFormulaState();
}

class _CardFormulaState extends State<CardFormula>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final formulVtc = context.read(formuleVTCProvider);
    return Consumer(builder: (context, watch, child) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              height: 128.0,
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                          child: Text(
                            '${widget.formule.title} : ${toNormalPrice(widget.formule.prix)} €',
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RawMaterialButton(
                            onPressed: () {
                              if (formulVtc.getNb(widget.formule.id) > 0) {
                                _listKey.currentState.removeItem(
                                  formulVtc
                                      .getCardParticipants(
                                      widget.formule.id)
                                      .length -
                                      1,
                                      (BuildContext context,
                                      Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: CurvedAnimation(
                                          parent: animation,
                                          curve: const Interval(0.5, 1.0)),
                                      child: SizeTransition(
                                        sizeFactor: CurvedAnimation(
                                            parent: animation,
                                            curve: const Interval(0.0, 1.0)),
                                        child: CardParticipant(
                                          index: formulVtc
                                              .getCardParticipants(
                                              widget.formule.id)
                                              .length,
                                          isToDestroy: true,
                                          formule: widget.formule,
                                        ),
                                      ),
                                    );
                                  },
                                  duration: const Duration(milliseconds: 600),
                                );
                                formulVtc.removeCardParticipants(
                                    widget.formule,
                                    context
                                        .read(formuleVTCProvider)
                                        .getCardParticipants(
                                        widget.formule.id)
                                        .length -
                                        1);

                                formulVtc.setNb(
                                    widget.formule,
                                    context
                                        .read(formuleVTCProvider)
                                        .getCardParticipants(widget.formule.id)
                                        .length);
                                formulVtc
                                    .settotalCostMoins(widget.formule.prix);
                              }
                            },
                            shape: const CircleBorder(),
                            elevation: 5.0,
                            fillColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              FontAwesomeIcons.minus,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30.0,
                            ),
                          ),
                          Consumer(builder: (context, watch, child) {
                            final formulVtc = watch(formuleVTCProvider);
                            return Text(
                                formulVtc
                                    .formuleParticipant[formulVtc
                                    .formuleParticipant.keys
                                    .firstWhere((element) =>
                                element.formule.id ==
                                    widget.formule.id)]
                                    .nb
                                    .toString(),
                                style: Theme.of(context).textTheme.subtitle1);
                          }),
                          RawMaterialButton(
                            onPressed: () {
                              if (formulVtc.getNb(widget.formule.id) >= 0) {
                                formulVtc.setCarParticipants(
                                    widget.formule,
                                    formulVtc
                                        .getCardParticipants(
                                        widget.formule.id)
                                        .length -
                                        1);
                                formulVtc.setNb(
                                    widget.formule,
                                    formulVtc
                                        .getCardParticipants(widget.formule.id)
                                        .length);
                                formulVtc.settotalCostPlus(widget.formule.prix);

                                _listKey.currentState.insertItem(
                                    formulVtc
                                        .getCardParticipants(
                                        widget.formule.id)
                                        .length -
                                        1,
                                    duration:
                                    const Duration(milliseconds: 500));
                              }
                            },
                            shape: const CircleBorder(),
                            elevation: 5.0,
                            fillColor: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              FontAwesomeIcons.plus,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedList(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            key: _listKey,
            initialItemCount: context
                .read(formuleVTCProvider)
                .getCardParticipants(widget.formule.id)
                ?.length ??
                0,
            itemBuilder:
                (BuildContext context, int index, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: CardParticipant(
                  formule: widget.formule,
                  index: index,
                  isToDestroy: false,
                ),
              );
            },
          ),
        ],
      );
    });
  }

  String toNormalPrice(double price) {
    return price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}