import 'package:flutter/material.dart';

class TaskManagement extends StatelessWidget {
  const TaskManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 475.79,
          height: 878.50,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // Header divider
              Positioned(
                left: 0,
                top: 80.89,
                child: Container(
                  width: 473.78,
                  height: 1,
                  decoration: BoxDecoration(color: const Color(0xFFE5E9EF)),
                ),
              ),
              
              // Header container
              Positioned(
                left: 0,
                top: 0,
                child: Container(width: 474, height: 81),
              ),
              
              // Header title
              Positioned(
                left: 16,
                top: 25,
                child: Text(
                  'Task Management',
                  style: TextStyle(
                    color: const Color(0xFF192F5D),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
              ),
              
              // Profile button containers
              Positioned(
                left: 418,
                top: 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29826200),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 418,
                top: 20,
                child: Container(width: 40, height: 40),
              ),
              
              // Project Tasks button
              Positioned(
                left: 24,
                top: 105,
                child: Container(
                  width: 167,
                  height: 50,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 167,
                          height: 50,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF192F5D),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF192F5D),
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 13,
                        child: Text(
                          'Project Tasks',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFF7F8FB),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // My Tasks button
              Positioned(
                left: 207,
                top: 105,
                child: Container(
                  width: 138,
                  height: 50,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFCFDFF),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFF192F5D),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 240,
                top: 118,
                child: Text(
                  'My Tasks',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF190A0A),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
              ),
              
              // Search bar
              Positioned(
                left: 24,
                top: 179,
                child: Container(
                  width: 426,
                  height: 48,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 426,
                          height: 48,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0xFF060D17),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 14,
                        child: Container(
                          width: 20,
                          height: 20,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(children: [
                            // Search icon would go here
                          ]),
                        ),
                      ),
                      Positioned(
                        left: 53,
                        top: 15,
                        child: Text(
                          'Search tasks...',
                          style: TextStyle(
                            color: const Color(0xFF999999),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // First task card
              Positioned(
                left: 24,
                top: 259,
                child: Container(
                  width: 426,
                  height: 172,
                  decoration: ShapeDecoration(
                    color: const Color(0x56192F5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 259,
                child: Container(
                  width: 8,
                  height: 172,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF187E0F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 282,
                child: Text(
                  'Website Redesign',
                  style: TextStyle(
                    color: const Color(0xFF666666),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 312,
                child: Text(
                  'Design System Update',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 345,
                child: SizedBox(
                  width: 51,
                  child: Text(
                    'Design Squad',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 132,
                top: 345,
                child: SizedBox(
                  width: 65,
                  child: Text(
                    'In Progress',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 215,
                top: 345,
                child: SizedBox(
                  width: 71,
                  child: Text(
                    'Due: 2024-02-15',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 288,
                top: 313,
                child: Container(
                  width: 83,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD14318),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 312,
                top: 321,
                child: Text(
                  'High',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
              Positioned(
                left: 388,
                top: 313,
                child: SizedBox(
                  width: 42,
                  child: Text(
                    'Sarah Chen',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              
              // Second task card
              Positioned(
                left: 24,
                top: 455,
                child: Container(
                  width: 426,
                  height: 172,
                  decoration: ShapeDecoration(
                    color: const Color(0x56192F5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 455,
                child: Container(
                  width: 8,
                  height: 172,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD14318),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 478,
                child: Text(
                  'Mobile App v2.0',
                  style: TextStyle(
                    color: const Color(0xFF666666),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 508,
                child: Text(
                  'API Integration',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 541,
                child: SizedBox(
                  width: 96,
                  child: Text(
                    'Development Team',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 159,
                top: 539,
                child: Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.75),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
              Positioned(
                left: 238,
                top: 541,
                child: SizedBox(
                  width: 45,
                  child: Text(
                    'Due: 2024-02-20',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 279,
                top: 509,
                child: Container(
                  width: 109,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF187E0F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 303,
                top: 517,
                child: Text(
                  'Medium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
              Positioned(
                left: 404,
                top: 509,
                child: SizedBox(
                  width: 35,
                  child: Text(
                    'Mike Ross',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ),
              
              // Add new task button
              Positioned(
                left: 124,
                top: 667,
                child: Container(
                  width: 205,
                  height: 56,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 205,
                          height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF192F5D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 16,
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                      ),
                      Positioned(
                        left: 64,
                        top: 16,
                        child: Text(
                          'Add New Task',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom navigation
              Positioned(
                left: 24,
                top: 809,
                child: Container(
                  width: 474.40,
                  height: 58,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 474.40,
                          height: 1,
                          decoration: BoxDecoration(color: const Color(0x19192F5D)),
                        ),
                      ),
                      
                      // Tasks nav item
                      Positioned(
                        left: 153,
                        top: 11,
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                      ),
                      Positioned(
                        left: 170,
                        top: 7,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFF1212),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26843500),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 175,
                        top: 7,
                        child: Text(
                          '3',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 149,
                        top: 38,
                        child: Text(
                          'Tasks',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF666666),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      
                      // Chat nav item
                      Positioned(
                        left: 251,
                        top: 11,
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(),
                        ),
                      ),
                      Positioned(
                        left: 264,
                        top: 7,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFFF1212),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26843500),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 269,
                        top: 7,
                        child: Text(
                          '2',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 249,
                        top: 38,
                        child: Text(
                          'Chat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF666666),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      
                      // Calendar nav item
                      Positioned(
                        left: 335,
                        top: 40,
                        child: Text(
                          'Calendar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF666666),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      
                      // Dashboard nav item
                      Positioned(
                        left: 48,
                        top: 38,
                        child: Text(
                          'Dashboard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF280A0A),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Profile avatar
              Positioned(
                left: 398,
                top: 9,
                child: Container(width: 64, height: 64, child: Stack()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
