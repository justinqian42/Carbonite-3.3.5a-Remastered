# Transport Management System

## Overview

The Transport Management System provides a comprehensive interface for managing learned transports in CustomWaypoints. This system allows users to view, select, and delete saved transports with an intuitive GUI interface.

## Features

### 1. Transport Confirmation System
- **Popup Confirmation**: When a new transport is detected, a confirmation dialog appears
- **Duplicate Detection**: Automatically detects and skips confirmation for existing transports
- **User Control**: Users can choose to save or ignore detected transports

### 2. Transport Management UI
- **Visual Interface**: Scrollable list of all saved transports
- **Selection System**: Checkbox-based multi-selection for bulk operations
- **Bulk Deletion**: Delete multiple selected transports at once
- **Clear All**: Option to clear all transports instantly
- **Keyboard Shortcuts**: DELETE key for quick deletion, ESC to close

## Commands

### Slash Commands
```
/cw transportconfirmation     - Toggle transport confirmation on/off
/cw managetransports          - Open transport management window
/cw transports               - List all learned transports in chat
/cw cleartransports           - Clear all learned transports
/cw transportlog              - Toggle transport logging
/cw transportdiscovery        - Toggle transport discovery
```

### UI Access
- **Main UI Button**: "Manage Transports" button in the main addon window
- **Checkbox**: "TransportConfirm" checkbox to enable/disable confirmation system

## Interface Elements

### Transport Confirmation Dialog
- **Title**: "CustomWaypoints - Transport Detected"
- **Question**: "Save this transport for routing?"
- **Details**: Shows from → to locations
- **Actions**: Save, Ignore, Close (ESC)

### Transport Management Window
- **Title**: "CustomWaypoints - Transport Management"
- **Instructions**: "Select transports to delete, then click Delete Selected or use DELETE key"
- **Transport List**: Scrollable list with checkboxes and transport details
- **Buttons**: 
  - "Delete Selected" - Removes selected transports
  - "Clear All" - Removes all transports
  - Close button (X) or ESC key

## Transport Details Display

Each transport entry shows:
- **Transport Label**: e.g., "Learned Portal: Stormwind City → Orgrimmar"
- **Usage Count**: Number of times this transport has been used
- **Selection Checkbox**: For multi-selection operations

## Technical Implementation

### Data Storage
- **Location**: `STATE.db.learnedTransports` table
- **Structure**: Array of transport edge objects
- **Persistence**: Saved between WoW sessions

### Duplicate Detection
- **Algorithm**: Checks `fromMaI`, `toMaI`, and coordinates within 25 yards
- **Fallback**: Uses learned route key for edge cases
- **Behavior**: Increments usage count, updates last seen timestamp

### UI Framework
- **Frames**: Standard WoW UI frames with proper parenting
- **Scrolling**: `UIPanelScrollFrameTemplate` for long lists
- **Input Handling**: Keyboard shortcuts and mouse interactions
- **State Management**: Proper cleanup and frame reuse

## Usage Workflow

### Adding New Transports
1. Enable transport confirmation (`/cw transportconfirmation`)
2. Travel through portals, hearthstones, or other transports
3. Confirm or ignore the popup dialog
4. Transport is saved (if confirmed) for future routing

### Managing Existing Transports
1. Click "Manage Transports" button or use `/cw managetransports`
2. Review the list of saved transports
3. Select unwanted transports with checkboxes
4. Click "Delete Selected" or press DELETE key
5. Confirm deletion (if applicable)

### Bulk Operations
- **Multi-Select**: Check multiple transports for bulk deletion
- **Clear All**: Use "Clear All" button for complete reset
- **Quick Actions**: Keyboard shortcuts for efficient workflow

## Error Handling

### Common Issues
- **No Transports**: Shows "No saved transports found" message
- **Selection Required**: "No transports selected for deletion" warning
- **Frame Reuse**: Properly hides/shows management window

### Debug Information
- Enable transport logging (`/cw transportlog`) for detailed output
- Check chat messages for operation confirmations
- Use `/cw transports` to verify current transport list

## Integration with Routing System

### Route Calculation
- Learned transports are integrated into pathfinding algorithms
- Preference bonuses can be configured via routing tuning
- Automatic usage based on cost calculations

### Performance
- Compact storage with duplicate prevention
- Efficient lookup during route calculation
- Minimal impact on addon performance

## Configuration Options

### Settings
- `transportConfirmationEnabled`: Enable/disable confirmation popups
- `transportDiscoveryEnabled`: Enable/disable automatic detection
- `transportLogEnabled`: Enable/disable logging output

### Routing Tuning
- `learnedPortalBonus`: Preference bonus for learned portals
- Distance thresholds for portal detection
- Cost calculations for route optimization

## Troubleshooting

### Transport Not Saving
- Check if transport confirmation is enabled
- Verify the transport isn't already a duplicate
- Check transport discovery is enabled

### Management Window Issues
- Reload UI if window doesn't appear
- Check for conflicting addons
- Verify addon is properly loaded

### Performance Issues
- Clear old transports regularly
- Disable logging if not needed
- Use compact transport database

## Future Enhancements

### Planned Features
- Transport export/import functionality
- Advanced filtering and search
- Transport usage analytics
- Visual map integration
- Batch operations with confirmation

### API Extensions
- Plugin system for custom transport handlers
- Integration with other addons
- Advanced routing algorithms
- Real-time transport updates
