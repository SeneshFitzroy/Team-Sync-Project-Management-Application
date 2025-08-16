import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2D62ED);
  static const Color primaryDark = Color(0xFF1E4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  
  // Background Colors
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundGray = Color(0xFFF8FAFC);
  static const Color backgroundLight = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Task Status Colors
  static const Color todoColor = Color(0xFF6B7280);
  static const Color inProgressColor = Color(0xFFF59E0B);
  static const Color completedColor = Color(0xFF10B981);
  
  // Priority Colors
  static const Color lowPriority = Color(0xFF10B981);
  static const Color mediumPriority = Color(0xFFF59E0B);
  static const Color highPriority = Color(0xFFEF4444);
  static const Color urgentPriority = Color(0xFF7C2D12);
  
  // Chat Colors
  static const Color chatSentBubble = primaryBlue;
  static const Color chatReceivedBubble = Color(0xFFF1F5F9);
  static const Color chatTextSent = Colors.white;
  static const Color chatTextReceived = textPrimary;
  
  // Typography
  static const String fontFamily = 'Poppins';
  
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textLight,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textWhite,
  );
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundWhite,
      fontFamily: fontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryLight,
        surface: backgroundWhite,
        onPrimary: textWhite,
        onSecondary: textWhite,
        onSurface: textPrimary,
        error: error,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        iconTheme: IconThemeData(color: textWhite),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textWhite,
          elevation: 2,
          shadowColor: primaryBlue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: buttonText,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textLight.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textSecondary,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: textLight,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: textPrimary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: backgroundWhite,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonText,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: textWhite,
        elevation: 4,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      useMaterial3: true,
    );
  }
  
  // Helper methods for consistent styling
  static BoxDecoration primaryGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryBlue, primaryDark],
    ),
    borderRadius: BorderRadius.circular(16),
  );
  
  static BoxDecoration cardDecoration = BoxDecoration(
    color: backgroundWhite,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: textPrimary.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration chatBubbleDecoration({required bool isSent}) {
    return BoxDecoration(
      color: isSent ? chatSentBubble : chatReceivedBubble,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: isSent ? const Radius.circular(16) : const Radius.circular(4),
        bottomRight: isSent ? const Radius.circular(4) : const Radius.circular(16),
      ),
    );
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
      case 'pending':
        return todoColor;
      case 'in_progress':
      case 'in progress':
        return inProgressColor;
      case 'completed':
      case 'done':
        return completedColor;
      default:
        return todoColor;
    }
  }
  
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return lowPriority;
      case 'medium':
        return mediumPriority;
      case 'high':
        return highPriority;
      case 'urgent':
        return urgentPriority;
      default:
        return mediumPriority;
    }
  }
}
