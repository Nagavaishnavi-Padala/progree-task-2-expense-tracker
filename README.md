# Progree Task 2 - Expense Tracker

A cross-platform Flutter expense tracker application developed as part of the Progree App Development Internship.

## Overview

This application allows users to record, view, edit, and delete their expenses using a secure local database.

The application uses Flutter for the user interface and encrypted SQLite storage for securely storing expense data locally on the device.

## Features

- Add new expenses
- View saved expenses
- Edit existing expenses
- Delete expenses
- Expense categories
- Date selection
- Input validation
- Total expense calculation
- Today's expense calculation
- Responsive dashboard
- Empty-state UI
- Confirmation dialog before deletion
- Encrypted local database storage
- Data persistence across app restarts

## CRUD Operations

| Operation | Description |
|---|---|
| Create | Add a new expense |
| Read | Display saved expenses |
| Update | Edit an existing expense |
| Delete | Remove an expense |

## Tech Stack

- Flutter
- Dart
- Material 3
- SQLite
- SQLCipher
- `sqflite_sqlcipher`
- `path`

## Database

The application uses SQLCipher-backed SQLite for encrypted local storage.

Expense records contain:

- ID
- Amount
- Category
- Description
- Date

## Project Structure

```text
lib/
├── main.dart
├── database/
│   └── database_helper.dart
├── models/
│   └── expense.dart
├── screens/
│   ├── add_expense_screen.dart
│   └── home_screen.dart
└── widgets/