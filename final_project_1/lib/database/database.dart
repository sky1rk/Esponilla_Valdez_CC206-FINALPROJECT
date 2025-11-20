import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get email => text()();
  TextColumn get password => text()();
}

class UserProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get tasksCreated => integer().withDefault(const Constant(0))();
  IntColumn get tasksDone => integer().withDefault(const Constant(0))();
  TextColumn get lastTaskTitle => text().nullable()();
  DateTimeColumn get lastTaskCompletionTime => dateTime().nullable()();
}

@DriftDatabase(tables: [Users, UserProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  Future<void> addUser(String username, String email, String password) async {
    await into(users).insert(
      UsersCompanion.insert(
        username: username,
        email: email,
        password: password,
      ),
    );
  }

  Future<bool> userExists(String username) async {
    final query = await (select(
      users,
    )..where((u) => u.username.equals(username))).get();
    return query.isNotEmpty;
  }

  Future<bool> validateLogin(String username, String password) async {
    final query =
        await (select(users)..where(
              (u) => u.username.equals(username) & u.password.equals(password),
            ))
            .get();
    return query.isNotEmpty;
  }

  Future<UserProgressData?> getUserProgress(int userId) {
    return (select(userProgress)..where((p) => p.userId.equals(userId))).getSingleOrNull();
  }

  Future<void> addOrUpdateUserProgress({
    required int userId,
    int tasksCreatedIncrement = 0,
    int tasksDoneIncrement = 0,
    String? lastTaskTitle,
    DateTime? lastTaskCompletionTime,
  }) async {
    final progress = await getUserProgress(userId);
    if (progress == null) {
      await into(userProgress).insert(
        UserProgressCompanion.insert(
          userId: userId,
          tasksCreated: Value(tasksCreatedIncrement),
          tasksDone: Value(tasksDoneIncrement),
          lastTaskTitle: Value(lastTaskTitle),
          lastTaskCompletionTime: Value(lastTaskCompletionTime),
        ),
      );
    } else {
      await (update(userProgress)..where((p) => p.userId.equals(userId))).write(
        UserProgressCompanion(
          tasksCreated: Value(progress.tasksCreated + tasksCreatedIncrement),
          tasksDone: Value(progress.tasksDone + tasksDoneIncrement),
          lastTaskTitle: Value(lastTaskTitle ?? progress.lastTaskTitle),
          lastTaskCompletionTime: Value(lastTaskCompletionTime ?? progress.lastTaskCompletionTime),
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'notiva.db');
    final dbFile = File(path);
    final database = NativeDatabase(dbFile, logStatements: kDebugMode);

    return database;
  });
}