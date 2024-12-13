import 'dart:async';
import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/models/recipe_model.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';
import 'package:szef_kuchni_v2/views/recipe_view.dart';

class AllRecipesView extends StatefulWidget{
  const AllRecipesView({super.key});

  @override
  State<AllRecipesView> createState() => _AllRecipesViewState();
}

class _AllRecipesViewState extends State<AllRecipesView> {
  //=====================================================
  //================== VARIABLES ========================
  //=====================================================
  
  // Use this to import databaseService functionality
  final DatabaseService databaseService = DatabaseService();
  // Sets a trigger that is used to load more recipes with pagination
  final ScrollController _scrollController = ScrollController();
  // List of recipes that are displayed in the view
  List<Recipe> _recipes = [];
  // List of all ingredients names
  List<String> _ingredientsNames = [];
  // List of all categories names
  List<String> _categoriesNames = [];

  // Pagination variables
  bool _isLoading = false;
  bool _hasMore = true;
  int _batchNumber = 0;
  static const int _batchSize = 40;
  bool _isSearching = false;
  Timer? _debounce;

  // State of filters expansion panel
  bool expansionPanelState = false;

  // fliter parameters for searching recipes
  int _minTime = 0;
  int _maxTime = 0;
  final List<String> _selectedIngredients = [];
  final List<String> _selectedCategories = [];

  //=====================================================
  //================== FUNCTIONS ========================
  //=====================================================

  // Called when the view is created
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreRecipes();
    _loadIngredientsNames();
    _loadCategoriesNames();
  }

  // Called when the view is destroyed
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // loads all the ingredient names
  Future<void> _loadIngredientsNames() async {
    _ingredientsNames = await databaseService.getIngredientsNames();
  }

  // loads all the category names
  Future<void> _loadCategoriesNames() async {
    _categoriesNames = await databaseService.getCategoriesNames();
  }

  // Called when the _scrollController trigger is activated
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreRecipes();
    }
  }

  // loads more recipes when _onScroll is called
  Future<void> _loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final newRecipes = await databaseService.getRecipeNames(
      batchNumber: _batchNumber,
      batchSize: _batchSize,
      minTime: _minTime,
      maxTime: _maxTime,
      selectedIngredients: _selectedIngredients,
      selectedCategories: _selectedCategories,
    );
    
    setState(() {
      if (newRecipes.isEmpty) {
        _hasMore = false;
      } else {
        _recipes.addAll(newRecipes);
        _batchNumber += 1;
      }
      _isLoading = false;
    });
  }

  // displays search results based on keyword entered in searchbar,
  // replaces the current list of recipee names with the new one
  // is called every time a new letter is typed in searchbar
  Future<void> _displaySearchResults(String enteredKeyword) async {
    setState(() {
      _isLoading = true;
      _recipes.clear(); // Clear existing recipes
    });

    final newRecipes = await databaseService.getRecipeNames(
      batchNumber: _batchNumber,
      batchSize: _batchSize,
      minTime: _minTime,
      maxTime: _maxTime,
      selectedIngredients: _selectedIngredients,
      selectedCategories: _selectedCategories,
      enteredKeyword: enteredKeyword,
    );
    
    setState(() {
      _recipes = newRecipes;
      _isLoading = false;
      _isSearching = false;
      _hasMore = false; // Disable pagination for search results
      _batchNumber = 0; // Reset pagination counter
    });
  }

  void _displaySearchResultsWithDelay(String value) {
    setState(() {
      _isSearching = true;
    });
    // Cancel the previous timer if it's still active
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Start a new timer
    _debounce = Timer(const Duration(seconds: 1), () {
      _displaySearchResults(value);
    });
  }

  //=====================================================
  //================== COMPONENTS =======================
  //=====================================================

  // MAIN BUILD FUNCTION
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    
    // LayoutBuilder is used to get the height of the view
    // height is used to determine the height of the filter panel
    // i dont like this and i want to change it later
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double viewHeight = constraints.maxHeight;
        return Scaffold(
          backgroundColor: theme.colorScheme.secondaryContainer,
          // MAIN COLUMN
          body: Column(
            children: <Widget>[

              searchBar(),

              filtersExpandablePanel(theme, viewHeight, constraints),

              _isSearching
              ? loadingDisplay(theme)
              : recipesDisplay(theme)
            ]
          ),
        );
      }
    );
  }

  // MAIN SEARCH BAR
  Padding searchBar() {
    return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged:(value) => _displaySearchResultsWithDelay(value),
                    decoration: const InputDecoration(
                      label: Text(
                        "Wyszukaj po nazwie",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            );
  }

  // FILTERS PANEL
  ExpansionPanelList filtersExpandablePanel(ThemeData theme, double viewHeight, BoxConstraints constraints) {
    return ExpansionPanelList(
      children: [
        ExpansionPanel(
          backgroundColor: theme.colorScheme.surfaceContainerHigh,
          headerBuilder: (context, isOpen) {
            return const ListTile(
              title: Text(
                "Filtry",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              visualDensity: VisualDensity.compact,
            );
          },
          isExpanded: expansionPanelState,

          // BODY OF FILTER SETTINGS PANEL
          body: SizedBox(
            height: viewHeight * 0.75, // it needs to be a fixed height, code breaks otherwise
            child: SingleChildScrollView(

              // MAIN FILTER SETTINGS COLUMN
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // TIME SETTING OBJECT
                  Container(
                    width: constraints.maxWidth,
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.onSurface,
                        )
                      ),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Czas przygotowania"),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  _minTime = 0; 
                                } else {
                                  _minTime = int.parse(value);
                                }
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                label: Text(
                                  "Od",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  _maxTime = 0; // or any default value you prefer
                                } else {
                                  _maxTime = int.parse(value);
                                }
                              },
                              decoration: const InputDecoration(
                                isDense: true,
                                label: Text(
                                  "Do",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // INGREDIENTS SETTING OBJECT
                  Container(
                    width: constraints.maxWidth,
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: theme.colorScheme.onSurface,
                        )
                      ),
                    ),
                    child: filterComponentWithSearchBar(theme, "Składniki", "wyszukaj składnik", _ingredientsNames, _selectedIngredients),
                  ),
                  
                  // CATEGORIES SETTING OBJECT
                  Container(
                    width: constraints.maxWidth,
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.onSurface,
                        )
                      )
                    ),
                    child: filterComponentWithSearchBar(theme, "Kategorie", "wyszukaj kategorie", _categoriesNames, _selectedCategories),
                  ),

                  // APPLY FILTERS BUTTON
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _recipes.clear();
                        _batchNumber = 0;
                        _loadMoreRecipes();
                        expansionPanelState = false;
                      });
                    }, 
                    child: const Text(
                      "Zastosuj filtry",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      expansionCallback: (panelIndex, isExpanded) {
        setState(() {
          expansionPanelState = !expansionPanelState;
        });
      },
    );
  }
  
  // FILTERS PANEL COMPONENT - FILTER COMPONENT WITH SEARCH BAR
  // Ingredients filter component and category filter component were basically the same
  // so i made a function that efficiently creates them with only few given parameters
  Column filterComponentWithSearchBar(ThemeData theme, String labelName, String hintLabelName, List<String> autocompeteDataList, List<String> selectedDataList) {
    late TextEditingController textEditingController;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(labelName),
              const SizedBox(width: 8),
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return autocompeteDataList.where((object) => object.contains(textEditingValue.text));
                  },
                  onSelected: (String selectedResult) {
                    setState(() {
                      if (selectedDataList.contains(selectedResult)) {
                        textEditingController.text = "";
                        return;
                      }
                      selectedDataList.add(selectedResult);
                      textEditingController.text = "";
                    });
                  },
                  fieldViewBuilder: (
                  BuildContext context, 
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode, 
                  VoidCallback onFieldSubmitted) {
                    textEditingController = fieldTextEditingController;
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        isDense: true,
                        hintText: hintLabelName,
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: selectedDataList.map((object) => Card(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    object,
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDataList.remove(object);
                      if (labelName == "Składniki") {
                        _selectedIngredients.remove(object);
                      } else if (labelName == "Kategorie") {
                        _selectedCategories.remove(object);
                      }
                    });
                  },
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  // MAIN RECIPES: DISPLAY
  Expanded recipesDisplay(ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          color: theme.colorScheme.surfaceContainerHigh,
          child: 
            _recipes.isNotEmpty
            ? ListView.builder(
                controller: _scrollController,
                itemCount: _recipes.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {

                  // Displays loading indicator when loading from database is not finished
                  // im not sure if it works correctly
                  if (index >= _recipes.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ); 
                  }
                  // Displays recipe tiles
                  // this need to be changed to a recipe button that opens a recipe view
                  return GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Card(
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: recipeTile(index, theme),
                        ),
                      ),
                    ),
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeView(recipe: _recipes[index])));},
                  );
                },
              )
            : const Center(
                child: Text("No results"),
              )
        ),
      ),
    );
  }

  // MAIN RECIPES: RECIPE TILE
  Column recipeTile(int index, ThemeData theme) {
    return Column(
      children: [
       // Text(_recipes[index].id.toString(),),
        Text(_recipes[index].name,),
        //Text(_recipes[index].minutes.toString(),),
        //Text(_recipes[index].nutrition,),
        //Text(_recipes[index].steps,),
        Text(_recipes[index].isFavourite.toString(),),
      ],
    );
  }

  Expanded loadingDisplay(ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          color: theme.colorScheme.surfaceContainerHigh,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}