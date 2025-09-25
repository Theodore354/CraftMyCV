import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cv_helper_app/cv_storage.dart';
import 'package:cv_helper_app/models/index.dart';
import 'cv_preview_screen.dart';

class CvFormScreen extends StatefulWidget {
  /// If editing, pass the existing CV and its index in CvStorage
  final CvModel? initial;
  final int? storageIndex;

  const CvFormScreen({super.key, this.initial, this.storageIndex})
    : assert(
        (initial == null && storageIndex == null) ||
            (initial != null && storageIndex != null),
      );

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  // Skills (comma separated)
  final _skillsController = TextEditingController();

  // Dynamic lists
  final List<WorkEntry> _workEntries = [];
  final List<EducationEntry> _educationEntries = [];

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final cv = widget.initial!;
      _fullNameController.text = cv.fullName;
      _emailController.text = cv.email;
      _phoneController.text = cv.phone;
      _locationController.text = cv.location;
      _skillsController.text = cv.skills.join(', ');
      _workEntries.addAll(cv.workExperience);
      _educationEntries.addAll(cv.education);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  // ====== Add Work Entry ======
  void _addWorkEntry() {
    showDialog(
      context: context,
      builder: (ctx) {
        final jobController = TextEditingController();
        final companyController = TextEditingController();
        final startController = TextEditingController();
        final endController = TextEditingController();
        final respController = TextEditingController();

        return AlertDialog(
          title: const Text("Add Work Experience"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: jobController,
                  decoration: const InputDecoration(labelText: "Job Title"),
                ),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: "Company"),
                ),
                TextField(
                  controller: startController,
                  decoration: const InputDecoration(
                    labelText: "Start (e.g. Jan 2020)",
                  ),
                ),
                TextField(
                  controller: endController,
                  decoration: const InputDecoration(
                    labelText: "End (e.g. Dec 2022 / Present)",
                  ),
                ),
                TextField(
                  controller: respController,
                  decoration: const InputDecoration(
                    labelText: "Responsibilities",
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _workEntries.add(
                    WorkEntry(
                      jobTitle: jobController.text.trim(),
                      company: companyController.text.trim(),
                      start: startController.text.trim(),
                      end: endController.text.trim(),
                      responsibilities:
                          respController.text.trim().isEmpty
                              ? null
                              : respController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(ctx);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // ====== Add Education Entry ======
  void _addEducationEntry() {
    showDialog(
      context: context,
      builder: (ctx) {
        final degreeController = TextEditingController();
        final institutionController = TextEditingController();
        final startController = TextEditingController();
        final endController = TextEditingController();
        final descController = TextEditingController();

        return AlertDialog(
          title: const Text("Add Education"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: degreeController,
                  decoration: const InputDecoration(labelText: "Degree"),
                ),
                TextField(
                  controller: institutionController,
                  decoration: const InputDecoration(labelText: "Institution"),
                ),
                TextField(
                  controller: startController,
                  decoration: const InputDecoration(
                    labelText: "Start (e.g. Sep 2016)",
                  ),
                ),
                TextField(
                  controller: endController,
                  decoration: const InputDecoration(
                    labelText: "End (e.g. Jun 2020 / Present)",
                  ),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _educationEntries.add(
                    EducationEntry(
                      degree: degreeController.text.trim(),
                      institution: institutionController.text.trim(),
                      start: startController.text.trim(),
                      end: endController.text.trim(),
                      description:
                          descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(ctx);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ====== Next -> Preview -> Confirm & Save/Update ======
  Future<void> _onNext() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final skills =
        _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    final now = DateTime.now().millisecondsSinceEpoch;

    final base = CvModel(
      id: _isEditing ? widget.initial!.id : _newId(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      workExperience: List<WorkEntry>.from(_workEntries),
      education: List<EducationEntry>.from(_educationEntries),
      skills: skills,
      createdAt: _isEditing ? (widget.initial!.createdAt ?? now) : now,
      updatedAt: now,
    );

    // 1) Preview
    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CvPreviewScreen(cv: base),
        fullscreenDialog: true,
      ),
    );

    // 2) Persist only if confirmed
    if (confirmed == true) {
      final jsonStr = jsonEncode(base.toJson());

      if (_isEditing) {
        await CvStorage.update(widget.storageIndex!, jsonStr);
      } else {
        await CvStorage.add(jsonStr);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'CV updated' : 'CV saved')),
      );

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? "Edit CV" : "Build Your CV")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty)
                              ? "Enter your name"
                              : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(value);
                    return ok ? null : 'Enter a valid email';
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                const SizedBox(height: 20),

                // Work Experience
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Work Experience",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addWorkEntry,
                    ),
                  ],
                ),
                ..._workEntries.map(
                  (w) => Card(
                    child: ListTile(
                      title: Text("${w.jobTitle} at ${w.company}"),
                      subtitle: Text(
                        "${w.start} - ${w.end}\n${w.responsibilities ?? ''}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _workEntries.remove(w)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Education
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Education",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addEducationEntry,
                    ),
                  ],
                ),
                ..._educationEntries.map(
                  (e) => Card(
                    child: ListTile(
                      title: Text("${e.degree} — ${e.institution}"),
                      subtitle: Text(
                        "${e.start} - ${e.end}\n${e.description ?? ''}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => setState(() => _educationEntries.remove(e)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Skills
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    labelText: "Skills (comma separated)",
                  ),
                ),

                const SizedBox(height: 30),

                // Next -> Preview
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _onNext,
                    child: Text(
                      _isEditing ? "Preview Changes" : "Next",
                      style: const TextStyle(fontSize: 16),
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
