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

  void addFavorite(String pair) {
    favorites.add(pair);
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

    Widget page(BoxConstraints constraints) {
      switch (selectedIndex) {
        case 0:
          return GeneratorPage();
        case 1:
          return FavoritePage(
            constraints: constraints,
          );
        default:
          throw UnimplementedError('No widget for $selectedIndex');
      }
      ;
    }

    var theme = Theme.of(context);
    TextStyle getTextStyle(int index, {bool isFAB = false}) {
      var isSelected = index == selectedIndex;
      return theme.textTheme.labelMedium!.copyWith(
          color: isFAB
              ? Colors.white
              : isSelected
                  ? Colors.black
                  : Colors.black45,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.bold);
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
                trailing: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FloatingActionButton.extended(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2000)),
                        elevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        highlightElevation: 0,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        splashColor: Colors.blueAccent.shade700,
                        isExtended: constraints.maxWidth > 600,
                        backgroundColor: Colors.blueAccent.shade400,
                        onPressed: () {
                          showDialog(
                              barrierDismissible: true,
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                var appState = context.watch<MyAppState>();
                                var theme = Theme.of(context);
                                return Scaffold(
                                  drawerEdgeDragWidth: 200,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  body: CreateNewPairDialog(
                                    appState: appState,
                                    theme: theme,
                                    constraints: constraints,
                                  ),
                                );
                              });
                        },
                        label: Text(
                          'Create pair',
                          style: getTextStyle(selectedIndex, isFAB: true),
                        ),
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          // opticalSize: 2,
                          size: 22,
                        ),
                      ),
                    ),
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
                child: page(constraints),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CreateNewPairDialog extends StatelessWidget {
  const CreateNewPairDialog({
    super.key,
    required this.appState,
    required this.theme,
    required this.constraints,
  });

  final MyAppState appState;
  final ThemeData theme;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.blueAccent.shade700,
      shadowColor: Colors.transparent,
      child: SizedBox(
        height: 500,
        width: constraints.maxWidth > 600 ? 600 : null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BackButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(72),
                child: CreateNewPairField(appState: appState, theme: theme),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CreateNewPairField extends StatefulWidget {
  const CreateNewPairField({
    super.key,
    required this.appState,
    required this.theme,
  });

  final MyAppState appState;
  final ThemeData theme;

  @override
  State<CreateNewPairField> createState() => _CreateNewPairFieldState();
}

class _CreateNewPairFieldState extends State<CreateNewPairField> {
  String pairInput = '';
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var decoration = InputDecoration(
        hintStyle:
            widget.theme.textTheme.titleMedium!.copyWith(color: Colors.white60),
        labelStyle:
            widget.theme.textTheme.titleMedium!.copyWith(color: Colors.white),
        counterStyle:
            widget.theme.textTheme.titleMedium!.copyWith(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(200)),
          borderSide: BorderSide(width: 2, color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.blueAccent.shade100),
            borderRadius: BorderRadius.all(Radius.circular(200)),
            gapPadding: 100),
        border: OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(200)),
            gapPadding: 100),
        hintText: 'Creat your pair!');

    return Column(
      children: [
        TextField(
            style: widget.theme.textTheme.titleMedium!
                .copyWith(color: Colors.white),
            cursorColor: Colors.white,
            autofocus: true,
            onSubmitted: (pair) {
              if (pair.length > 2) {
                widget.appState.addFavorite(pair);
                ScaffoldMessenger.of(context).showSnackBar(snackBarNewPair(
                    theme: widget.theme,
                    pair: pair,
                    appState: widget.appState));
                Navigator.pop(context);
              }
            },
            decoration: decoration,
            onChanged: (value) {
              setState(() {
                pairInput = value;
              });
            }),
        SizedBox(
          height: 15,
        ),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    pairInput.length > 2 ? Colors.white : Colors.white54),
                foregroundColor: MaterialStateProperty.all(
                  pairInput.length > 2
                      ? Colors.blueAccent.shade400
                      : Colors.blueAccent.shade200,
                ),
                padding: MaterialStateProperty.all(EdgeInsets.all(18)),
                elevation: MaterialStateProperty.all(0),
                textStyle: MaterialStateProperty.all(
                    theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ))),
            onPressed: () {
              if (pairInput.length > 2) {
                widget.appState.addFavorite(pairInput);
                ScaffoldMessenger.of(context).showSnackBar(snackBarNewPair(
                    theme: widget.theme,
                    pair: pairInput,
                    appState: widget.appState));
                Navigator.pop(context);
              }
            },
            child: Text('Add to favorite'))
      ],
    );
  }
}

SnackBar snackBarNewPair(
    {required String pair,
    required MyAppState appState,
    required ThemeData theme}) {
  var pairStyle = theme.textTheme.bodyMedium!.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );
  return SnackBar(
    padding: EdgeInsets.fromLTRB(18, 24, 12, 24),
    content: Row(
      children: [
        Text('Saved'),
        SizedBox(
          width: 6,
        ),
        Text(
          pair,
          style: pairStyle,
        )
      ],
    ),
    backgroundColor: Colors.blueAccent.shade700,
    behavior: SnackBarBehavior.fixed,
    action: SnackBarAction(
        backgroundColor: Colors.white,
        textColor: Colors.blueAccent.shade700,
        label: 'Remove pair',
        onPressed: () {
          appState.removeFavorite(pair);
        }),
  );
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          OnbourdingGeneratorPage(appState: appState),
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

class OnbourdingGeneratorPage extends StatelessWidget {
  const OnbourdingGeneratorPage({
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
                  ? Wrap(
                      spacing: 12,
                      alignment: WrapAlignment.center,
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Color.fromRGBO(17, 151, 228, 1),
                          size: 18,
                        ),
                        Text(
                          'Now you can see what you have saved',
                          style: leadStyle,
                          softWrap: true,
                        ),
                      ],
                    )
                  : Text(
                      isFavorite
                          ? '${favorites.length < 2 ? 'But if you change your mind, ' : 'Remeber, '}you can remove it!'
                          : 'Here you can like a pair and then save it',
                      style: leadStyle,
                      textAlign: TextAlign.center,
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
    var theme = Theme.of(context);
    return ElevatedButton(
      onPressed: () {
        if (isFavorite) {
          ScaffoldMessenger.of(context).showSnackBar(
              snackBarNewPair(pair: pair, appState: appState, theme: theme));
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

class FavoritePage extends StatelessWidget {
  FavoritePage({super.key, required this.constraints});

  BoxConstraints constraints;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var theme = Theme.of(context);
    var isDesktop = constraints.maxWidth > 600;
    var style = isDesktop
        ? theme.textTheme.headlineLarge!
            .copyWith(color: Colors.white, fontWeight: FontWeight.bold)
        : theme.textTheme.headlineMedium!
            .copyWith(color: Colors.white, fontWeight: FontWeight.bold);

    return Center(
      child: Column(
        children: [
          SizedBox(height: 30),
          DescriptionFavoritePage(appState: appState, isDesktop: isDesktop),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 12),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (var pair in favorites)
                  FavoriteCard(
                      isDesktop: isDesktop,
                      pair: pair,
                      style: style,
                      appState: appState),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.isDesktop,
    required this.pair,
    required this.style,
    required this.appState,
  });

  final bool isDesktop;
  final String pair;
  final TextStyle style;
  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Colors.blueAccent.shade700,
      child: InkWell(
        onTap: () {
          showDialog(
              barrierDismissible: true,
              barrierColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                var appState = context.watch<MyAppState>();
                var theme = Theme.of(context);
                var stylePair = theme.textTheme.displayMedium!.copyWith(
                    color: Color.fromRGBO(17, 151, 228, 1),
                    fontWeight: FontWeight.bold);
                return Scaffold(
                    drawerEdgeDragWidth: 200,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    body: Dialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      child: SizedBox(
                        height: 500,
                        width: 500,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: CloseButton(
                                    color: Color.fromRGBO(17, 151, 228, 1),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(72),
                                  child: Column(
                                    children: [
                                      Text(
                                        pair,
                                        style: stylePair,
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                          onPressed: () {
                                            appState.removeFavorite(pair);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Remove'))
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                    ));
              });
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 18),
          child: Text(
            pair,
            semanticsLabel: pair,
            style: style,
          ),
        ),
      ),
    );
  }
}

class DescriptionFavoritePage extends StatelessWidget {
  const DescriptionFavoritePage(
      {super.key, required this.isDesktop, required this.appState});

  final bool isDesktop;
  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var headerStyle = theme.textTheme.headlineSmall!.copyWith(
      color: Color.fromRGBO(17, 151, 228, 1),
      fontWeight: FontWeight.bold,
    );
    var leadStyle = theme.textTheme.bodyMedium!.copyWith(
      color: Color.fromRGBO(17, 151, 228, 1),
      fontWeight: FontWeight.bold,
    );
    final totalFavorites = appState.favorites.length;
    return Card.filled(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          children: [
            Text(
              totalFavorites > 1
                  ? 'Here are all your $totalFavorites favorite pairs'
                  : 'Here are yout favorite pair',
              style: headerStyle,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'But if you want to delete your pair, just tap on it!',
              style: leadStyle,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
            SizedBox(
              height: 15,
            ),
            Transform.rotate(
                angle: -25 * math.pi / 180,
                child: Icon(
                  Icons.touch_app_outlined,
                  color: Colors.blueAccent.shade200,
                  size: 52,
                ))
          ],
        ),
      ),
    );
  }
}
