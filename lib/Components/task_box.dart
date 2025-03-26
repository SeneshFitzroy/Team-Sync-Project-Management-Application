import 'package:flutter/material.dart';

enum TaskStatus { active, atRisk, completed }

class TaskBox extends StatefulWidget {
  final String title;
  final int memberCount;
  final TaskStatus status;
  final int progressPercentage;
  final Color accentColor;
  final DateTime? dueDate;
  final List<String>? memberAvatars;
  final Function(int)? onProgressChanged;

  const TaskBox({
    super.key,
    required this.title,
    required this.memberCount,
    required this.status,
    required this.progressPercentage,
    required this.accentColor,
    this.dueDate,
    this.memberAvatars,
    this.onProgressChanged,
  });

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  late int _currentProgress;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progressPercentage;
  }

  String get statusText {
    switch (widget.status) {
      case TaskStatus.active:
        return 'active';
      case TaskStatus.atRisk:
        return 'at-risk';
      case TaskStatus.completed:
        return 'completed';
    }
  }

  void _updateProgress(double dx, double maxWidth) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(Offset(dx, 0));
    
    // Calculate percentage based on touch position
    int newProgress = ((localPos.dx - 24) / maxWidth * 100).round();
    
    // Clamp between 0 and 100
    newProgress = newProgress.clamp(0, 100);
    
    if (newProgress != _currentProgress) {
      setState(() {
        _currentProgress = newProgress;
      });
      
      // Notify parent if callback is provided
      if (widget.onProgressChanged != null) {
        widget.onProgressChanged!(_currentProgress);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double progressBarWidth = screenWidth - 80; // Same as container width
    
    return Container(
      width: screenWidth - 32,
      height: 163,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0x56192F5D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Stack(
        children: [
          // Left accent bar
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 163,
              decoration: ShapeDecoration(
                color: widget.accentColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          
          // Task title
          Positioned(
            left: 24,
            top: 24,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
          ),
          
          // Members icon and count
          Positioned(
            left: 24,
            top: 59,
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.memberCount} Members',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
          
          // Status icon and text
          Positioned(
            left: 150,
            top: 59,
            child: Row(
              children: [
                Icon(
                  widget.status == TaskStatus.completed ? Icons.check_circle : 
                  widget.status == TaskStatus.active ? Icons.timer : Icons.warning,
                  size: 16,
                  color: widget.status == TaskStatus.atRisk ? Colors.orange : 
                         widget.status == TaskStatus.completed ? Colors.green : 
                         Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
          
          // Due date (if provided)
          if (widget.dueDate != null)
            Positioned(
              right: 24,
              top: 59,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${widget.dueDate!.day}/${widget.dueDate!.month}/${widget.dueDate!.year}",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ),
          
          // Progress text
          Positioned(
            left: 24,
            top: 101,
            child: const Text(
              'Progress',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
          
          // Progress percentage
          Positioned(
            right: 24,
            top: 101,
            child: Text(
              '$_currentProgress%',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
          
          // Interactive progress bar area
          Positioned(
            left: 24,
            top: 120,
            child: GestureDetector(
              onHorizontalDragStart: (details) {
                setState(() {
                  _isDragging = true;
                });
                _updateProgress(details.globalPosition.dx, progressBarWidth);
              },
              onHorizontalDragUpdate: (details) {
                _updateProgress(details.globalPosition.dx, progressBarWidth);
              },
              onHorizontalDragEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
              },
              onTapDown: (details) {
                _updateProgress(details.globalPosition.dx, progressBarWidth);
              },
              child: Container(
                width: progressBarWidth,
                height: 30, // Larger touch target
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Progress bar background
                    Container(
                      width: progressBarWidth,
                      height: 9,
                      decoration: ShapeDecoration(
                        color: const Color(0x26192F5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    
                    // Progress bar fill
                    Container(
                      width: progressBarWidth * _currentProgress / 100,
                      height: 9,
                      decoration: ShapeDecoration(
                        color: widget.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    
                    // Drag handle
                    if (_isDragging)
                      Positioned(
                        left: (progressBarWidth * _currentProgress / 100) - 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.accentColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Team member avatars (optional)
          if (widget.memberAvatars != null && widget.memberAvatars!.isNotEmpty)
            Positioned(
              right: 24,
              top: 24,
              child: SizedBox(
                height: 24,
                width: 70, // Fixed width to avoid layout issues
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    for (int i = 0; i < (widget.memberAvatars!.length > 3 ? 3 : widget.memberAvatars!.length); i++)
                      Positioned(
                        right: i * 18.0, // Position from right with proper spacing
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            image: DecorationImage(
                              image: NetworkImage(widget.memberAvatars![i]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    if (widget.memberAvatars!.length > 3)
                      Positioned(
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              '+${widget.memberAvatars!.length - 3}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}