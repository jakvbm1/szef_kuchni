import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:szef_kuchni_v2/services/save_and_open_pdf.dart';
import 'package:szef_kuchni_v2/services/recipe_pdf_api.dart';
import 'package:szef_kuchni_v2/services/query_service.dart' as qs;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class RecipeView extends StatefulWidget {
 final Recipe recipe;
  final DatabaseService dbService;
  

  RecipeView({super.key, required this.recipe, DatabaseService? dbService})
  : dbService = dbService ?? DatabaseService();

  @override
  State<RecipeView> createState() => _RecipeViewState(recipe: recipe, dbService: dbService);
}

class _RecipeViewState extends State<RecipeView> {
  _RecipeViewState({required this.recipe, required this.dbService});
  Recipe recipe;
  List<String> ingredients = [];
  bool ingredientsLoaded = false;
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  late FlutterTts flutterTts;
  int currentStep = 0;
  int stepsCount = 0;
  DatabaseService dbService;

  @override
  void initState() {
    setState(() {
      _loadIngredientsNames();
    });
    super.initState();
    _speech = stt.SpeechToText();
    initSpeech();
    flutterTts = FlutterTts();
    stepsCount = widget.recipe.stepsList.length;
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }


  Future<void> _loadIngredientsNames() async {
    ingredients = await dbService.getRecipeIngredients(recipe.id);
    setState(() {
      ingredientsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondaryContainer,
      appBar: recipeAppBar(context, theme),

      // VOICE LISTENING BUTTON
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton : voiceListeningButton(theme),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    foodStats(theme),
                    ingredientsDisplay(theme),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: widget.recipe.stepsList.map((step) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          step,
                          maxFontSize: 14,
                          minFontSize: 10,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar recipeAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      title: Text(widget.recipe.name),
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      actions: <Widget>[
        // pdf file creation
        IconButton(
          onPressed: () {
            createPDF();
          },
          icon: const Icon(Icons.picture_as_pdf),
        ),
        IconButton(
          icon: Icon(Icons.thumb_up,
              color: recipe.isFavourite ? Colors.blueAccent : Colors.black),
          onPressed: () {
            setState(() {
              //recipe.changeFavourite();
              recipe.isFavourite = !recipe.isFavourite;
              if(recipe.isFavourite)
              {
                dbService.addRecipeToFavourites(recipe.id);
              }
              else
              {
                dbService.remRecipeFromFavourites(recipe.id);
              }
            });

            String displayedText;
            if (recipe.isFavourite) {
              displayedText = 'added to favourites!';
            } else {
              displayedText = 'removed from favourites!';
            }

            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(displayedText)));
          },
        ),
      ],
    );
  }

  Padding foodStats(ThemeData theme) {
    List<String> nutrients = widget.recipe.nutrition
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim()
        .split(", ");

    String time;
    if (widget.recipe.minutes < 60) {
      time = '${widget.recipe.minutes} min';
    } else {
      time = "${widget.recipe.minutes ~/ 60}h ";
      if (widget.recipe.minutes % 60 != 0) {
        time += "${widget.recipe.minutes % 60}min";
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AutoSizeText(
                time,
                maxFontSize: 24,
                minFontSize: 20,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
              ),
              //to likely cos jest pojebane
              AutoSizeText(
                "${nutrients[0]} kcal\n"
                "${nutrients[5]}g total fat | of which saturated ${nutrients[1]}g\n"
                "${nutrients[2]}g carbohydrates | of which sugar ${nutrients[6]}g\n"
                "${nutrients[4]}g protein | ${nutrients[3]}g sodium",
                textAlign: TextAlign.center,
                maxFontSize: 18,
                minFontSize: 12,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding ingredientsDisplay(ThemeData theme) {
    if (ingredientsLoaded) {
      String ingr = '';

      for (int i = 0; i < ingredients.length; i++) {
        if (i == ingredients.length - 1) {
          ingr += ingredients[i];
        } else {
          ingr += "${ingredients[i]},  ";
        }
      }
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const AutoSizeText(
                  'Ingredients',
                  maxFontSize: 22,
                  minFontSize: 16,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                AutoSizeText(
                  ingr,
                  maxFontSize: 14,
                  minFontSize: 10,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.indigo[200]),
          height: 150,
          child: Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }
  }

  ListView stepsList(ThemeData theme) {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10),
      itemCount: widget.recipe.stepsList.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: AutoSizeText(
              maxFontSize: 14,
              minFontSize: 10,
              widget.recipe.stepsList[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
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
        case 'favourite' :
          setState(() {
            recipe.changeFavourite();
          });

          String displayedText;
          if (recipe.isFavourite) {
            displayedText = 'added to favourites!';
          } else {
            displayedText = 'removed from favourites!';
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(displayedText)));

          break;

        case 'saveAsPDF':
          createPDF();
          break;

        case 'readNext':
          if(currentStep == stepsCount){
            _speak("That was the last step");
            break;
          }
          _speak("Next step: ${recipe.stepsList[currentStep]}");
          currentStep++;
          break;

        case 'readPrevious':
          if(currentStep == 0){
            _speak("That was the first step");
            break;
          }
          currentStep--;
          _speak("Previous step: ${recipe.stepsList[currentStep]}");
          break;

        case 'readIngredients':
          _speak("Ingredients: $ingredients");
          break;

        case 'mainMenu':
          Navigator.pop(context);
          break;

        default:
          break;

      }
      setState(() {});
    }
  }

  Future<void> _speak(String text) async {
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void createPDF() async{
    final simplePdfFile =
      await RecipePdfApi.generateRecipePdf(recipe, ingredients);
    SaveAndOpenPdf.openPdf(simplePdfFile);
  }

}
