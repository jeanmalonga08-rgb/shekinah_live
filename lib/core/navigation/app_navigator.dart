import 'package:flutter/material.dart';

/// Clé du [Navigator] racine — pour les overlays globaux hors arbre Overlay
/// (ex. [OfflineDownloadBanner] dans [MaterialApp.builder]).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
