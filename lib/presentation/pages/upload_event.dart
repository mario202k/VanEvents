import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:van_events_project/domain/models/event.dart';
import 'package:van_events_project/domain/models/formule.dart';
import 'package:van_events_project/presentation/widgets/model_screen.dart';
import 'package:van_events_project/presentation/widgets/show.dart';
import 'package:van_events_project/providers/upload_event.dart';


class UploadEvent extends StatefulWidget {
  final MyEvent myEvent;

  UploadEvent({this.myEvent});

  @override
  UploadEventState createState() => UploadEventState();
}

class UploadEventState extends State<UploadEvent> {
  UploadEventChangeNotifier uploadEventRead;

  @override
  void initState() {
    uploadEventRead = context.read(uploadEventProvider);

    uploadEventRead.initState(context, widget.myEvent);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    uploadEventRead.nodes.forEach((node) => node.dispose());
    //uploadEventRead.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return ModelScreen(
      child: Scaffold(
        key: uploadEventRead.myScaffoldKey,
        appBar: AppBar(
          title: Text(
            'UploadEvent',
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          controller: uploadEventRead.scrollController,
          child: Column(
            children: <Widget>[
              Text(
                'Flyer',
                style: Theme.of(context).textTheme.headline5,
              ),
              InkWell(
                onTap: () async {
                  uploadEventRead
                      .setFlyer(await Show.showDialogSource(context));
                },
                child: Container(
                  child: Consumer(builder: (context, watch, child) {
                    return watch(uploadEventProvider).flyer != null
                        ? Image.file(
                      watch(uploadEventProvider).flyer,
                    )
                        : uploadEventRead.isUpdating
                        ? CachedNetworkImage(
                      placeholder: (context, url) =>
                          Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor:
                            Theme.of(context).colorScheme.primary,
                            child: Container(
                                height: 900,
                                width: 600,
                                color: Colors.white),
                          ),
                      imageBuilder: (context, imageProvider) =>
                          SizedBox(
                            height:
                            MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width,
                            child: Image(
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                          ),
                      errorWidget: (context, url, error) => Material(
                        child: Image.asset(
                          'assets/img/imgnotavailable.jpeg',
                          width: 300.0,
                          height: 300.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                      imageUrl: widget.myEvent.imageFlyerUrl,
                      fit: BoxFit.scaleDown,
                    )
                        : Icon(
                      FontAwesomeIcons.image,
                      color: Theme.of(context).colorScheme.primary,
                      size: 220,
                    );
                  }),
                ),
              ),
              Text(
                'Photos',
                style: Theme.of(context).textTheme.headline5,
              ),
              InkWell(
                onTap: uploadEventRead.loadAssets,
                child: Consumer(builder: (context, watch, child) {
                  final uploadEventWatch = watch(uploadEventProvider);
                  return uploadEventWatch.images.length > 0
                      ? GridView.builder(
                      itemCount: uploadEventWatch.images.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          (orientation == Orientation.landscape)
                              ? 3
                              : 2),
                      itemBuilder: (BuildContext context, int index) {
                        Asset asset = uploadEventRead.images[index];

                        return AssetThumb(
                          asset: asset,
                          width: 300,
                          height: 300,
                        );
                      })
                      : uploadEventWatch.isUpdating &&
                      widget.myEvent.imagePhotos.length > 0
                      ? GridView.builder(
                      itemCount: widget.myEvent.imagePhotos.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          (orientation == Orientation.landscape)
                              ? 3
                              : 2),
                      itemBuilder: (BuildContext context, int index) {
                        return CachedNetworkImage(
                          placeholder: (context, url) =>
                              Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor:
                                Theme.of(context).colorScheme.primary,
                                child: Container(
                                    height: 300,
                                    width: 300,
                                    color: Colors.white),
                              ),
                          imageBuilder: (context, imageProvider) =>
                              SizedBox(
                                height: 300,
                                width: 300,
                                child: Image(
                                  image: imageProvider,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              Material(
                                child: Image.asset(
                                  'assets/img/imgnotavailable.jpeg',
                                  width: 300.0,
                                  height: 300.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                          imageUrl: widget.myEvent.imagePhotos[index],
                          fit: BoxFit.scaleDown,
                        );
                      })
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.images,
                        color: Theme.of(context).colorScheme.primary,
                        size: 100,
                      ),
                      Icon(
                        FontAwesomeIcons.images,
                        color: Theme.of(context).colorScheme.primary,
                        size: 100,
                      ),
                      Icon(
                        FontAwesomeIcons.images,
                        color: Theme.of(context).colorScheme.primary,
                        size: 100,
                      )
                    ],
                  );
                }),
              ),
              Text(
                'Genre',
                style: Theme.of(context).textTheme.headline5,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: uploadEventRead.genre.keys
                    .map((e) => SizedBox(
                  height: 55,
                  child: Consumer(
                    builder:
                        (BuildContext context, watch, Widget child) {
                      return CheckboxListTile(
                        onChanged: (bool val) =>
                            uploadEventRead.setGenre(e),
                        value: watch(uploadEventProvider).genre[e],
                        activeColor:
                        Theme.of(context).colorScheme.primary,
                        title: Text(
                          e,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
                    },
                  ),
                ))
                    .toList(),
              ),
              Text(
                'Type',
                style: Theme.of(context).textTheme.headline5,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: uploadEventRead.type.keys
                    .map((e) => SizedBox(
                  height: 55,
                  child: Consumer(
                    builder: (context, watch, child) {
                      return CheckboxListTile(
                        onChanged: (bool val) =>
                            uploadEventRead.setType(e),
                        value: watch(uploadEventProvider).type[e],
                        activeColor:
                        Theme.of(context).colorScheme.primary,
                        title: Text(
                          e,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
                    },
                  ),
                ))
                    .toList(),
              ),
              IntrinsicHeight(
                child: FormBuilder(
                  // context,
                  key: uploadEventRead.fbKey,
                  //autovalidate: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FormBuilderTextField(
                        controller: uploadEventRead.title,
                        name: 'Titre',
                        focusNode: uploadEventRead.nodes[0],
                        onEditingComplete: () {
                          if (uploadEventRead
                              .fbKey.currentState.fields['Titre']
                              .validate()) {
                            uploadEventRead.nodes[0].unfocus();

                            FocusScope.of(context)
                                .requestFocus(uploadEventRead.nodes[1]);
                          }
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        decoration: InputDecoration(labelText: 'Titre'),
                        validator:FormBuilderValidators.required(context,),

                      ),

                      Divider(),
                      Text(
                        'Durée',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      FormBuilderDateTimePicker(
                        controller: uploadEventRead.dateDebutController,
                        firstDate: DateTime.now(),
                        initialValue: uploadEventRead.isUpdating?widget.myEvent.dateDebut:null,
                        initialTime: TimeOfDay.now() ,

                        initialDate: uploadEventRead.isUpdating
                            ? uploadEventRead.dateDebut ?? DateTime.now()
                            : DateTime.now(),
                        locale: Locale('fr'),
                        name: "Date de debut",
                        focusNode: uploadEventRead.nodes[1],
                        onChanged: (dt) {
                          uploadEventRead.setDateDebut(dt);
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        inputType: InputType.both,
                        format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                        decoration: InputDecoration(
                            labelText: !uploadEventRead.isUpdating
                                ? 'Date de debut'
                                : DateFormat("dd/MM/yyyy 'à' HH:mm")
                                .format(widget.myEvent.dateDebut)),
                        validator:FormBuilderValidators.required(context,),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FormBuilderDateTimePicker(
                        controller: uploadEventRead.dateFinController,
                        firstDate: uploadEventRead.dateDebut ?? DateTime.now(),
                        initialValue: uploadEventRead.isUpdating?widget.myEvent.dateFin:null,
                        initialDate:
                        uploadEventRead.dateDebut ?? DateTime.now(),
                        name: "Date de fin",
                        onChanged: (dt) {
                          uploadEventRead.setDateFin(dt);
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        focusNode: uploadEventRead.nodes[2],
                        onEditingComplete: () {
                          if (uploadEventRead.fbKey.currentState
                              .fields['Date de fin']
                              .validate()) {
                            uploadEventRead.nodes[2].unfocus();
                            //FocusScope.of(context).requestFocus(nodes[3]);
                          }
                        },
                        inputType: InputType.both,
                        format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                        decoration: InputDecoration(
                            labelText: !uploadEventRead.isUpdating
                                ? 'Date de fin'
                                : DateFormat("dd/MM/yyyy 'à' HH:mm")
                                .format(widget.myEvent.dateFin)),
                        validator:FormBuilderValidators.required(context,),
                      ),
                      Divider(),
                      !uploadEventRead.isUpdating?Column(
                        children: <Widget>[
                          Text(
                            'A l\'affiche',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          Consumer(
                            builder: (context, watch, child) {
                              return CheckboxListTile(
                                onChanged: (bool val) {
                                  uploadEventRead.setIsAffiche();
                                },
                                value: watch(uploadEventProvider).isAffiche,
                                activeColor: Theme.of(context).colorScheme.primary,
                                title: Text(
                                  'A l\'affiche',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              );
                            },
                          ),
                          Consumer(builder: (context, watch, child) {
                            return Visibility(
                              visible: watch(uploadEventProvider).isAffiche,
                              child: CheckboxListTile(
                                onChanged: (bool val) {
                                  uploadEventRead.setJusquauJourJ(val);
                                },
                                value: watch(uploadEventProvider).isJusquauJourJ,
                                activeColor: Theme.of(context).colorScheme.primary,
                                title: Text(
                                  watch(uploadEventProvider).isJusquauJourJ
                                      ? 'Jusqu\'au jour J'
                                      : 'Durée:',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            );
                          }),
                          Consumer(builder: (context, watch, child) {
                            return Visibility(
                              visible: !watch(uploadEventProvider).isJusquauJourJ &&
                                  watch(uploadEventProvider).isAffiche,
                              child: Column(
                                children: [
                                  FormBuilderDateTimePicker(
                                    name: "Date de début d\'affiche",
                                    firstDate: DateTime.now(),
                                    initialDate: DateTime.now(),
                                    controller:
                                    uploadEventRead.debutAfficheController,
                                    onChanged: (dt) {
                                      uploadEventRead.setDebutAffiche(dt);
                                    },
                                    style: Theme.of(context).textTheme.bodyText1,
                                    cursorColor:
                                    Theme.of(context).colorScheme.onBackground,
                                    inputType: InputType.both,
                                    format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                                    decoration: InputDecoration(
                                        labelText:
                                        widget.myEvent?.dateDebutAffiche != null
                                            ? DateFormat("dd/MM/yyyy 'à' HH:mm")
                                            .format(widget
                                            .myEvent?.dateDebutAffiche)
                                            : 'Date de début d\'affiche'),
                                    validator:FormBuilderValidators.required(context,),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  FormBuilderDateTimePicker(
                                    firstDate: DateTime.now(),
                                    initialDate: uploadEventRead.debutAffiche?? DateTime.now(),
                                    name: "Date de fin d\'affiche",
                                    controller:
                                    uploadEventRead.finAfficheController,
                                    onChanged: (dt) {
                                      uploadEventRead.setFinAffiche(dt);
                                    },
                                    style: Theme.of(context).textTheme.bodyText1,
                                    cursorColor:
                                    Theme.of(context).colorScheme.onBackground,
                                    inputType: InputType.both,
                                    format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                                    decoration: InputDecoration(
                                        labelText: widget.myEvent?.dateFinAffiche !=
                                            null
                                            ? DateFormat("dd/MM/yyyy 'à' HH:mm")
                                            .format(
                                            widget.myEvent?.dateFinAffiche)
                                            : 'Date de fin d\'affiche'),
                                    validator:FormBuilderValidators.required(context,),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ):SizedBox(),
                      Divider(),
                      Text(
                        'Adresse',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      FormBuilderTextField(
                        controller: uploadEventRead.rue,
                        name: 'Rue',
                        focusNode: uploadEventRead.nodes[3],
                        style: Theme.of(context).textTheme.bodyText1,
                        onTap: () async {
                          final place = await Show.showAddress(context,'UploadEvent');
                          uploadEventRead.setPlace(place);
                        },
                        decoration: InputDecoration(labelText: 'Rue'),
                        validator:FormBuilderValidators.required(context,),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FormBuilderTextField(
                        controller: uploadEventRead.codePostal,
                        name: 'Code Postal',
                        focusNode: uploadEventRead.nodes[4],
                        style: Theme.of(context).textTheme.bodyText1,
                        onTap: () async {
                          final place = await Show.showAddress(context,'UploadEvent');
                          uploadEventRead.setPlace(place);
                        },
                        decoration: InputDecoration(labelText: 'Code Postal'),
                        validator:FormBuilderValidators.required(context,),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FormBuilderTextField(
                        controller: uploadEventRead.ville,
                        name: 'Ville',
                        focusNode: uploadEventRead.nodes[5],
                        style: Theme.of(context).textTheme.bodyText1,
                        onTap: () async {
                          final place = await Show.showAddress(context,'UploadEvent');
                          if(place == null){
                            return;
                          }
                          uploadEventRead.setPlace(place);
                        },
                        decoration: InputDecoration(labelText: 'Ville'),
                        validator:FormBuilderValidators.required(context,),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FormBuilderTextField(
                        controller: uploadEventRead.coords,
                        name: 'Coordonnée',
                        focusNode: uploadEventRead.nodes[6],
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: 'Coordonnée'),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(context,),
                          FormBuilderValidators.match(context,
                              r'^([-+]?)([\d]{1,2})(((\.)(\d+)(,)))(\s*)(([-+]?)([\d]{1,3})((\.)(\d+))?)$'),]),
                      ),
                      Divider(),
                      FormBuilderTextField(
                        controller: uploadEventRead.description,
                        name: 'description',
                        maxLines: 10,
                        focusNode: uploadEventRead.nodes[7],
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator:FormBuilderValidators.required(context,),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              Consumer(builder: (context, watch, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: watch(uploadEventProvider).formulesWidgets,
                );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: () {
                      if (uploadEventRead.formulesWidgets.length > 2) {
                        uploadEventRead.deleteFormule();
                      }
                    },
                    child: Icon(
                      FontAwesomeIcons.minus,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 5.0,
                    fillColor: Color(0xffFAF4F2),
                    padding: const EdgeInsets.all(10.0),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      uploadEventRead.addFormule();
                    },
                    child: Icon(
                      FontAwesomeIcons.plus,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 5.0,
                    fillColor: Color(0xffFAF4F2),
                    padding: const EdgeInsets.all(10.0),
                  ),
                ],
              ),
              Divider(),
              Consumer(

                  builder: (context, watch,child) {
                    final myUploadWatch = watch(uploadEventProvider);
                    return Column(
                      children: [
                        LimitedBox(
                          child: AnimatedCircularChart(
                            key: uploadEventRead.chartKey,
                            size: const Size(300.0, 300.0),
                            initialChartData: myUploadWatch.data,
                            chartType: CircularChartType.Radial,
                            //percentageValues: true,
                            holeLabel: myUploadWatch.nbTotal.toString(),
                            labelStyle: TextStyle(
                              color: Colors.blueGrey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),maxHeight: 300.0,maxWidth: 300.0,
                        ),
                        Wrap(
                          alignment: WrapAlignment.spaceAround,
                          spacing: 40,
                          direction: Axis.horizontal,
                          runSpacing: 5,
                          children: myUploadWatch.listIndicator,
                        ),
                      ],
                    );
                  }
              ),

              Divider(),
              Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Consumer(builder: (context, watch, child) {
                        return !watch(uploadEventProvider).showSpinnerAppliquer
                            ? RaisedButton(
                          child: Text(
                            "Appliquer",
                          ),
                          onPressed: () async {
                            await uploadEventRead.findCodePromo(context);
                          },
                        )
                            : Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary)),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: FormBuilderTextField(
                      controller: uploadEventRead.codePromo,
                      name: 'CodePromo',
                      onEditingComplete: () async {
                        //SystemChannels.textInput.invokeMethod('TextInput.hide');
                        await uploadEventRead.findCodePromo(context);
                      },
                      decoration: InputDecoration(
                          labelText: 'Code promo',
                          suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () =>
                                  uploadEventRead.clearPromoCode())),
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Consumer(builder: (context, watch, child) {
                        return !watch(uploadEventProvider).showSpinner
                            ? RaisedButton(
                          child: Text(
                            "Soumettre",
                          ),
                          onPressed: () {
                            uploadEventRead.submit(context);
                          },
                        )
                            : Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary)),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: RaisedButton(
                      //color: Theme.of(context).colorScheme,
                      child: Text(
                        "Recommencer", overflow: TextOverflow.ellipsis,
                        //style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        uploadEventRead.scrollController.animateTo(0.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                        //fbKey.currentState.reset();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Consumer(builder: (context, watch, child) {
          final toggleWatch = watch(uploadEventProvider);
          return Visibility(
            visible: toggleWatch.eventCost >= 0.5,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              color: Theme.of(context).colorScheme.secondary,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  Text(
                    '${toggleWatch.eventCostDiscounted == null ? toggleWatch.eventCost.toStringAsFixed(toggleWatch.eventCost.truncateToDouble() == toggleWatch.eventCost ? 0 : 2) :
                    toggleWatch.eventCostDiscounted.toStringAsFixed(toggleWatch.eventCostDiscounted.truncateToDouble() == toggleWatch.eventCostDiscounted ? 0 : 2)} €',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class CardFormula extends StatefulWidget {
  final int numero;

  final Function onChangedNbPersonne;
  final GlobalKey<FormBuilderState> fbKey = GlobalKey();
  final Formule formule;

  CardFormula(this.numero, this.onChangedNbPersonne, {this.formule});

  @override
  CardFormulaState createState() => CardFormulaState();
}

class CardFormulaState extends State<CardFormula> {
  List<FocusScopeNode> nodes;
  TextEditingController textEditingControllerTitle = TextEditingController();
  TextEditingController textEditingControllerPrix = TextEditingController();
  TextEditingController textEditingControllernb = TextEditingController();

  @override
  void initState() {
    nodes = List<FocusScopeNode>.generate(
      3,
          (index) => FocusScopeNode(),
    );

    if (widget.formule != null) {
      textEditingControllerTitle.text = widget.formule.title;
      textEditingControllerPrix.text = widget.formule.prix.toString();
      textEditingControllernb.text = widget.formule.nombreDePersonne.toString();

    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          //gradient: LinearGradient(begin: AlignmentGeometry.),
//                          color: Colors.blueAccent
        ),
        child: FormBuilder(
          key: widget.fbKey,
          //autovalidate: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Formule n° ${widget.numero + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                  controller: textEditingControllerTitle,
                  name: 'Nom',
                  decoration: InputDecoration(labelText: 'Nom'),
                  onChanged: (val) {
                    widget.fbKey.currentState.save();
                  },
                  focusNode: nodes[0],
                  onEditingComplete: () {
                    if (widget.fbKey.currentState.fields['Nom']
                        .validate()) {
                      nodes[0].unfocus();

                      FocusScope.of(context).requestFocus(nodes[1]);
                    }
                  },
                  keyboardType: TextInputType.text,
                  validator: FormBuilderValidators.required(context),
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                controller: textEditingControllerPrix,
                name: 'Prix',
                decoration: InputDecoration(labelText: 'Prix'),
                onChanged: (val) {
                  widget.fbKey.currentState.save();
                },
                focusNode: nodes[1],
                onEditingComplete: () {
                  if (widget.fbKey.currentState.fields['Prix']
                      .validate()) {
                    nodes[1].unfocus();

                    FocusScope.of(context).requestFocus(nodes[2]);
                  }
                },
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.required(context),
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                controller: textEditingControllernb,
                name: 'Nombre de personne par formule',
                decoration: InputDecoration(
                    labelText: 'Nombre de personne par formule'),
                onChanged: (value) {
                  widget.fbKey.currentState.save();

                  if (widget.onChangedNbPersonne != null) {
                    widget.fbKey.currentState.save();
                    widget.onChangedNbPersonne('${widget.numero}/$value');
                  }
                },
                focusNode: nodes[2],
                onEditingComplete: () {
                  if (widget.fbKey.currentState
                      .fields['Nombre de personne par formule']
                      .validate()) {
                    nodes[2].unfocus();
                  }
                },
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.required(context)
                ,
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
