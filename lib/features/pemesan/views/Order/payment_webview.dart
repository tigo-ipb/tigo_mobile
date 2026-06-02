import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String title;

  const PaymentWebView({
    super.key,
    required this.url,
    this.title = 'Pembayaran Tiket',
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Can be used for progress indicators if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Detect redirection to success/callback URLs (e.g. Xendit or Tigo payment success redirect)
            final lowercaseUrl = url.toLowerCase();
            if (lowercaseUrl.contains('success') ||
                lowercaseUrl.contains('complete') ||
                lowercaseUrl.contains('callback') ||
                lowercaseUrl.contains('selesai')) {
              Navigator.pop(context, true);
            }
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            final lowercaseUrl = request.url.toLowerCase();
            if (lowercaseUrl.contains('success') ||
                lowercaseUrl.contains('complete') ||
                lowercaseUrl.contains('callback') ||
                lowercaseUrl.contains('selesai')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.close, color: AppColors.neutral950),
          onPressed: () =>
              Navigator.pop(context, false), // User closed/cancelled
        ),
        titleSpacing: 0,
        title: Text(
          widget.title,
          style: AppTextStyles.medium(18, AppColors.neutral950),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.sky500),
            ),
        ],
      ),
    );
  }
}
