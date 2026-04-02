import 'package:flutter/material.dart';

import '../app/app_route_observer.dart';

/// Rebuilds [child] when this route was covered and becomes visible again
/// (e.g. after the user pops back). Fixes stale auth-dependent UI like the
/// account menu on [HomeScreen].
class RouteAwareRefresh extends StatefulWidget {
  const RouteAwareRefresh({required this.child, super.key});

  final Widget child;

  @override
  State<RouteAwareRefresh> createState() => _RouteAwareRefreshState();
}

class _RouteAwareRefreshState extends State<RouteAwareRefresh> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
