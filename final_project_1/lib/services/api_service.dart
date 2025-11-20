import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/completed_task.dart';
import '../models/task.dart';
import '../models/task_list.dart';
import '../models/user_progress.dart';

/// A minimal REST API client for authentication.
// Updated to include fetchCompletedTasks
class ApiService {
  final String baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _storage;

  ApiService({
    required this.baseUrl,
    http.Client? client,
    FlutterSecureStorage? storage,
  }) : _client = client ?? http.Client(),
       _storage = storage ?? const FlutterSecureStorage();

  /// Try to log in using /auth/login. If that fails or doesn't return a token,
  /// try a json-server style lookup at /users?username=...&password=...
  Future<bool> login(String username, String password) async {
    final authUri = Uri.parse('$baseUrl/auth/login');
    try {
      final res = await _client.post(
        authUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (res.statusCode == 200) {
        try {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final token = data['token'] as String?;
          if (token != null) {
            await _storage.write(key: 'auth_token', value: token);
            return true;
          }
        } catch (_) {
          // fallthrough to fallback below
        }
      }
    } catch (_) {
      // ignore and try fallback
    }

    // Fallback for json-server: query /users?username=...&password=...
    try {
      final qUri = Uri.parse(
        '$baseUrl/users?username=${Uri.encodeQueryComponent(username)}&password=${Uri.encodeQueryComponent(password)}',
      );
      final qRes = await _client.get(qUri);
      if (qRes.statusCode == 200) {
        final list = jsonDecode(qRes.body) as List<dynamic>;
        if (list.isNotEmpty) {
          // Generate a simple token for local testing and store it
          final token = base64Encode(
            utf8.encode('$username:${DateTime.now().millisecondsSinceEpoch}'),
          );
          await _storage.write(key: 'auth_token', value: token);
          return true;
        }
      }
    } catch (_) {
      // network error
    }

    return false;
  }

  /// Try /auth/signup, otherwise POST to /users (json-server style).
  Future<bool> signup(String username, String email, String password) async {
    final authUri = Uri.parse('$baseUrl/auth/signup');
    try {
      final res = await _client.post(
        authUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // If an auth token is returned, save it.
        try {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final token = data['token'] as String?;
          if (token != null) {
            await _storage.write(key: 'auth_token', value: token);
          }
        } catch (_) {}
        return true;
      }
    } catch (_) {
      // ignore and try fallback
    }

    // Fallback for json-server: create a user at /users
    try {
      final uri = Uri.parse('$baseUrl/users');
      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        // create a simple token and store it for local testing
        final token = base64Encode(
          utf8.encode('$username:${DateTime.now().millisecondsSinceEpoch}'),
        );
        await _storage.write(key: 'auth_token', value: token);
        return true;
      }
    } catch (_) {
      // network error
    }

    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async => _storage.read(key: 'auth_token');

  Future<List<Task>> fetchTasks({String? username}) async {
    try {
      var uriStr = '$baseUrl/tasks';
      if (username != null && username.isNotEmpty) {
        uriStr += '?username=${Uri.encodeQueryComponent(username)}';
      }
      final uri = Uri.parse(uriStr);
      final res = await _client.get(uri);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((e) {
          final map = e as Map<String, dynamic>;
          DateTime? dt;
          if (map['dateTime'] != null) {
            try {
              dt = DateTime.parse(map['dateTime'] as String);
            } catch (_) {}
          }
          return Task(
            id: map['id'] as String?,
            taskListId: map['taskListId'] as String?,
            title: map['title'] as String? ?? '',
            dateTime: dt,
            notes: map['notes'] as String?,
            username: map['username'] as String?,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<TaskList>> fetchTaskLists() async {
    try {
      final uri = Uri.parse('$baseUrl/task-lists');
      final res = await _client.get(uri);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return list.map((e) => TaskList.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<UserProgress?> fetchUserProgress(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/user-progress?userId=$userId');
      final res = await _client.get(uri);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        if (list.isNotEmpty) {
          return UserProgress.fromJson(list.first);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<List<CompletedTask>> fetchCompletedTasks(String username) async {
    try {
      final user = await getUserByUsername(username);
      if (user == null) return [];
      final userId = user['id'] as String?;
      if (userId == null) return [];

      final uri = Uri.parse('$baseUrl/user-progress?userId=$userId');
      final res = await _client.get(uri);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        if (list.isNotEmpty) {
          final progress = UserProgress.fromJson(list.first);
          return progress.completedTasks.map((e) => CompletedTask.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<bool> clearHistory(String username) async {
    try {
      final user = await getUserByUsername(username);
      if (user == null) return false;
      final userId = user['id'] as String?;
      if (userId == null) return false;

      final progress = await fetchUserProgress(userId);
      if (progress == null) return false;

      progress.completedTasks.clear();

      return await updateUserProgress(progress);
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUserProgress(UserProgress progress) async {
    try {
      final isNew = progress.id == 'new_progress';
      final uri = isNew
          ? Uri.parse('$baseUrl/user-progress')
          : Uri.parse('$baseUrl/user-progress/${progress.id}');

      final body = progress.toJson();
      if (isNew) {
        body.remove('id'); // Let the server generate the ID
      }

      final response = isNew
          ? await _client.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
          : await _client.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }



  Future<bool> createTask(Task t, {String? username}) async {
    try {
      final uri = Uri.parse('$baseUrl/tasks');
      final body = <String, dynamic>{'title': t.title};
      if (t.dateTime != null) body['dateTime'] = t.dateTime!.toIso8601String();
      if (t.notes != null && t.notes!.isNotEmpty) body['notes'] = t.notes;
      if (username != null && username.isNotEmpty) body['username'] = username;

      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return res.statusCode == 201 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTask(Task t) async {
    if (t.id == null) return false;
    try {
      final uri = Uri.parse('$baseUrl/tasks/${t.id}');
      final body = <String, dynamic>{'title': t.title};
      if (t.dateTime != null) body['dateTime'] = t.dateTime!.toIso8601String();
      if (t.notes != null && t.notes!.isNotEmpty) body['notes'] = t.notes;

      final res = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }


  Future<bool> deleteTask(String taskId) async {
    try {
      final uri = Uri.parse('$baseUrl/tasks/$taskId');
      final res = await _client.delete(uri);
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTasks(List<String> taskIds) async {
    try {
      for (final taskId in taskIds) {
        final uri = Uri.parse('$baseUrl/tasks/$taskId');
        await _client.delete(uri);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/users?username=${Uri.encodeQueryComponent(username)}',
      );
      final res = await _client.get(uri);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        if (list.isNotEmpty) {
          return Map<String, dynamic>.from(list.first as Map);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateUserByUsername(
    String username, {
    String? newUsername,
    String? email,
    String? password,
  }) async {
    try {
      final user = await getUserByUsername(username);
      if (user == null) return false;
      final id = user['id'];
      if (id == null) return false;

      final uri = Uri.parse('$baseUrl/users/$id');
      final body = <String, dynamic>{};
      if (newUsername != null && newUsername.isNotEmpty)
        body['username'] = newUsername;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (body.isEmpty) return false;

      final res = await _client.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
