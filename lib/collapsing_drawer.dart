library collapsing_drawer;

import 'package:flutter/material.dart';

class CollapsingContainer extends StatefulWidget {
  final Widget body;
  final Widget drawer;
  final double drawerMaxWidth;
  final double drawerMinWidth;
  final AnimationController animationController;

  CollapsingContainer(
      {Key key, this.body, this.drawerMaxWidth, this.drawerMinWidth, this.animationController, this.drawer})
      : super(key: key);

  @override
  CollapsingContainerState createState() => CollapsingContainerState();
}

class CollapsingContainerState extends State<CollapsingContainer> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  var _drawer = GlobalKey<CollapsingDrawerState>();
  double openWidth;
  double collapsedWidth;

  @override
  void initState() {
    _controller = widget.animationController ?? AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    super.initState();
  }

  @override
  void dispose() {
    if (widget.animationController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (widget.drawerMaxWidth == null) {
      openWidth = MediaQuery.of(context).size.width * 0.6;
    } else {
      openWidth = widget.drawerMaxWidth;
    }

    if (widget.drawerMinWidth == null) {
      collapsedWidth = 80;
    } else {
      collapsedWidth = widget.drawerMinWidth;
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(CollapsingContainer oldWidget) {
    if (widget.drawerMaxWidth == null) {
      openWidth = MediaQuery.of(context).size.width * 0.6;
    } else {
      openWidth = widget.drawerMaxWidth;
    }

    if (widget.drawerMinWidth == null) {
      collapsedWidth = 80;
    } else {
      collapsedWidth = widget.drawerMinWidth;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            _controller.value += details.delta.dx / (openWidth - collapsedWidth);
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity.abs() > 500) {
              if (details.primaryVelocity >= 0) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            } else {
              if (_controller.value < 0.5) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            }
          },
          child: CollapsingDrawer(
            key: _drawer,
            collapsedWidth: collapsedWidth,
            openWidth: openWidth,
            animationController: _controller,
            child: widget.drawer,
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (_controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.forward) {
              _controller.value += details.delta.dx / (openWidth - collapsedWidth);
            }
          },
          onHorizontalDragEnd: (details) {
            if (_controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.forward) {
              if (details.primaryVelocity.abs() > 500) {
                if (details.primaryVelocity >= 0) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              } else {
                if (_controller.value < 0.5) {
                  _controller.reverse();
                } else {
                  _controller.forward();
                }
              }
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width - collapsedWidth,
            child: widget.body,
          ),
        )
      ],
    );
  }

  void switchState() {
    _drawer.currentState.switchState();
  }
}

class CollapsingDrawer extends StatefulWidget {
  //The width when the drawer is open.
  final double openWidth;
  //The width when the drawer is closed.
  final double collapsedWidth;
  final Widget child;
  final AnimationController animationController;

  CollapsingDrawer({
    Key key,
    @required this.openWidth,
    @required this.animationController,
    @required this.collapsedWidth,
    this.child,
  }) : super(key: key);

  @override
  CollapsingDrawerState createState() => CollapsingDrawerState();
}

class CollapsingDrawerState extends State<CollapsingDrawer> {
  Animation<double> _animation;
  bool isCollapsed = true;

  double openWidth;
  double collapsedWidth;

  @override
  void initState() {
    this.openWidth = widget.openWidth;
    this.collapsedWidth = widget.collapsedWidth;

    _animation = Tween<double>(begin: collapsedWidth, end: openWidth).animate(widget.animationController);

    widget.animationController.addListener(() {
      if (widget.animationController.status == AnimationStatus.completed) {
        isCollapsed = false;
      }

      if (widget.animationController.status == AnimationStatus.dismissed) {
        isCollapsed = true;
      }
    });

    super.initState();
  }

  @override
  void didUpdateWidget(CollapsingDrawer oldWidget) {
    if (widget.openWidth != null) {
      openWidth = widget.openWidth;
    }

    if (widget.collapsedWidth != null) {
      collapsedWidth = widget.collapsedWidth;
    }

    _animation = Tween<double>(begin: collapsedWidth, end: openWidth).animate(widget.animationController);

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
            width: _animation.value,
            height: double.infinity,
            child: widget.child,
          ),
    );
  }

  void switchState() {
    if (isCollapsed) {
      widget.animationController.forward();
    } else {
      widget.animationController.reverse();
    }

    isCollapsed = !isCollapsed;
  }
}
