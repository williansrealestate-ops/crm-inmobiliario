import 'package:flutter/material.dart';
import '../config/theme.dart';

class SearchableDropdown extends StatefulWidget {
  final String value;
  final String hint;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool showAvatars;
  final Map<String, String>? avatarLetters;

  const SearchableDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.showAvatars = false,
    this.avatarLetters,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.text = widget.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de búsqueda
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              prefixIcon: Icon(widget.icon, size: 20, color: AppTheme.getTextSecondaryColor(context)),
              suffixIcon: IconButton(
                icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _filterItems(_searchController.text);
                    }
                  });
                },
              ),
              hintText: widget.hint,
              hintStyle: TextStyle(color: AppTheme.getTextTertiaryColor(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: AppTheme.getBackgroundColor(context),
            ),
            onChanged: (value) {
              _filterItems(value);
              if (!_isExpanded) {
                setState(() => _isExpanded = true);
              }
            },
            onTap: () {
              setState(() => _isExpanded = true);
              _filterItems(_searchController.text);
            },
          ),
          
          // Lista desplegable
          if (_isExpanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border(
                  top: BorderSide(color: AppTheme.getDividerColor(context)),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isSelected = item == widget.value;
                    final letter = widget.avatarLetters?[item] ?? item.substring(0, 1).toUpperCase();
                    
                    return InkWell(
                      onTap: () {
                        widget.onChanged(item);
                        _searchController.text = item;
                        setState(() => _isExpanded = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: isSelected 
                            ? AppTheme.primary.withOpacity(0.1) 
                            : Colors.transparent,
                        child: Row(
                          children: [
                            if (widget.showAvatars) ...[
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: isSelected 
                                      ? AppTheme.primary 
                                      : AppTheme.getTextColor(context),
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check, color: Color(0xFF10B981)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}