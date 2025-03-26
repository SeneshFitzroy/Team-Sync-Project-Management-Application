import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;

  const SearchBarWidget({
    super.key, 
    this.hintText = 'Search...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          height: 44,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, right: 2),
                child: Icon(Icons.search, color: Colors.grey[500], size: 18),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: TextField(
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontSize: 14),
                    readOnly: readOnly,
                    onTap: onTap,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    ),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 4),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  icon: Icon(Icons.clear, color: Colors.grey[400], size: 16),
                  onPressed: () {
                    // Clear text functionality
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search icon button for app bar with extreme left alignment
class SearchIconButton extends StatelessWidget {
  final Function()? onPressed;
  
  const SearchIconButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0),  // Remove left margin completely
      alignment: Alignment.centerLeft,
      child: Transform.translate(  // Use Transform to shift the button even more left
        offset: const Offset(-6, 0),  // Shift 6 pixels to the left
        child: IconButton(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,  // No padding
          visualDensity: const VisualDensity(horizontal: -4, vertical: 0),  // Compact density
          icon: const Icon(
            Icons.search,
            color: Colors.black87,
            size: 22,
          ),
          onPressed: onPressed ?? () {
            showSearch(
              context: context, 
              delegate: CustomSearchDelegate(),
            );
          },
        ),
      ),
    );
  }
}

// Custom search delegate for the search icon button
class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement your search results here
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions here
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Recent search 1'),
          onTap: () {
            query = 'Recent search 1';
            showResults(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Recent search 2'),
          onTap: () {
            query = 'Recent search 2';
            showResults(context);
          },
        ),
      ],
    );
  }
}