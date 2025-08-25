import 'package:flutter/material.dart';

class YourWidget extends StatefulWidget {
  const YourWidget({super.key});

  @override
  State<YourWidget> createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  // Add your state variables here
  Map<String, dynamic>? data;
  
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final result = await apiCall();
    if (mounted) {
      setState(() {
        data = result;
      });
    }
  }

  Future<dynamic> apiCall() async {
    // Implement your API call here
    await Future.delayed(const Duration(seconds: 1)); // Simulating network delay
    return {'message': 'Data fetched successfully'};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: data == null
          ? const CircularProgressIndicator()
          : Text(data!['message']),
    );
  }
}
