import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

class InstallAppBanner extends StatefulWidget {
  final Widget child;
  const InstallAppBanner({super.key, required this.child});

  @override
  State<InstallAppBanner> createState() => _InstallAppBannerState();
}

class _InstallAppBannerState extends State<InstallAppBanner>
    with SingleTickerProviderStateMixin {
  bool _show = false;
  bool _isIos = false;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    if (kIsWeb) {
      _checkInstallEligibility();
    }
  }

  void _checkInstallEligibility() {
    final ua = web.window.navigator.userAgent.toLowerCase();

    // Already running as installed PWA — don't show
    final isStandalone = _callJsBool('isRunningAsPwa');
    if (isStandalone) return;

    final isAndroid = ua.contains('android');
    final isIos = (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod'));

    if (!isAndroid && !isIos) return; // Desktop — skip

    setState(() {
      _isIos = isIos;
      _show = true;
    });
    _slideCtrl.forward();
  }

  bool _callJsBool(String functionName) {
    try {
      final result = web.window.getProperty(functionName.toJS);
      if (result != null && result.isA<JSFunction>()) {
        final fn = result as JSFunction;
        final callResult = fn.callAsFunction();
        if (callResult != null && callResult.isA<JSBoolean>()) {
          return (callResult as JSBoolean).toDart;
        }
      }
    } catch (_) {}
    return false;
  }

  bool _callJsTriggerInstall() {
    try {
      final result = web.window.getProperty('triggerPwaInstall'.toJS);
      if (result != null && result.isA<JSFunction>()) {
        final fn = result as JSFunction;
        final callResult = fn.callAsFunction();
        if (callResult != null && callResult.isA<JSBoolean>()) {
          return (callResult as JSBoolean).toDart;
        }
      }
    } catch (_) {}
    return false;
  }

  void _onInstallTap() {
    if (_isIos) {
      _showIosInstructions();
    } else {
      final triggered = _callJsTriggerInstall();
      if (!triggered) {
        _showManualInstructions();
      }
    }
    _dismiss();
  }

  void _dismiss() {
    _slideCtrl.reverse().then((_) {
      if (mounted) setState(() => _show = false);
    });
  }

  void _showIosInstructions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.ios_share_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 16),
            const Text(
              'Install NewsFeed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                children: [
                  TextSpan(text: 'Tap the '),
                  WidgetSpan(
                    child: Icon(Icons.ios_share_rounded, color: Colors.white, size: 18),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(text: ' Share button in your browser, then select '),
                  TextSpan(
                    text: '"Add to Home Screen"',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6472B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualInstructions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.more_vert_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 16),
            const Text(
              'Install NewsFeed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                children: [
                  TextSpan(text: 'Tap the '),
                  WidgetSpan(
                    child: Icon(Icons.more_vert_rounded, color: Colors.white, size: 18),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(text: ' menu in Chrome, then select '),
                  TextSpan(
                    text: '"Install app"',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(text: ' or '),
                  TextSpan(
                    text: '"Add to Home Screen"',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6472B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_show)
          SlideTransition(
            position: _slideAnim,
            child: Material(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF2A1A3E)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      // App icon
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6472B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('N',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Install NewsFeed App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Get a faster, app-like experience',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Install button
                      ElevatedButton(
                        onPressed: _onInstallTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6472B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Install',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Close
                      GestureDetector(
                        onTap: _dismiss,
                        child: const Icon(Icons.close, color: Colors.white38, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
