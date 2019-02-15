# collapsing_drawer

A drawer than can be collapsed.

![Demon](https://github.com/shinayser/collapsing_drawer/blob/master/thegif.gif)

### Basic usage

1. Add the import:
```import 'package:collapsing_drawer/collapsing_drawer.dart';```

Then you just add a **CollapsingContainer** to your Scaffold's body like this:
```
class TestesCollapsingContainer extends StatefulWidget {
  @override
  TestesCollapsingContainerState createState() => TestesCollapsingContainerState();
}

class TestesCollapsingContainerState extends State<TestesCollapsingContainer> with SingleTickerProviderStateMixin {
  final _drawer = GlobalKey<CollapsingContainerState>();
  
  //This controller optional. Use only if you want to share the animation with other widgets like the "JustATile" (below)
  AnimationController animationController;
   
  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: millis(100));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        CollapsingContainer(
          key: _drawer,
          animationController: animationController,
          body: SafeArea(
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) => ListTile(title: Text("A text on the side")),
            ),
          ),
          drawer: SafeArea(
            child: Material(
              color: Colors.blue,
              elevation: 4,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) => JustATile(animationController, index),
                      itemCount: 30,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  IconButton(
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      progress: animationController,
                    ),
                    onPressed: () {
                      _drawer.currentState.switchState();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  void _openCloseDrawer() {
    _drawer.currentState.switchState();
  }

}

```

A sample of a tile you can use on it:
```

class JustATile extends StatefulWidget {
  final AnimationController animationController;
  final int index;

  JustATile(this.animationController, this.index);

  @override
  _JustATileState createState() => _JustATileState();
}

class _JustATileState extends State<JustATile> {
  Animation<double> _animation;

  @override
  void initState() {
    _animation = Tween<double>(begin: 1.0, end: 0).animate(widget.animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (BuildContext context, Widget child) {
        return ListTile(
          onTap: () {
            print("You tapped");
          },
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
          ),
          title: Opacity(
            opacity: 1 - _animation.value,
            child: Text(
              "Title at ${widget.index}",
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
        );
      },
      animation: _animation,
    );
  }
}
```