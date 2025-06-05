# Firestore Index Issue Fix

## Problem
The app was showing this error:
```
Error getting user chats: [cloud_firestore/failed-precondition] The query requires an index
```

## Root Cause
The `getUserChats()` method in `ChatService` was using a query with both:
- `.where('participants', arrayContains: currentUserId)`
- `.orderBy('lastMessageTime', descending: true)`

This combination requires a composite index in Firestore, which couldn't be created due to access restrictions.

## Solution
Modified the query to avoid the composite index requirement:

### Before (Required Index):
```dart
return _firestore
    .collection('chats')
    .where('participants', arrayContains: currentUserId)
    .orderBy('lastMessageTime', descending: true)  // This requires composite index
    .snapshots()
```

### After (No Index Required):
```dart
return _firestore
    .collection('chats')
    .where('participants', arrayContains: currentUserId)  // Simple query
    .snapshots()
    .map((snapshot) {
      List<ChatModel> chats = /* parse documents */;
      
      // Sort locally instead of in Firestore
      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      return chats;
    });
```

## Additional Fixes
1. **Removed null checks**: Since `lastMessageTime` is non-nullable in `ChatModel`, removed unnecessary null checks
2. **Fixed lastMessageTime storage**: Changed from `millisecondsSinceEpoch` to `DateTime` object for consistency

## Benefits
- ✅ No composite index required
- ✅ Works with default Firestore security rules
- ✅ Maintains same functionality (sorted by most recent)
- ✅ Better performance for small datasets (sorts in memory)

## Trade-offs
- For large numbers of chats (100+), sorting in memory might be less efficient than server-side sorting
- All chat documents are loaded before sorting (not paginated)

## Testing
Run the app with:
```cmd
flutter run
```

The "Error getting user chats" should now be resolved.
