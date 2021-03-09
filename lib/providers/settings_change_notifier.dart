import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_events_project/constants/theming_options.dart';

final settingsProvider = ChangeNotifierProvider.autoDispose<SettingsChangeNotifier>((ref) {
  return SettingsChangeNotifier();
});

enum MyThemes{
  dracula, shinny, clubbing
}

class SettingsChangeNotifier extends ChangeNotifier{

  MyThemes onGoingTheme;
  ColorScheme onGoingcolorScheme;
  SharedPreferences sharePref;

  void setTheme(MyThemes myTheme) {

    onGoingTheme = myTheme;
    setColorScheme(myTheme);

    notifyListeners();

  }

  void setThemeNoNotif(MyThemes myTheme) {

    onGoingTheme = myTheme;
    setColorScheme(myTheme);

  }

  void setColorScheme(MyThemes myTheme){
    switch(myTheme){

      case MyThemes.dracula:
        onGoingcolorScheme = colorSchemeDracula;
        sharePref.setString('theme', 'Dracula');
        break;
      case MyThemes.shinny:
        onGoingcolorScheme = colorSchemeShinny;
        sharePref.setString('theme', 'Shinny');
        break;
      case MyThemes.clubbing:
        onGoingcolorScheme = colorSchemeClubbing;
        sharePref.setString('theme', 'Clubbing');
        break;
    }

  }

  void initial(SharedPreferences sharePref) {
    this.sharePref = sharePref;
    if(onGoingcolorScheme != null){
      return;
    }

    String theme = sharePref.getString('theme');

    theme ??= 'Shinny';

    switch(theme){
      case 'Shinny':
        setThemeNoNotif(MyThemes.shinny);

        break;
      case 'Dracula':
        setThemeNoNotif(MyThemes.dracula);

        break;
      case 'Clubbing':
        setThemeNoNotif(MyThemes.clubbing);

        break;
    }


  }



}