import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Email Verification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Color(0xFFE8F4FF),
      ),
      home: EmailVerificationScreen(),
    );
  }
}

class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  // Code input fields
  List<String> codeDigits = ['', '', '', ''];
  int remainingSeconds = 20;
  Timer? _timer;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      remainingSeconds = 20;
      canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get formattedTime {
    return '00:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void updateCodeDigit(String digit) {
    setState(() {
      for (int i = 0; i < codeDigits.length; i++) {
        if (codeDigits[i].isEmpty) {
          codeDigits[i] = digit;
          break;
        }
      }
    });
  }

  void deleteLastDigit() {
    setState(() {
      for (int i = codeDigits.length - 1; i >= 0; i--) {
        if (codeDigits[i].isNotEmpty) {
          codeDigits[i] = '';
          break;
        }
      }
    });
  }

  void resendCode() {
    if (canResend) {
      // Add your resend code logic here
      print('Resending code...');
      // Reset the timer
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and sparkle icon
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    Icon(Icons.auto_awesome, size: 24),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Title
              Text(
                'Please check your email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12),

              // Subtitle with email
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  children: [
                    TextSpan(text: 'We\'ve sent a code to '),
                    TextSpan(
                      text: 'helloworld@gmail.com',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Code input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      codeDigits[index],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 24),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Implement your verification logic here
                    // You can access the code from the 'codeDigits' list
                    String enteredCode = codeDigits.join();
                    print('Entered Code: $enteredCode');
                    // Add your verification function here, example: verifyCode(enteredCode);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF192B51),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Resend code text
              Center(
                child: GestureDetector(
                  onTap: canResend ? resendCode : null,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: 'Send code again ',
                          style: TextStyle(
                            color: canResend ? Colors.blue : Colors.black54,
                          ),
                        ),
                        TextSpan(
                          text: canResend ? '' : formattedTime,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Spacer(),

              // Fixed Keyboard area
              Container(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // First row: 1, 2, 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeyButton('1'),
                        _buildKeyButton('2'),
                        _buildKeyButton('3'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Second row: 4, 5, 6
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeyButton('4'),
                        _buildKeyButton('5'),
                        _buildKeyButton('6'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Third row: 7, 8, 9
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeyButton('7'),
                        _buildKeyButton('8'),
                        _buildKeyButton('9'),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Fourth row: empty, 0, delete
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(width: 70, height: 50), // Empty space
                        _buildKeyButton('0'),
                        _buildDeleteButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build number key buttons
  Widget _buildKeyButton(String number) {
    return GestureDetector(
      onTap: () {
        updateCodeDigit(number);
      },
      child: Container(
        width: 70,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Helper method to build delete button
  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () {
        deleteLastDigit();
      },
      child: Container(
        width: 70,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.backspace_outlined),
      ),
    );
  }
}