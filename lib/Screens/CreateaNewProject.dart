import 'package:flutter/material.dart';
import 'AddTeamMembers.dart';
import '../Services/firebase_service.dart';

class CreateANewProject extends StatefulWidget {
  const CreateANewProject({super.key});

  @override
  State<CreateANewProject> createState() => _CreateANewProjectState();
}

class _CreateANewProjectState extends State<CreateANewProject> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TeamMember> _selectedTeamMembers = [];
  
  // Add color selection
  Color _selectedColor = const Color(0xFF187E0F); // Default green
  final List<Color> _colorOptions = [
    const Color(0xFF187E0F), // Green
    const Color(0xFFD14318), // Red/Orange
    const Color(0xFF192F5D), // Blue (app primary)
    const Color(0xFF9B870C), // Gold
    const Color(0xFF8E44AD), // Purple
  ];

  @override
  void dispose() {
    _projectNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTeamMember() async {
    // Navigate to AddTeamMembers screen and wait for result
    final selectedMembersData = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTeamMembers(),
      ),
    );
    
    // If members were selected, add them to the project
    if (selectedMembersData != null && selectedMembersData.isNotEmpty) {
      setState(() {
        for (var memberData in selectedMembersData) {
          // Check if we already have 5 team members
          if (_selectedTeamMembers.length >= 5) break;
          
          // Create a TeamMember from the returned data
          final member = TeamMember(
            id: memberData['id'],
            name: memberData['name'],
            role: memberData['role'],
            avatarUrl: memberData['avatarUrl'],
          );
          
          // Check if member is already added (avoid duplicates)
          if (!_selectedTeamMembers.any((m) => m.id == member.id)) {
            _selectedTeamMembers.add(member);
          }
        }
      });
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedMembersData.length} team members added')),
      );
    }
  }

  void _removeTeamMember(TeamMember member) {
    setState(() {
      _selectedTeamMembers.remove(member);
    });
  }
  void _createProject() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Create a project data map for Firebase
        final projectData = {
          'title': _projectNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'status': 'active',
          'progress': 0.0,
          'members': _selectedTeamMembers.map((member) => member.id).toList(),
          'teamMemberDetails': _selectedTeamMembers.map((member) => {
            'id': member.id,
            'name': member.name,
            'role': member.role,
          }).toList(),
        };

        // Save to Firebase
        final projectId = await FirebaseService.createProject(projectData);
        
        // Log activity
        await FirebaseService.logActivity('project_created', {
          'projectId': projectId,
          'projectTitle': projectData['title'],
          'memberCount': _selectedTeamMembers.length,
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Hide loading
        if (mounted) Navigator.pop(context);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Project "${projectData['title']}" created successfully!'),
              backgroundColor: const Color(0xFF187E0F),
            ),
          );
          
          // Return the project data to the Dashboard for immediate UI update
          Navigator.pop(context, {
            'title': projectData['title'],
            'description': projectData['description'],
          });
        }
      } catch (e) {
        // Hide loading
        if (mounted) Navigator.pop(context);
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating project: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

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
          'Create New Project',
          style: TextStyle(
            color: Color(0xFF192F5D),
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Project Name',
                style: TextStyle(
                  color: Color(0xFF192F5D),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _projectNameController,
                decoration: InputDecoration(
                  hintText: 'Enter project name',
                  hintStyle: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0x21192F5D),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0x21192F5D),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(
                  color: Color(0xFF192F5D),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter project description',
                  hintStyle: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0x21192F5D),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0x21192F5D),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Project Color',
                style: TextStyle(
                  color: Color(0xFF192F5D),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _colorOptions.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: color == _selectedColor
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Team Members',
                    style: TextStyle(
                      color: Color(0xFF192F5D),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_selectedTeamMembers.length}/5 members',
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Display team members list
              _selectedTeamMembers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'No team members added yet',
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedTeamMembers.length,
                      itemBuilder: (context, index) {
                        final member = _selectedTeamMembers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFE5E9EF)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFE0E0E0),
                                backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                                    ? NetworkImage(member.avatarUrl!)
                                    : null,
                                child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                                    ? Text(
                                        member.name.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF192F5D),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                member.name,
                                style: const TextStyle(
                                  color: Color(0xFF192F5D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                member.role,
                                style: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _removeTeamMember(member),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedTeamMembers.length >= 5 ? null : _addTeamMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192F5D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(188, 48),
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                ),
                child: const Text(
                  'Add Team Member',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _createProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF192F5D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Create Project',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamMember {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });
}

class TeamMemberAvatar extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onRemove;

  const TeamMemberAvatar({
    super.key,
    required this.member,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: const Color(0xFFE0E0E0),
          backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
          child: member.avatarUrl == null
              ? Text(
                  member.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF192F5D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
