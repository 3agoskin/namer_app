import 'dart:collection';
import 'dart:html';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

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
              seedColor:
                  Color.fromRGBO(17, 151, 228, 1)), // fromRGBO(17, 151, 228, 1)
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random().asString;

  void getNext() {
    current = WordPair.random().asString;
    notifyListeners();
  }

  var favorites = <String>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(String pair) {
    if (!favorites.contains(pair)) {
      throw UnimplementedError(
          'Try remove $pair from favorites, there is no such a pair');
    }
    favorites.remove(pair);
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

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                backgroundColor: Color.fromRGBO(245, 251, 255, 1),
                indicatorColor: Color.fromRGBO(173, 219, 246, 1),
                extended: constraints.maxWidth > 600,
                minExtendedWidth: 170,
                leading: FloatingActionButton.extended(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2000)),
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  splashColor: Color.fromRGBO(255, 224, 72, 1),
                  isExtended: constraints.maxWidth > 600,
                  onPressed: () => print('FAB'),
                  backgroundColor: Color.fromRGBO(255, 243, 183, 1),
                  label: Text(
                    'Create pair',
                    style: getTextStyle(selectedIndex),
                  ),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Color.fromRGBO(0, 39, 61, 1),
                    // opticalSize: 2,
                    size: 22,
                  ),
                ),
                destinations: [
                  NavigationRailDestination(
                      icon: Icon(
                        Icons.home_outlined,
                        color: Color.fromRGBO(0, 39, 61, 1),
                      ),
                      label: Text(
                        'Home',
                        style: getTextStyle(0),
                      ),
                      selectedIcon: Icon(Icons.home)),
                  NavigationRailDestination(
                      disabled: favorites.isEmpty,
                      icon: favorites.isEmpty
                          ? Icon(Icons.cancel_outlined,
                              color: favorites.isEmpty
                                  ? Color.fromRGBO(198, 229, 247, 1)
                                  : Color.fromRGBO(0, 39, 61, 1))
                          : Badge(
                              textStyle: theme.textTheme.labelSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                              textColor: theme.colorScheme.onPrimary,
                              backgroundColor: Colors.blueAccent.shade700,
                              label: Text(
                                  '${favorites.length > 9 ? '9+' : favorites.length}'),
                              child: Icon(Icons.favorite_outline),
                            ),
                      label: Text(favorites.isEmpty ? 'Empty' : 'Favorites',
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
                color: Color.fromRGBO(229, 246, 255, 1),
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
      child: Wrap(
        alignment: WrapAlignment.center,
        children: <Widget>[
          for (var pair in favorites)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Text(
                  pair,
                  semanticsLabel: pair,
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Onbourding(appState: appState),
          SizedBox(height: 15),
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

class Onbourding extends StatelessWidget {
  const Onbourding({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    final pair = appState.current;
    final favorites = appState.favorites;
    final isFavorite = favorites.contains(pair);
    final isOneFavoriteSaved = favorites.length > 1 && !isFavorite;
    var theme = Theme.of(context);
    var headerStyle = theme.textTheme.headlineSmall!.copyWith(
      color: Color.fromRGBO(17, 151, 228, 1),
      fontWeight: FontWeight.bold,
    );
    var leadStyle = theme.textTheme.bodyMedium!.copyWith(
      color: Color.fromRGBO(17, 151, 228, 1),
      fontWeight: FontWeight.bold,
    );
    return Card.filled(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            children: [
              Text(
                'Welcome to Namer App',
                style: headerStyle,
              ),
              SizedBox(
                height: 15,
              ),
              isOneFavoriteSaved
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Color.fromRGBO(17, 151, 228, 1),
                          size: 18,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Now you can see what you have saved',
                          style: leadStyle,
                        ),
                      ],
                    )
                  : Text(
                      isFavorite
                          ? '${favorites.length < 2 ? 'But if you change your mind, ' : 'Remeber, '}you can remove it!'
                          : 'Here you can like a pair and then save it',
                      style: leadStyle,
                    ),
              SizedBox(
                height: 15,
              ),
              Transform.rotate(
                  angle: (isOneFavoriteSaved ? 360 : 270) * math.pi / 180,
                  child: Icon(
                    isOneFavoriteSaved
                        ? Icons.done_all
                        : isFavorite
                            ? Icons.cancel_outlined
                            : Icons.arrow_back,
                    color: Color.fromRGBO(17, 151, 228, 1),
                    size: 36,
                  ))
            ],
          ),
        ));
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
    final pair = appState.current;
    final isFavorite = appState.favorites.contains(pair);
    final removeFavorite = appState.removeFavorite;
    return ElevatedButton(
      onPressed: () {
        if (isFavorite) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Saved pair'),
            backgroundColor: Colors.blueAccent.shade700,
            behavior: SnackBarBehavior.fixed,
            action: SnackBarAction(
                backgroundColor: Colors.white,
                textColor: Colors.blueAccent.shade700,
                label: 'Remove $pair',
                onPressed: () {
                  removeFavorite(pair);
                }),
          ));
        }
        appState.getNext();
      },
      child: Text(isFavorite ? 'Save' : 'Next'),
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
        letterSpacing: 1,
        fontWeight: FontWeight.bold,
        color: isFavorite
            ? theme.colorScheme.onPrimary
            : Color.fromRGBO(17, 151, 228, 1));

    return Tooltip(
      message: 'Press and get new pair of words',
      exitDuration: Duration(seconds: 1),
      verticalOffset: 60,
      waitDuration: Duration(seconds: 1),
      preferBelow: false,
      child: Card(
        color: isFavorite ? Colors.blueAccent.shade700 : Colors.white,
        child: InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            if (isFavorite) return;
            appState.getNext();
          },
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Text(
              pair,
              style: style,
              semanticsLabel: pair,
            ),
          ),
        ),
      ),
    );
  }
}
