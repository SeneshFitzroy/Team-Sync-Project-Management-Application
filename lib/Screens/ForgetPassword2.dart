import 'package:flutter/material.dart';
import 'dart:async';
import 'ResetPassword.dart';

class ForgotPassword2 extends StatefulWidget {
  final String email;
  
  const ForgotPassword2({
    super.key,
    this.email = 'helloworld@gmail.com',  // Default email or get it from previous screen
  });

  @override
  _ForgotPassword2State createState() => _ForgotPassword2State();
}

class _ForgotPassword2State extends State<ForgotPassword2> {
  // Controllers for OTP input fields
  final TextEditingController _firstDigitController = TextEditingController();
  final TextEditingController _secondDigitController = TextEditingController();
  final TextEditingController _thirdDigitController = TextEditingController();
  final TextEditingController _fourthDigitController = TextEditingController();
  
  // Focus nodes for OTP fields
  final FocusNode _firstDigitFocus = FocusNode();
  final FocusNode _secondDigitFocus = FocusNode();
  final FocusNode _thirdDigitFocus = FocusNode();
  final FocusNode _fourthDigitFocus = FocusNode();
  
  // Timer for resend functionality
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _firstDigitController.dispose();
    _secondDigitController.dispose();
    _thirdDigitController.dispose();
    _fourthDigitController.dispose();
    _firstDigitFocus.dispose();
    _secondDigitFocus.dispose();
    _thirdDigitFocus.dispose();
    _fourthDigitFocus.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (_secondsRemaining < 1) {
          _isTimerActive = false;
          timer.cancel();
        } else {
          _secondsRemaining = _secondsRemaining - 1;
        }
      });
    });
  }

  void resendCode() {
    if (!_isTimerActive) {
      // Logic to resend code
      setState(() {
        _secondsRemaining = 30;
        _isTimerActive = true;
      });
      startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent!')),
      );
    }
  }

  void verifyOTP() {
    String otp = _firstDigitController.text + 
                 _secondDigitController.text + 
                 _thirdDigitController.text + 
                 _fourthDigitController.text;
                 
    if (otp.length == 4) {
      // Verification logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification successful!')),
      );
      
      // Navigate to ResetPassword screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResetPassword()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit code')),
      );
    }
  }

  // OTP field widget builder
  Widget _buildOtpField(TextEditingController controller, FocusNode focusNode, FocusNode? nextFocus) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD8DADC)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 28,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD8DADC)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black54),
                ),
              ),
              
              const SizedBox(height: 65),
              
              // Header text
              const Text(
                'Please check your email',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 1.30,
                  letterSpacing: -0.30,
                ),
              ),
              
              const SizedBox(height: 41),
              
              // Email text
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'A code has been sent to',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 37),
              
              // OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOtpField(_firstDigitController, _firstDigitFocus, _secondDigitFocus),
                  _buildOtpField(_secondDigitController, _secondDigitFocus, _thirdDigitFocus),
                  _buildOtpField(_thirdDigitController, _thirdDigitFocus, _fourthDigitFocus),
                  _buildOtpField(_fourthDigitController, _fourthDigitFocus, null),
                ],
              ),
              
              const SizedBox(height: 38),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF192F5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 38),
              
              // Resend code and timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: resendCode,
                    child: Text(
                      'Send code again',
                      style: TextStyle(
                        color: _isTimerActive ? Colors.black45 : Colors.black87,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isTimerActive 
                      ? '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}'
                      : '',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
