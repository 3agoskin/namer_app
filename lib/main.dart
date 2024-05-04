import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue), // fromRGBO(17, 151, 228, 1)
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    var theme = Theme.of(context);
    TextStyle getTextStyle(int index) {
      return theme.textTheme.labelMedium!.copyWith(
          fontWeight:
              index == selectedIndex ? FontWeight.bold : FontWeight.normal);
    }
    // var style = theme.textTheme.displayMedium!.copyWith(
    //     color: isFavorite
    //         ? theme.colorScheme.onPrimary
    //         : theme.colorScheme.primary);

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth > 600,
                minExtendedWidth: 170,
                leading: FloatingActionButton.extended(
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  isExtended: constraints.maxWidth > 600,
                  onPressed: () => print('FAB'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  label: Text('Create pair'),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                destinations: [
                  NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      label: Text(
                        'Home',
                        style: getTextStyle(0),
                      ),
                      selectedIcon: Icon(Icons.home)),
                  NavigationRailDestination(
                      disabled: favorites.isEmpty,
                      icon: favorites.isEmpty
                          ? Icon(Icons.exposure_zero)
                          : Icon(Icons.favorite_outline),
                      label: Text(
                          favorites.isEmpty
                              ? 'No favorites'
                              : 'Favorites (${favorites.length})',
                          style: getTextStyle(1)),
                      selectedIcon: Icon(Icons.favorite)),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var pair in favorites)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Click on card to go next ${appState.favorites}'),
          SizedBox(height: 80),
          BigCard(appState: appState),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeButton(
                appState: appState,
              ),
              SizedBox(width: 10),
              NextButton(appState: appState),
            ],
          ),
        ],
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        appState.getNext();
      },
      child: Text('Next'),
    );
  }
}

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    void _incrementEnter(PointerEvent details) {
      setState(() {
        _hover = true;
      });
    }

    void _incrementExit(PointerEvent details) {
      setState(() {
        _hover = false;
      });
    }

    final pair = widget.appState.current;
    final isFavorite = widget.appState.favorites.contains(pair);
    Icon setIcon() {
      IconData icon;
      if (_hover) {
        icon = isFavorite ? Icons.cancel : Icons.favorite;
      } else {
        icon = isFavorite ? Icons.cancel_outlined : Icons.favorite_outline;
      }
      return Icon(icon);
    }

    String text = isFavorite ? 'Remove' : 'Like';

    return MouseRegion(
      onEnter: (event) => _incrementEnter(event),
      onExit: (event) => _incrementExit(event),
      child: ElevatedButton.icon(
          onPressed: () => widget.appState.toggleFavorite(),
          icon: setIcon(),
          label: Text(text)),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    final pair = appState.current;
    final isFavorite = appState.favorites.contains(pair);

    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
        color: isFavorite
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary);

    return Tooltip(
      message: 'Press and get new pair of words',
      exitDuration: Duration(seconds: 1),
      verticalOffset: 60,
      waitDuration: Duration(seconds: 1),
      preferBelow: false,
      child: Card(
        color:
            isFavorite ? theme.colorScheme.primary : theme.colorScheme.surface,
        child: InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () => appState.getNext(),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Text(
              pair.asLowerCase,
              style: style,
              semanticsLabel: pair.asPascalCase,
            ),
          ),
        ),
      ),
    );
  }
}
