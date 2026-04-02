import 'package:flutter/material.dart';

/// Observes route changes so screens can refresh when popped back to.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
