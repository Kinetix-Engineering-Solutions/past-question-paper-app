# Bug Fix: TypeError in Question Browser

## 🐛 Issue
**Error Message:**
```
TypeError: Instance of 'LinkedMap<String, dynamic>': type 'LinkedMap<String, dynamic>' 
is not a subtype of type 'String'
```

**Location:** Question Browser when loading questions from Firestore

---

## 🔍 Root Cause

The error occurred in `QuestionListItem.fromFirestore()` when trying to read nested Firestore data:

### Problem Areas:

1. **`pqpData` Field:**
   ```dart
   // ❌ WRONG - pqpData is a Map, trying to access nested field directly
   pqpNumber: data['pqpData']?['questionNumber']
   ```
   - `data['pqpData']` returns a `LinkedHashMap<String, dynamic>`
   - Trying to access `['questionNumber']` without casting caused type error

2. **`correctAnswer` Field:**
   - Some questions (e.g., drag_drop) might have `correctAnswer` as a Map instead of String
   - Direct casting to String failed for these cases

3. **Unsafe Type Casting:**
   - No null checks before accessing nested fields
   - No type validation before casting
   - Assumed all fields are correct types

---

## ✅ Solution

### 1. Fixed `QuestionListItem.fromFirestore()` Method

**Before:**
```dart
factory QuestionListItem.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return QuestionListItem(
    id: doc.id,
    questionText: data['questionText'] ?? '',
    subject: data['subject'] ?? '',
    grade: data['grade'] ?? 0,
    // ... other fields
    correctAnswer: data['correctAnswer'] ?? '',
    pqpNumber: data['pqpData']?['questionNumber'], // ❌ Type error here
  );
}
```

**After:**
```dart
factory QuestionListItem.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  
  // ✅ Safely extract pqpData questionNumber
  String? pqpNumber;
  if (data['pqpData'] != null && data['pqpData'] is Map) {
    final pqpData = data['pqpData'] as Map<String, dynamic>;
    pqpNumber = pqpData['questionNumber']?.toString();
  }
  
  // ✅ Safely extract correctAnswer (might be Map for drag_drop)
  String correctAnswer = '';
  if (data['correctAnswer'] != null) {
    if (data['correctAnswer'] is String) {
      correctAnswer = data['correctAnswer'] as String;
    } else if (data['correctAnswer'] is Map) {
      correctAnswer = '—'; // Show dash for complex types
    }
  }
  
  return QuestionListItem(
    id: doc.id,
    questionText: (data['questionText'] ?? '').toString(),
    subject: (data['subject'] ?? '').toString(),
    grade: (data['grade'] ?? 0) is int ? data['grade'] : int.tryParse(data['grade']?.toString() ?? '0') ?? 0,
    // ... safe conversion for all fields
    correctAnswer: correctAnswer,
    pqpNumber: pqpNumber,
  );
}
```

### 2. Fixed Preview Dialog Data Extraction

Applied same defensive coding pattern in `question_preview_dialog.dart`:

**MCQ Options:**
```dart
// ✅ Safe extraction with type checking
List<String> options = [];
if (data['options'] != null && data['options'] is List) {
  options = (data['options'] as List).map((e) => e?.toString() ?? '').toList();
}
```

**Answer Variations:**
```dart
// ✅ Safe extraction with filtering
List<String> variations = [];
if (data['answerVariations'] != null && data['answerVariations'] is List) {
  variations = (data['answerVariations'] as List)
      .map((e) => e?.toString() ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
}
```

**Drag Items:**
```dart
// ✅ Safe extraction with Map conversion
List<Map<String, dynamic>> dragItems = [];
if (data['dragItems'] != null && data['dragItems'] is List) {
  dragItems = (data['dragItems'] as List)
      .map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      })
      .where((item) => item.isNotEmpty)
      .toList();
}
```

---

## 🛡️ Defensive Coding Pattern Applied

### Pattern:
```dart
// 1. Check if field exists
if (data['fieldName'] != null) {
  
  // 2. Check type before casting
  if (data['fieldName'] is ExpectedType) {
    
    // 3. Safe cast with null-aware operators
    final value = data['fieldName'] as ExpectedType;
    
    // 4. Convert with fallback
    final result = value?.toString() ?? 'default';
  }
}
```

### Benefits:
✅ No runtime type errors  
✅ Handles missing fields gracefully  
✅ Works with inconsistent data  
✅ Provides meaningful fallback values  

---

## 🧪 Testing

### Scenarios Tested:
- ✅ Questions with pqpData present
- ✅ Questions without pqpData (null)
- ✅ Questions with correctAnswer as String (MCQ, short_answer)
- ✅ Questions with correctAnswer as Map (drag_drop)
- ✅ Questions with missing optional fields
- ✅ Questions with mixed data types

### Result:
✅ All questions now load successfully without type errors

---

## 📚 Lessons Learned

### Always Validate Firestore Data:
1. **Never assume field types** - Data might be inconsistent
2. **Check null and type** - Use `is` operator before casting
3. **Provide fallbacks** - Use `??` operator with sensible defaults
4. **Convert safely** - Use `.toString()` when type might vary
5. **Test with real data** - Firestore structure might differ from expectations

### Best Practices for Firestore Models:
```dart
// ❌ BAD - Assumes type, no validation
final name = data['name'];

// ✅ GOOD - Type checked with fallback
final name = (data['name'] is String) ? data['name'] as String : '';

// ✅ BETTER - Null-safe with toString
final name = (data['name'] ?? '').toString();
```

---

## 🔧 Files Modified

1. **`lib/admin/viewmodels/question_list_viewmodel.dart`**
   - Fixed `QuestionListItem.fromFirestore()` method
   - Added safe type checking and conversion
   - Added null safety for nested maps

2. **`lib/admin/widgets/question_preview_dialog.dart`**
   - Fixed `_buildMCQAnswer()` - Safe options extraction
   - Fixed `_buildShortAnswer()` - Safe variations extraction
   - Fixed `_buildDragDropAnswer()` - Safe drag items extraction

---

## ✅ Status

**Fixed:** October 5, 2025  
**Status:** ✅ Resolved - No more type errors  
**Impact:** Critical - Prevented question browser from loading  
**Solution Time:** ~15 minutes
