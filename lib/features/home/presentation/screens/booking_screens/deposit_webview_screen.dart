import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import 'package:test_cark/config/routes/screens_name.dart';

class DepositWebViewScreen extends StatefulWidget {
  final String url;
  const DepositWebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<DepositWebViewScreen> createState() => _DepositWebViewScreenState();
}

class _DepositWebViewScreenState extends State<DepositWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _successDialogShown = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            // شرط النجاح: إذا احتوى الرابط على success أو تم إعادة التوجيه لصفحة نجاح
            if (!_successDialogShown && _isPaymentSuccessUrl(url)) {
              _successDialogShown = true;
              await _showSuccessDialog();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isPaymentSuccessUrl(String url) {
    // عدل هذا الشرط حسب redirect URL الخاص بالنجاح في Paymob
    return url.contains('success') || url.contains('payment_completed') || url.contains('paid=true');
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(18),
                child: Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              SizedBox(height: 24),
              Text('Deposit Paid Successfully!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Your deposit has been paid and your booking is now confirmed.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Close WebView
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      ScreensName.homeScreen,
                      (route) => false,
                    );
                  },
                  child: Text('Go to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
} 