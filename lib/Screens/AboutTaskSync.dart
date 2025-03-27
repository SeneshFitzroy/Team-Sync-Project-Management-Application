import 'package:flutter/material.dart';

class AboutTaskSync extends StatelessWidget {
  const AboutTaskSync({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                _buildHeader(context),
                _buildMissionSection(),
                const SizedBox(height: 16),
                _buildFeaturesSection(),
                const SizedBox(height: 16),
                _buildVersionSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Color(0xFF192F5D),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: const Text(
              'About TaskSync',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Our Mission',
            style: TextStyle(
              color: Color(0xFF192F5D),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'TaskSync is dedicated to transforming the way teams collaborate and manage projects. We provide an intuitive platform that brings together task management, team communication, and project planning in one seamless experience.',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              color: Color(0xFF192F5D),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            'Task Management',
            'Create, assign, and track tasks with ease. Set priorities and deadlines.',
            Icons.check_circle,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            'Team Communication',
            'Built-in messaging and collaboration tools keep your team connected.',
            Icons.chat_bubble,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            'Project Planning',
            'Powerful planning tools help you organize projects and set milestones.',
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF192F5D),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF192F5D),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  height: 1.62,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Version',
            style: TextStyle(
              color: Color(0xFF192F5D),
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'TaskSync v2.0.1',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          Text(
            'Released: October 2023',
            style: TextStyle(
              color: Color(0xFF9D9D9D),
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ],
      ),
    );
  }
}
