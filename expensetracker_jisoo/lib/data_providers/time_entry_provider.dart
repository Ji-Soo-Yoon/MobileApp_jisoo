import 'package:flutter/foundation.dart';
import '../models/time_entry_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class TimeEntryProvider with ChangeNotifier {
  final LocalStorage storage;
  // List of expenses
  List<TimeEntry> _timeEntries = [];
  List<Task> _tasks = [];
  List<Project> _projects = [];

  // List of categories
  /*
  final List<Project> _projects = [
    Project(id: '1', name: 'Something Big', isDefault: false),
    Project(id: '2', name: 'Mind Blowing', isDefault: false),
    Project(id: '3', name: 'Fake', isDefault: false),
    Project(id: '4', name: 'Money Hungry', isDefault: false),
    Project(id: '5', name: 'Bottomless Pit', isDefault: false),
  ];

  // List of tags

  final List<Task> _tasks = [
    Task(id: '1', name: 'Breakfast'),
    Task(id: '2', name: 'Lunch'),
    Task(id: '3', name: 'Dinner'),
    Task(id: '4', name: 'Treat'),
    Task(id: '5', name: 'Vacation'),
    Task(id: '6', name: 'Shopping'),    
    Task(id: '7', name: 'SelfCare'),
    Task(id: '8', name: 'Streaming'),
  ];
  */

  // Getters
  List<TimeEntry> get timeEntries => _timeEntries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  TimeEntryProvider(this.storage) {
    _loadProjectsFromStorage();
    _loadTasksFromStorage();
    _loadTimeEntriesFromStorage();
  }

  void _loadTimeEntriesFromStorage() {
  var storedTimeEntries = storage.getItem('timeEntries');
  if (storedTimeEntries != null) {
    final List<dynamic> decoded = jsonDecode(storedTimeEntries);
    _timeEntries = decoded
        .map((item) => TimeEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
    _saveTimeEntriesToStorage();
  }

}

void _loadProjectsFromStorage() {
  var storedProjects = storage.getItem('projects');
  if (storedProjects != null) {
    final List<dynamic> decoded = jsonDecode(storedProjects);
    _projects = decoded
        .map((item) => Project.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
      storage.setItem(
        'projects',
        jsonEncode(_projects.map((p) => p.toJson()).toList()),
      );
  }
}

void _loadTasksFromStorage() {
  var storedTasks = storage.getItem('tasks');
  if (storedTasks != null) {
    final List<dynamic> decoded = jsonDecode(storedTasks);
    _tasks = decoded
        .map((item) => Task.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
  }
  else
  {
      storage.setItem(
        'tasks',
        jsonEncode(_tasks.map((t) => t.toJson()).toList()),
      );
  }
}

  // Add an expense
  void addTimeEntry(TimeEntry timeEntry) {
    _timeEntries.add(timeEntry);
    _saveTimeEntriesToStorage();
    notifyListeners();
  }

 void _saveTimeEntriesToStorage() {
  storage.setItem(
    'timeEntries',
    jsonEncode(_timeEntries.map((e) => e.toJson()).toList()),
  );
}

  void addOrUpdateTimeEntries(TimeEntry timeEntry) {
    int index = _timeEntries.indexWhere((e) => e.id == timeEntry.id);
    if (index != -1) {
      // Update existing expense
      _timeEntries[index] = timeEntry;
    } else {
      // Add new time entry
      _timeEntries.add(timeEntry);
    }
    _saveTimeEntriesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Delete an expense
  void deleteTimeEntry(String id) {
    _timeEntries.removeWhere((timeEntry) => timeEntry.id == id);
    _saveTimeEntriesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }

  // Add a category
  void addProject(Project project) {
    if (!_projects.any((p) => p.name == project.name)) {
      _projects.add(project);
      storage.setItem(
        'projects',
        jsonEncode(_projects.map((p) => p.toJson()).toList()),
      );
      notifyListeners();
    }
  }

  //add tasks
  void addTask(Task task) {
    if (!_tasks.any((t) => t.name == task.name)) {
      _tasks.add(task);
      storage.setItem(
        'tasks',
        jsonEncode(_tasks.map((t) => t.toJson()).toList()),
      );
      notifyListeners();
    }
  }

  // Delete a category
  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    notifyListeners();
  }

  // Delete a tag
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  int generateProjectId() {
    return projects.length;
  }

  int generateTaskId() {
    return tasks.length;
  }

  int generateTimeEntryId() {
    return timeEntries.length;
  }
/*
  void removeTimeEntry(String id) {
    _timeEntries.removeWhere((timeEntry) => timeEntry.id == id);
    _saveTimeEntriesToStorage(); // Save the updated list to local storage
    notifyListeners();
  }*/
}
