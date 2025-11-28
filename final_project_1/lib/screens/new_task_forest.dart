import 'package:flutter/material.dart';
import '../models/task.dart';
import 'main_forest.dart';
import 'tasks_screen_forest.dart';

class NewTaskScreen extends StatefulWidget {
  final String username;
  final Task? task;
  const NewTaskScreen({super.key, required this.username, this.task});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _notes;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _notes = TextEditingController(text: widget.task?.notes ?? '');
    if (widget.task != null) {
      _date = widget.task!.dateTime;
      _time = TimeOfDay.fromDateTime(widget.task!.dateTime!);
    }
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_date == null || _time == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick both date and time')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final dt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    final task = Task(
      id: widget.task?.id,
      title: _title.text.trim(),
      dateTime: dt,
      notes: _notes.text.trim(),
      username: widget.username,
    );

    try {
      final ok = widget.task == null
          ? await apiService.createTask(task, username: widget.username)
          : await apiService.updateTask(task);

      if (ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task saved!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TasksScreen(username: widget.username),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save task.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isEditing = widget.task != null;

    return Scaffold(
      body: Container(
        constraints: BoxConstraints(minHeight: height),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/forest.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: Stack(
                    children: [
                      Positioned(
                        left: -10,
                        top: 8,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: NotivaColors.gold,
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text(
                            'Back',
                            style: TextStyle(fontSize: 23),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Image.asset(
                    'assets/images/toddler.png',
                    width: 500,
                    height: 500,
                    fit: BoxFit.contain,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -140),
                  child: Container(
                    margin: const EdgeInsets.only(top: 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: NotivaColors.panel.withAlpha(242),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: NotivaColors.panelBorder,
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: NotivaColors.shadow,
                          offset: Offset(0, 6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              isEditing ? 'Edit Task' : 'Add Task',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: NotivaColors.gold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: NotivaColors.panel,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: NotivaColors.panelBorder,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: _title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Title',
                                hintStyle: TextStyle(color: Color(0xFFCBE5D7)),
                                border: InputBorder.none,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter title'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: NotivaColors.panel,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: NotivaColors.panelBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: _pickDate,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _date == null
                                            ? 'Date'
                                            : _date!.toLocal().toString().split(
                                                ' ',
                                              )[0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: NotivaColors.panel,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: NotivaColors.panelBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: _pickTime,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _time == null
                                            ? 'Time'
                                            : _time!.format(context),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: NotivaColors.panel,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: NotivaColors.panelBorder,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: _notes,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Notes',
                                hintStyle: TextStyle(color: Color(0xFFCBE5D7)),
                                border: InputBorder.none,
                              ),
                              maxLines: 4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final canSave =
                                  _date != null &&
                                  _time != null &&
                                  _title.text.trim().isNotEmpty;
                              return DecoratedBox(
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: NotivaColors.shadow,
                                      offset: Offset(0, 6),
                                      blurRadius: 12,
                                    ),
                                  ],
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      NotivaColors.buttonTop,
                                      NotivaColors.buttonBottom,
                                    ],
                                  ),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    onPressed: (canSave && !_isSaving)
                                        ? _save
                                        : null,
                                    child: _isSaving
                                        ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          )
                                        : Text(
                                            'Save',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: canSave
                                                  ? const Color.fromARGB(
                                                      255,
                                                      255,
                                                      248,
                                                      225,
                                                    )
                                                  : Colors.white38,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
