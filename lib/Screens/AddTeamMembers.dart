import 'package:flutter/material.dart';

class TeamMember {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;
  bool isSelected;

  TeamMember({
    required this.name,
    required this.role,
    this.id = '',
    this.avatarUrl = '',
    this.isSelected = false,
  });
  
  // Convert to project TeamMember format
  Map<String, dynamic> toMap() {
    return {
      'id': id.isEmpty ? name.toLowerCase().replaceAll(' ', '_') : id,
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
}

class AddTeamMembers extends StatefulWidget {
  const AddTeamMembers({Key? key}) : super(key: key);

  @override
  _AddTeamMembersState createState() => _AddTeamMembersState();
}

class _AddTeamMembersState extends State<AddTeamMembers> {
  final TextEditingController _searchController = TextEditingController();
  List<TeamMember> _allTeamMembers = [];
  List<TeamMember> _filteredTeamMembers = [];

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    _allTeamMembers = [
      TeamMember(name: 'Sarah Chen', role: 'UI Designer'),
      TeamMember(name: 'Mike Peters', role: 'Product Manager'),
      TeamMember(name: 'Anna Smith', role: 'Developer'),
      TeamMember(name: 'James Wilson', role: 'Marketing Lead'),
      TeamMember(name: 'Elena Rodriguez', role: 'Data Analyst'),
      TeamMember(name: 'David Kim', role: 'UX Researcher'),
    ];
    _filteredTeamMembers = List.from(_allTeamMembers);

    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTeamMembers = List.from(_allTeamMembers);
      } else {
        _filteredTeamMembers = _allTeamMembers
            .where((member) =>
                member.name.toLowerCase().contains(query) ||
                member.role.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  int get _selectedCount => _allTeamMembers.where((member) => member.isSelected).length;

  void _toggleMemberSelection(int index) {
    setState(() {
      _filteredTeamMembers[index].isSelected = !_filteredTeamMembers[index].isSelected;
    });
  }

  void _addSelectedMembers() {
    // Get all selected members
    final selectedMembers = _allTeamMembers
        .where((member) => member.isSelected)
        .map((member) => TeamMember(
              id: member.id.isEmpty ? member.name.toLowerCase().replaceAll(' ', '_') : member.id,
              name: member.name,
              role: member.role,
              avatarUrl: member.avatarUrl,
            ))
        .toList();

    if (selectedMembers.isNotEmpty) {
      // Return selected members to the previous screen
      Navigator.pop(context, selectedMembers.map((m) => 
        TeamMember(
          id: m.id,
          name: m.name,
          role: m.role,
          avatarUrl: m.avatarUrl,
        )).toList());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one team member')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF192F5D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Team Members',
          style: TextStyle(
            color: Color(0xFF192F5D),
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or role',
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E9EF),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E9EF),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
            child: Text(
              'Suggested Members',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _filteredTeamMembers.length,
              itemBuilder: (context, index) {
                final member = _filteredTeamMembers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFE5E9EF),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE5E9EF),
                        child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                            ? Text(
                                member.name[0],
                                style: const TextStyle(
                                  color: Color(0xFF192F5D),
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
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                      subtitle: Text(
                        member.role,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () => _toggleMemberSelection(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: ShapeDecoration(
                            color: member.isSelected
                                ? const Color(0xFF192F5D)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 2,
                                color: member.isSelected
                                    ? const Color(0xFF192F5D)
                                    : const Color(0xFFE5E9EF),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: member.isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextButton(
              onPressed: _addSelectedMembers,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF192F5D),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Selected Members ($_selectedCount)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
