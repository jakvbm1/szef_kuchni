class QueryService {

  //Comand Dictionary
  static RegExp search = RegExp(r'(poszukaj|szukaj|wyszukaj|search|search for)');
  static RegExp favourite = RegExp(r'(polub|dodaj to ulubionych|favourite|favorite|add to favourites|add to favorites|like|usuń z ulubionych|remove from favourites|remove from favorites|unlike)');
  static RegExp saveAsPDF = RegExp(r'(zapisz|zapisz jako pdf|save|save as pdf)');
  static RegExp readNext = RegExp(r'(czytaj kolejny|kolejny krok|następny krok|dalej|czytaj kolejny krok|przeczytaj|przeczytaj kolejny krok|read next|read the next step|next step|next)');
  static RegExp readPrevious = RegExp(r'(czytaj poprzedni|czytaj poprzedni krok|wróć|read the previous step|previous step|previous|go back)');
  static RegExp readIngredients = RegExp(r'(składniki|przeczytaj składniki|ingredients|read ingredients)');
  static RegExp favourites = RegExp(r'(ulubione|ulubionych|favourites page|favorites page)');
  static RegExp mainMenu = RegExp(r'(ekran główny|menu główne|main menu)');

  static String resolveQuery(String query){
    var answer = '';
    query = query.toLowerCase();
    
    if (query.contains(search)){
      answer = 'search';
    } 
    else if(query.contains(favourite)){
        answer = 'favourite';
    }
    else if(query.contains(saveAsPDF)){
      answer = 'saveAsPDF';
    }
    else if(query.contains(readNext)){
      answer = 'readNext';
    }
    else if(query.contains(readPrevious)){
      answer = 'readPrevious';
    }
    else if(query.contains(readIngredients)){
      answer = 'readIngredients';
    }
    else if(query.contains(favourites)){
      answer = 'favourites';
    }
    else if(query.contains(mainMenu)){
      answer = 'mainMenu';
    }

    return answer;
  }


}