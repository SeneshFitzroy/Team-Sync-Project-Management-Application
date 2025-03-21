import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Member Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      home: const TeamMemberSelectionScreen(),
    );
  }
}

class TeamMember {
  final String name;
  final String role;
  bool isSelected;

  TeamMember({
    required this.name,
    required this.role,
    this.isSelected = false,
  });
}

class TeamMemberSelectionScreen extends StatefulWidget {
  const TeamMemberSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TeamMemberSelectionScreen> createState() =>
      _TeamMemberSelectionScreenState();
}

class _TeamMemberSelectionScreenState extends State<TeamMemberSelectionScreen> {
  final List<TeamMember> _suggestedMembers = [
    TeamMember(name: 'Sarah Chen', role: 'UI Designer'),
    TeamMember(name: 'Mike Peters', role: 'Product Manager'),
    TeamMember(name: 'Anna Smith', role: 'Developer'),
    TeamMember(name: 'James Wilson', role: 'Marketing Lead'),
    TeamMember(name: 'Elena Rodriguez', role: 'Data Analyst'),
    TeamMember(name: 'David Kim', role: 'UX Researcher'),
  ];

  int _selectedCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Add Team Members'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Suggested Members',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _suggestedMembers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = _suggestedMembers[index];
                return MemberListTile(
                  member: member,
                  isHighlighted: index == 1, // Mike Peters is highlighted
                  onSelected: (value) {
                    setState(() {
                      member.isSelected = value;
                      _selectedCount += value ? 1 : -1;
                    });
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _selectedCount > 0 ? () {} : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.indigo[800],
                ),
                child: Text(
                  'Add Selected Members ($_selectedCount)',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MemberListTile extends StatelessWidget {
  final TeamMember member;
  final ValueChanged<bool> onSelected;
  final bool isHighlighted;

  const MemberListTile({
    Key? key,
    required this.member,
    required this.onSelected,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue[50] : Colors.transparent,
        border: isHighlighted ? Border.all(color: Colors.blue, width: 2) : null,
        borderRadius: isHighlighted ? BorderRadius.circular(8) : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        title: Text(
          member.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          member.role,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        trailing: Checkbox(
          value: member.isSelected,
          onChanged: (value) => onSelected(value ?? false),
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
