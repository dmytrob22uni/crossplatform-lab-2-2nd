# Lab2 App - Users & Posts Feed

A simple Flutter application for the Cross-Platform Software Systems lab. It fetches 20 users and 20 posts from [JSONPlaceholder API](https://jsonplaceholder.typicode.com), stores them in a local SQLite database, and displays them in a single reorderable list.

## Setup & Run

### Run App

```bash
# Install dependencies
flutter pub get

# Check connected device
flutter devices

# Run in debug mode on your device
flutter run

# Run tests
flutter test

# Static analysis
flutter analyze
```

## DB Behavior Notes

- **Refresh = Upsert:** Existing records are overwritten with API data. Custom `sort_order` is reset to 0 for fetched items (API has no ordering info), so order resets on refresh. This is intentional for simplicity.
- **Reorder:** When you drag an item, new indices are saved to `sort_order` via batch update.
- **Delete:** Removes row from the corresponding table immediately.
- **Remove All:** Clears both `users` and `posts` tables.

## Stack

- **Flutter** 3.x / **Dart** 3.x
- **Packages:** `http` (API), `sqflite` + `sqflite_common_ffi` (SQLite on desktop for dev), `path`
