import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PermissionErrorScreen extends StatelessWidget {
  final String errorMessage;
  final String? actionTitle;
  final VoidCallback? onRetry;

  const PermissionErrorScreen({
    super.key,
    required this.errorMessage,
    this.actionTitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF192F5D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Setup Required',
          style: TextStyle(
            color: Color(0xFF192F5D),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 60,
                color: Colors.orange.shade600,
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Database Setup Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192F5D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Error Message
            Text(
              errorMessage.contains('Permission denied') 
                ? 'Your Team Sync app needs database permissions to save projects and team data.'
                : errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Action Steps
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        'Quick Fix Steps:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF192F5D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep('1', 'Open Firebase Console (button below)'),
                  _buildStep('2', 'Go to Firestore Database → Rules'),
                  _buildStep('3', 'Click "Publish" to deploy new rules'),
                  _buildStep('4', 'Come back and try again'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Column(
              children: [
                // Open Firebase Console Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _openFirebaseConsole,
                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                    label: const Text(
                      'Open Firebase Console',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF187E0F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Retry Button
                if (onRetry != null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, color: Color(0xFF192F5D)),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF192F5D),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF192F5D)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Help Text
            Text(
              'Need help? This is a one-time setup that takes less than 2 minutes.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF192F5D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFirebaseConsole() async {
    const url = 'https://console.firebase.google.com/project/team-sync-project-management/firestore/rules';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening Firebase Console: $e');
    }
  }
}
