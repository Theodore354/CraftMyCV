import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cv_helper_app/models/index.dart';
import 'package:cv_helper_app/services/firestore_service.dart';
import 'package:cv_helper_app/screens/cv_preview_screen.dart';

class CvFormScreen extends StatefulWidget {
  final CvModel? initial;

  const CvFormScreen({super.key, this.initial});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String fullName = '';
  String email = '';
  String phone = '';
  String location = '';
  List<WorkEntry> workExperience = [];
  List<EducationEntry> education = [];
  List<String> skills = [];

  final skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      fullName = init.fullName;
      email = init.email;
      phone = init.phone;
      location = init.location;
      workExperience = List<WorkEntry>.from(init.workExperience);
      education = List<EducationEntry>.from(init.education);
      skills = List<String>.from(init.skills);
    }
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }

  // ======= SAVE / PREVIEW =======
  Future<void> _saveCv(CvModel cv) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService.upsertCv(user.uid, cv);
  }

  Future<void> _previewAndSave() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final cv = CvModel(
      id: widget.initial?.id ?? '',
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      location: location.trim(),
      workExperience: workExperience,
      education: education,
      skills: skills,
    );

    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CvPreviewScreen(cv: cv)),
    );

    if (confirmed == true) {
      await _saveCv(cv);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CV saved successfully!')));
      Navigator.pop(context, true);
    }
  }

  // ======= DIALOGS =======
  Future<WorkEntry?> _showWorkEntryDialog({WorkEntry? initial}) async {
    final form = GlobalKey<FormState>();
    final jobCtl = TextEditingController(text: initial?.jobTitle ?? '');
    final companyCtl = TextEditingController(text: initial?.company ?? '');
    final startCtl = TextEditingController(text: initial?.start ?? '');
    final endCtl = TextEditingController(text: initial?.end ?? '');
    final respCtl = TextEditingController(
      text: initial?.responsibilities ?? '',
    );

    return showDialog<WorkEntry>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              initial == null ? 'Add Work Experience' : 'Edit Work Experience',
            ),
            content: Form(
              key: form,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: jobCtl,
                      decoration: const InputDecoration(
                        labelText: 'Job Title *',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                    ),
                    TextFormField(
                      controller: companyCtl,
                      decoration: const InputDecoration(labelText: 'Company *'),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                    ),
                    TextFormField(
                      controller: startCtl,
                      decoration: const InputDecoration(
                        labelText: 'Start (e.g., Jan 2020) *',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                    ),
                    TextFormField(
                      controller: endCtl,
                      decoration: const InputDecoration(
                        labelText: 'End (e.g., Dec 2022 or Present) *',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                    ),
                    TextFormField(
                      controller: respCtl,
                      decoration: const InputDecoration(
                        labelText: 'Responsibilities (optional)',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (form.currentState?.validate() != true) return;
                  Navigator.pop(
                    ctx,
                    WorkEntry(
                      jobTitle: jobCtl.text.trim(),
                      company: companyCtl.text.trim(),
                      start: startCtl.text.trim(),
                      end: endCtl.text.trim(),
                      responsibilities:
                          respCtl.text.trim().isEmpty
                              ? null
                              : respCtl.text.trim(),
                    ),
                  );
                },
                child: Text(initial == null ? 'Add' : 'Save'),
              ),
            ],
          ),
    );
  }

  Future<EducationEntry?> _showEducationDialog({
    EducationEntry? initial,
  }) async {
    final form = GlobalKey<FormState>();
    final degreeCtl = TextEditingController(text: initial?.degree ?? '');
    final instCtl = TextEditingController(text: initial?.institution ?? '');
    final startCtl = TextEditingController(text: initial?.start ?? '');
    final endCtl = TextEditingController(text: initial?.end ?? '');
    final descCtl = TextEditingController(text: initial?.description ?? '');

    return showDialog<EducationEntry>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(initial == null ? 'Add Education' : 'Edit Education'),
            content: Form(
              key: form,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: degreeCtl,
                      decoration: const InputDecoration(labelText: 'Degree *'),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                    ),
                    TextFormField(
                      controller: instCtl,
                      decoration: const InputDecoration(
                        labelText: 'Institution *',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                    ),
                    TextFormField(
                      controller: startCtl,
                      decoration: const InputDecoration(
                        labelText: 'Start (e.g., Jan 2018) *',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                    ),
                    TextFormField(
                      controller: endCtl,
                      decoration: const InputDecoration(
                        labelText: 'End (e.g., Dec 2022 or Present) *',
                      ),
                      validator:
                          (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                    ),
                    TextFormField(
                      controller: descCtl,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (form.currentState?.validate() != true) return;
                  Navigator.pop(
                    ctx,
                    EducationEntry(
                      degree: degreeCtl.text.trim(),
                      institution: instCtl.text.trim(),
                      start: startCtl.text.trim(),
                      end: endCtl.text.trim(),
                      description:
                          descCtl.text.trim().isEmpty
                              ? null
                              : descCtl.text.trim(),
                    ),
                  );
                },
                child: Text(initial == null ? 'Add' : 'Save'),
              ),
            ],
          ),
    );
  }

  // ======= UI HELPERS =======
  InputDecoration _prettyInputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconConstraints: const BoxConstraints(minWidth: 56),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: _IconBubble(icon: icon, color: primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: TextStyle(color: primary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text, VoidCallback onAdd) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ), // rectangular
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _workCard(int i, WorkEntry w) {
    return Dismissible(
      key: ValueKey('work_${i}_${w.jobTitle}_${w.company}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async => await _confirmDelete('work experience'),
      onDismissed: (_) => setState(() => workExperience.removeAt(i)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red.withOpacity(0.12),
        child: const Icon(Icons.delete_outline),
      ),
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.work_outline)),
          title: Text('${w.jobTitle} — ${w.company}'),
          subtitle: Text(
            [
              '${w.start} — ${w.end}',
              if ((w.responsibilities ?? '').isNotEmpty) w.responsibilities!,
            ].join('\n'),
          ),
          onTap: () async {
            final edited = await _showWorkEntryDialog(initial: w);
            if (edited != null) setState(() => workExperience[i] = edited);
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final edited = await _showWorkEntryDialog(initial: w);
                  if (edited != null)
                    setState(() => workExperience[i] = edited);
                },
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await _confirmDelete('work experience')) {
                    setState(() => workExperience.removeAt(i));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eduCard(int i, EducationEntry e) {
    return Dismissible(
      key: ValueKey('edu_${i}_${e.degree}_${e.institution}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async => await _confirmDelete('education'),
      onDismissed: (_) => setState(() => education.removeAt(i)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red.withOpacity(0.12),
        child: const Icon(Icons.delete_outline),
      ),
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.school_outlined)),
          title: Text('${e.degree} — ${e.institution}'),
          subtitle: Text(
            [
              '${e.start} — ${e.end}',
              if ((e.description ?? '').isNotEmpty) e.description!,
            ].join('\n'),
          ),
          onTap: () async {
            final edited = await _showEducationDialog(initial: e);
            if (edited != null) setState(() => education[i] = edited);
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final edited = await _showEducationDialog(initial: e);
                  if (edited != null) setState(() => education[i] = edited);
                },
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  if (await _confirmDelete('education')) {
                    setState(() => education.removeAt(i));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(String what) async {
    final res = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete item?'),
            content: Text('Are you sure you want to remove this $what?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Create CV' : 'Edit CV'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Let’s set up your CV',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Fill in the details below. You can add work & education entries and preview before saving.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 16),

              _fieldLabel(context, 'Full Name'),
              TextFormField(
                initialValue: fullName,
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                onSaved: (v) => fullName = v?.trim() ?? '',
                textInputAction: TextInputAction.next,
                decoration: _prettyInputDecoration(
                  context,
                  hint: 'Enter full name',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 12),

              _fieldLabel(context, 'Email'),
              TextFormField(
                initialValue: email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final ok = RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  ).hasMatch(v.trim());
                  return ok ? null : 'Enter a valid email';
                },
                onSaved: (v) => email = v?.trim() ?? '',
                textInputAction: TextInputAction.next,
                decoration: _prettyInputDecoration(
                  context,
                  hint: 'Enter email',
                  icon: Icons.mail_outline,
                ),
              ),
              const SizedBox(height: 12),

              _fieldLabel(context, 'Phone'),
              TextFormField(
                initialValue: phone,
                keyboardType: TextInputType.phone,
                onSaved: (v) => phone = v?.trim() ?? '',
                textInputAction: TextInputAction.next,
                decoration: _prettyInputDecoration(
                  context,
                  hint: 'Enter phone number',
                  icon: Icons.phone_iphone,
                ),
              ),
              const SizedBox(height: 12),

              _fieldLabel(context, 'Location'),
              TextFormField(
                initialValue: location,
                onSaved: (v) => location = v?.trim() ?? '',
                textInputAction: TextInputAction.done,
                decoration: _prettyInputDecoration(
                  context,
                  hint: 'City, Country',
                  icon: Icons.location_on_outlined,
                ),
              ),

              _sectionTitle(context, 'Work Experience', () async {
                final result = await _showWorkEntryDialog();
                if (result != null) setState(() => workExperience.add(result));
              }),
              if (workExperience.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    'No work experience added yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ...List.generate(
                workExperience.length,
                (i) => _workCard(i, workExperience[i]),
              ),

              _sectionTitle(context, 'Education', () async {
                final result = await _showEducationDialog();
                if (result != null) setState(() => education.add(result));
              }),
              if (education.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    'No education added yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ...List.generate(
                education.length,
                (i) => _eduCard(i, education[i]),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'Skills',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        final text = skillController.text.trim();
                        if (text.isNotEmpty) {
                          setState(() {
                            skills.add(text);
                            skillController.clear();
                          });
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: 'Add skill',
                    ),
                  ],
                ),
              ),
              TextField(
                controller: skillController,
                decoration: _prettyInputDecoration(
                  context,
                  hint: 'Enter a skill',
                  icon: Icons.sell_outlined,
                ),
                onSubmitted: (_) {
                  final text = skillController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      skills.add(text);
                      skillController.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    skills.asMap().entries.map((e) {
                      final idx = e.key;
                      final s = e.value;
                      return InputChip(
                        label: Text(s),
                        onDeleted: () => setState(() => skills.removeAt(idx)),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 24),

              _GradientButton(text: 'PREVIEW', onPressed: _previewAndSave),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ========= SMOL UI WIDGETS =========

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBubble({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 18),
      ), // show the actual icon
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x339C27B0),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
