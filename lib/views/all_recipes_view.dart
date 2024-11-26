import 'package:flutter/material.dart';
import 'package:szef_kuchni_v2/models/name.dart';
import 'package:szef_kuchni_v2/services/database_service.dart';

class AllRecipesView extends StatefulWidget{
  const AllRecipesView({super.key});

  @override
  State<AllRecipesView> createState() => _AllRecipesViewState();
}

class _AllRecipesViewState extends State<AllRecipesView> {
  final DatabaseService databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();
  List<NameModel> _recipes = [];
  List<String> _ingredientsNames = [];
  List<String> _categoriesNames = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool expansionPanelState = false;
  int _lastLoadedId = 0;
  static const int _batchSize = 40;

  // flitering parameters
  final int _minTime = 0;
  final int _maxTime = 0;
  final List<String> _selectedIngredients = [];
  final List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMoreRecipes();
    _loadIngredientsNames();
    _loadCategoriesNames();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreRecipes();
    }
  }

  Future<void> _loadIngredientsNames() async {
    _ingredientsNames = await databaseService.getIngredientsNames();
  }

  Future<void> _loadCategoriesNames() async {
    _categoriesNames = await databaseService.getCategoriesNames();
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    final newRecipes = await databaseService.getRecipeNames(
      fromId: _lastLoadedId + 1,
      toId: _lastLoadedId + _batchSize
    );
    
    setState(() {
      if (newRecipes.isEmpty) {
        _hasMore = false;
      } else {
        _recipes.addAll(newRecipes);
        _lastLoadedId = newRecipes.last.id;
      }
      _isLoading = false;
    });
  }

  Future<void> _loadSearchResults(String enteredKeyword) async {
    setState(() {
      _isLoading = true;
      _recipes.clear(); // Clear existing recipes
    });

    final newRecipes = await databaseService.getFilteredResults(enteredKeyword);
    
    setState(() {
      _recipes = newRecipes;
      _isLoading = false;
      _hasMore = false; // Disable pagination for search results
      _lastLoadedId = 0; // Reset pagination counter
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double viewHeight = constraints.maxHeight;
        return Scaffold(
          backgroundColor: theme.colorScheme.secondaryContainer,
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged:(value) => _loadSearchResults(value),
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
              ),
              ExpansionPanelList(
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
                    body: SizedBox(
                      height: viewHeight * 0.75,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                              child: const Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Czas przygotowania"),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
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
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
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
                              child: filterComponentWithSearchBar(theme, "Składniki", _ingredientsNames, _selectedIngredients),
                            ),
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
                              child: filterComponentWithSearchBar(theme, "Kategorie", _categoriesNames, _selectedCategories),
                            )
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
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    color: theme.colorScheme.surfaceContainerHigh,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _recipes.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _recipes.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Card(
                            color: theme.colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(
                                _recipes[index].name,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ]
          ),
        );
      }
    );
  }

  // WIDOK FILTRU Z WYSZUKIWARKĄ
  Column filterComponentWithSearchBar(ThemeData theme, String labelName, List<String> autocompeteDataList, List<String> selectedDataList) {
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
                        hintText: "wyszukaj składnik",
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                object,
                textAlign: TextAlign.center,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}