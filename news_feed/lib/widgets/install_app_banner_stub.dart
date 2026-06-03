import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms.
/// Just passes through the child widget with no install banner.
class InstallAppBanner extends StatelessWidget {
  final Widget child;
  const InstallAppBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
