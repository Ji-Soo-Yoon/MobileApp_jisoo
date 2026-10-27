import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/time_entry_model.dart';
import '../data_providers/time_entry_provider.dart';
import '../widgets/add_project_dialog.dart';
import '../widgets/add_task_dialog.dart';

class AddTimeEntryScreen extends StatefulWidget {
  final TimeEntry? initialTimeEntry;

  const AddTimeEntryScreen({super.key, this.initialTimeEntry});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  late TextEditingController _totalTimeController;
  //late TextEditingController _payeeController;
  late TextEditingController _noteController;
  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _totalTimeController = TextEditingController(
        text: widget.initialTimeEntry?.totalTime.toString() ?? '');
    // _payeeController =
    //     TextEditingController(text: widget.initialExpense?.payee ?? '');
    _noteController =
        TextEditingController(text: widget.initialTimeEntry?.notes ?? '');
    _selectedDate = widget.initialTimeEntry?.date ?? DateTime.now();
    _selectedProjectId = widget.initialTimeEntry?.projectId;
    _selectedTaskId = widget.initialTimeEntry?.taskId;
  }

  @override
  Widget build(BuildContext context) {
    final timeProvider = Provider.of<TimeEntryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.initialTimeEntry == null ? 'Add Time Entry' : 'Edit Time Entry'),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 8.0), // Adjust the padding as needed
              child: buildProjectDropdown(timeProvider),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 8.0), // Adjust the padding as needed
              child: buildTaskDropdown(timeProvider),
            ),
            buildDateField(_selectedDate),
            buildTextField(_totalTimeController, 'Total Time (hours)',
                TextInputType.numberWithOptions(decimal: true)),
            buildTextField(_noteController, 'note', TextInputType.text),
            // buildCategoryDropdown(expenseProvider),
            // buildTagDropdown(expenseProvider),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: _saveTimeEntry,
          child: Text('Save Time Entry'),
        ),
      ),
    );
  }
  // Helper methods for building the form elements go here (omitted for brevity)

  void _saveTimeEntry() {
    if (_totalTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all required fields!')));
      return;
    }
    if(_selectedProjectId == null || _selectedTaskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a project and a task!')));
      return;
    }
    

    final timeEntry = TimeEntry(
      id: Provider.of<TimeEntryProvider>(context, listen: false).generateTimeEntryId().toString(),
      totalTime: double.parse(_totalTimeController.text),
      projectId: _selectedProjectId!,
      taskId: _selectedTaskId!,
      notes: _noteController.text,
      date: _selectedDate,
    );

    // Calling the provider to add or update the expense
    Provider.of<TimeEntryProvider>(context, listen: false)
        .addOrUpdateTimeEntries(timeEntry);
    Navigator.pop(context);
  }

  // Helper method to build a text field
  Widget buildTextField(
      TextEditingController controller, String label, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: type,
      ),
    );
  }

// Helper method to build the date picker field
  Widget buildDateField(DateTime selectedDate) {
    return ListTile(
      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
    );
  }

// Helper method to build the project dropdown
  Widget buildProjectDropdown(TimeEntryProvider provider) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedProjectId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          showDialog(
            context: context,
            builder: (context) => AddProjectDialog(onAdd: (newCategory) {
              setState(() {
                _selectedProjectId =
                    newCategory.id; // Automatically select the new category
                provider.addProject(
                    newCategory); // Add to provider, assuming this method exists
              });
            }),
          );
        } else {
          setState(() => _selectedProjectId = newValue);
        }
      },
      items: provider.projects.map<DropdownMenuItem<String>>((project) {
        return DropdownMenuItem<String>(
          value: project.id,
          child: Text(project.name),
        );
      }).toList()
        ..add(DropdownMenuItem(
          value: "New",
          child: Text("Add New Project"),
        )),
      decoration: InputDecoration(
        labelText: 'Project',
        border: OutlineInputBorder(),
      ),
    );
  }

// Helper method to build the task dropdown
  Widget buildTaskDropdown(TimeEntryProvider provider) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedTaskId,
      onChanged: (newValue) {
        if (newValue == 'New') {
          showDialog(
            context: context,
            builder: (context) => AddTaskDialog(onAdd: (newTask) {
              provider.addTask(newTask); // Assuming you have an `addTask` method.
              setState(
                  () => _selectedTaskId = newTask.id); // Update selected tag ID
            }),
          );
        } else {
          setState(() => _selectedTaskId = newValue);
        }
      },
      items: provider.tasks.map<DropdownMenuItem<String>>((task) {
        return DropdownMenuItem<String>(
          value: task.id,
          child: Text(task.name),
        );
      }).toList()
        ..add(DropdownMenuItem(
          value: "New",
          child: Text("Add New Task"),
        )),
      decoration: InputDecoration(
        labelText: 'Task',
        border: OutlineInputBorder(),
      ),
    );
  }
}
