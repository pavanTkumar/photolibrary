// File: lib/features/photos/presentation/widgets/tag_input_field.dart

import 'package:flutter/material.dart';

class TagInputField extends StatefulWidget {
  final Function(List<String>) onTagsChanged;
  final List<String>? initialTags;
  
  const TagInputField({
    Key? key,
    required this.onTagsChanged,
    this.initialTags,
  }) : super(key: key);

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _tags = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.initialTags != null) {
      _tags.addAll(widget.initialTags!);
    }
  }
  
  @override
  void dispose() {
    _tagController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _addTag(String tag) {
    tag = tag.trim().toLowerCase();
    
    // Only add the tag if it's not empty and not already in the list
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
      
      widget.onTagsChanged(_tags);
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Tags',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Tag chips
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text('#$tag'),
                onDeleted: () => _removeTag(tag),
                backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
                deleteIconColor: theme.colorScheme.onSurface.withOpacity(0.7),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 8),
        ],
        
        // Tag input field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Add tags (press Enter or ,)',
                  border: const OutlineInputBorder(),
                  prefixText: '# ',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _addTag(_tagController.text);
                      _focusNode.requestFocus();
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _addTag(value);
                  _focusNode.requestFocus();
                },
                onChanged: (value) {
                  // Add tag if the user types a comma
                  if (value.endsWith(',')) {
                    _addTag(value.substring(0, value.length - 1));
                  }
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Helper text
        Text(
          'Add tags to help others find your photo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}