import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/views/all_recipes_view.dart';
import 'package:szef_kuchni_v2/views/favourite_recipes.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:szef_kuchni_v2/services/query_service.dart' as qs;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MainView extends StatefulWidget {
  final void Function(bool) onThemeChanged;
  final stt.SpeechToText? speechToText;
  const MainView({super.key, required this.onThemeChanged, this.speechToText});
  
  @override
  State<MainView> createState() => _MainViewState();
  }

class _MainViewState extends State<MainView> {
  final AllRecipesView _allRecipesView = AllRecipesView(
    key: const Key('all_recipes_view'),
    onSignalReceived: (String signal){}
  );
  int selectedIndex = 0;
  bool isInDarkMode = false;
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  String searchText="";

  // switches index based on selected icon
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState(){
    super.initState();
    _speech = widget.speechToText ?? stt.SpeechToText();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontSize: 35.0,
      fontWeight: FontWeight.w900,
    );
    
    Widget view;
    switch (selectedIndex) {
      case 0:
        view = _allRecipesView;
      case 1:
        view = FavouriteRecipesView();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      // TOP BAR
      appBar: topBar(theme, style),

      // MAIN BODY
      body: view,

      // VOICE LISTENING BUTTON
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton : voiceListeningButton(theme),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: bottomNavigationBar(theme),
    );
  }

  AppBar topBar(ThemeData theme, TextStyle style) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      titleSpacing: 20.0,
      title: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: theme.cardTheme.color,
                  child: Text(
                    "Szef Kuchni", 
                    style: style,
                    textAlign: TextAlign.center,
                  ),          
              ),
            ),
          ),
          Switch(
            value: isInDarkMode,
            onChanged: (value) {
              setState(() {
                isInDarkMode = value;
                widget.onThemeChanged(isInDarkMode);
              });
            }
          )
        ],
      ),
    );
  }

  BottomNavigationBar bottomNavigationBar(ThemeData theme) {
    return BottomNavigationBar(
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favorites",
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }

  AvatarGlow voiceListeningButton(ThemeData theme){
    return AvatarGlow(
        animate: _speech.isListening,
        glowColor: theme.primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: _speech.isListening,
        child:FloatingActionButton(
          shape: CircleBorder(),
          onPressed: _speech.isListening ? _stopListening : _startListening,
          child: Icon(
            _speechEnabled? _speech.isListening ? Icons.mic : Icons.mic_none : Icons.mic_off,
            color: theme.cardColor,
          ),
          ),
      );
  }


  void _startListening() async {
      await _speech.listen(onResult: _onSpeechResult);
      setState(() {});
  }

  void _stopListening() {
    _speech.stop();
    setState(() {});
  }

  void _onSpeechResult(result){
    if(result.finalResult){
      String query = result.recognizedWords;
      print(query);
      String command = qs.QueryService.resolveQuery(query);
      switch(command){
        case 'search':
          setState(() {
            selectedIndex = 0;
            searchText = query.replaceAll(qs.QueryService.search, '');
          });
          _sendSearchQuery(searchText);
        case 'mainMenu':
          setState(() {
            selectedIndex = 0;
          });
        case 'favourites':
          setState(() {
            selectedIndex = 1;
          });
        case 'favourite':
          setState(() {
            selectedIndex = 1;
          });
        break;

        default:
        break;
      }
    }
    
  }

  void _sendSearchQuery(String query) {
    if (mounted && selectedIndex == 0) {
      print("sending signal...");
      // Update the AllRecipesView with search query
      _allRecipesView!.onSignalReceived(query);
    }
  }

}
  

