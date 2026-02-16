import 'dart:async';
import 'package:flutter/material.dart';
import 'package:co_rider/models/location_suggestion.dart';
import 'package:co_rider/services/location_service.dart';

class LocationAutocompleteField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final void Function(LocationSuggestion) onSelected;
  final IconData prefixIcon;
  final Color? prefixIconColor;

  const LocationAutocompleteField({
    super.key,
    required this.label,
    required this.controller,
    required this.onSelected,
    this.prefixIcon = Icons.location_on,
    this.prefixIconColor,
  });

  @override
  State<LocationAutocompleteField> createState() => _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final LocationService _locationService = LocationService();
  final LayerLink _layerLink = LayerLink();
  
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();
  bool _isSelectingSuggestion = false;
  bool _isApplyingSelection = false;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Delay removal to allow onTap to fire on suggestions before the overlay is removed
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_focusNode.hasFocus && !_isSelectingSuggestion) {
            _removeOverlay();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    if (_isApplyingSelection) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Clear selection state implied by editing
    // The parent widget should handle invalidation via the controller listener or a separate callback if needed, 
    // but here we just handle the search.
    
    if (query.length < 3) {
      _lastSearchQuery = '';
      _removeOverlay();
      return;
    }

    _lastSearchQuery = query;

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _isLoading = true);
      final currentQuery = _lastSearchQuery;
      
      try {
        final suggestions = await _locationService.searchLocations(query);
        if (mounted) {
          if (_isApplyingSelection || !_focusNode.hasFocus || currentQuery != _lastSearchQuery) {
            setState(() => _isLoading = false);
            _removeOverlay();
            return;
          }
          setState(() {
            _suggestions = suggestions;
            _isLoading = false;
          });
          _showOverlay();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _isLoading = false;
          });
          _removeOverlay(); // Or show error in overlay
        }
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();

    // If no suggestions and not loading, don't show overlay
    if (_suggestions.isEmpty && !_isLoading) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        _isSelectingSuggestion = true;
                        _selectSuggestion(suggestion);
                      },
                      child: ListTile(
                        dense: true,
                        title: Text(
                          suggestion.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      if (_overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
      _overlayEntry = null;
    }
  }

  void _selectSuggestion(LocationSuggestion suggestion) {
    _debounce?.cancel();
    _isApplyingSelection = true;
    _lastSearchQuery = '';
    final selectedText = suggestion.name;
    widget.controller.value = TextEditingValue(
      text: selectedText,
      selection: TextSelection.collapsed(offset: selectedText.length),
      composing: TextRange.empty,
    );
    _suggestions = [];
    _isLoading = false;
    widget.onSelected(suggestion);
    _removeOverlay();
    _isSelectingSuggestion = false;
    _isApplyingSelection = false;
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 4),
            child: Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1.0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: _isLoading 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : Icon(
                          widget.prefixIcon, 
                          size: 20, 
                          color: widget.prefixIconColor ?? Theme.of(context).primaryColor
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                     decoration: BoxDecoration(
                       color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50], 
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(
                         color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                       ),
                     ),
                     child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      onChanged: _onChanged,
                      decoration: InputDecoration(
                        hintText: 'Search in Chennai...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        isDense: true,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0D121B),
                      ),
                     ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
