@echo off
echo Cleaning up unused .dart files...

REM Remove unused utils files
del /f "lib\utils\auth_helper.dart" 2>nul
del /f "lib\utils\error_handler.dart" 2>nul
del /f "lib\utils\firebase_debug.dart" 2>nul
del /f "lib\utils\firebase_helpers.dart" 2>nul
del /f "lib\utils\firestore_extensions.dart" 2>nul

REM Remove unused Services files
del /f "lib\Services\auth_service.dart" 2>nul

REM Remove unused models files
del /f "lib\models\user_data.dart" 2>nul
del /f "lib\models\pigeon_user_details.dart" 2>nul

REM Remove duplicate login files
del /f "lib\Screens\login-page-new.dart" 2>nul
del /f "lib\Screens\login-page-bypass.dart" 2>nul

REM Remove unused widget template
del /f "lib\widgets\your_widget.dart" 2>nul

REM Remove test file from root
del /f "icon_test.dart" 2>nul

echo Cleanup completed!
pause
