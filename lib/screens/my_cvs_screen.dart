import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cv_helper_app/models/index.dart';
import 'package:cv_helper_app/services/firestore_service.dart';
import 'package:cv_helper_app/screens/cv_form_screen.dart';
import 'package:cv_helper_app/screens/cv_preview_screen.dart';

class MyCvsScreen extends StatefulWidget {
  const MyCvsScreen({super.key});

  @override
  State<MyCvsScreen> createState() => _MyCvsScreenState();
}

class _MyCvsScreenState extends State<MyCvsScreen> {
  late Stream<List<CvModel>> _streamCvs;
  final _searchCtl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadCvs();
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  void _loadCvs() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _streamCvs = FirestoreService.watchCvs(user.uid);
    } else {
      _streamCvs = const Stream<List<CvModel>>.empty();
    }
  }

  Future<void> _refresh() async {
    setState(_loadCvs);
  }

  Future<void> _deleteCv(String cvId, String title) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sure = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete CV?'),
            content: Text(
              'This will permanently remove “${title.isEmpty ? 'Untitled CV' : title}”.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (sure == true) {
      await FirestoreService.deleteCv(user.uid, cvId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CV deleted')));
    }
  }

  Future<void> _editCv(CvModel cv) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CvFormScreen(initial: cv)),
    );
    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CV updated')));
    }
  }

  void _previewCv(CvModel cv) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CvPreviewScreen(cv: cv)),
    );
  }

  Future<void> _duplicateCv(CvModel cv) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dup = CvModel(
      id: '',
      fullName: cv.fullName,
      email: cv.email,
      phone: cv.phone,
      location: cv.location,
      workExperience: List.from(cv.workExperience),
      education: List.from(cv.education),
      skills: List.from(cv.skills),
      templateId: cv.templateId, // ✅ keep same template
    );

    await FirestoreService.upsertCv(user.uid, dup);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Duplicated as new CV')));
  }

  Future<void> _createCv() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CvFormScreen()),
    );
    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CV created')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My CVs"),
        actions: [
          IconButton(
            tooltip: 'Create CV',
            onPressed: _createCv,
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCv,
        icon: const Icon(Icons.add),
        label: const Text('New CV'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtl,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name, email, location, skill…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<List<CvModel>>(
              stream: _streamCvs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ListSkeleton();
                }
                if (snapshot.hasError) {
                  return _ErrorState(
                    message:
                        'Failed to load CVs. Pull to refresh or try again.',
                    onRetry: _refresh,
                  );
                }

                final all = snapshot.data ?? const <CvModel>[];
                final filtered =
                    _query.isEmpty
                        ? all
                        : all.where((c) {
                          final hay =
                              [
                                c.fullName,
                                c.email,
                                c.phone,
                                c.location,
                                ...c.skills,
                              ].join(' ').toLowerCase();
                          return hay.contains(_query);
                        }).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(onCreate: _createCv);
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final cv = filtered[index];
                      return _CvCard(
                        cv: cv,
                        onTap: () => _previewCv(cv),
                        onEdit: () => _editCv(cv),
                        onDuplicate: () => _duplicateCv(cv),
                        onDelete: () => _deleteCv(cv.id, cv.fullName),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===== helper widgets =====

class _CvCard extends StatelessWidget {
  final CvModel cv;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _CvCard({
    required this.cv,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final title = cv.fullName.isEmpty ? 'Untitled CV' : cv.fullName;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primary.withOpacity(.12),
                child: Text(
                  _initials(title),
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TrimmedColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (cv.templateId.isNotEmpty)
                          _TemplateBadge(templateId: cv.templateId),
                        if (cv.location.isNotEmpty)
                          _MiniPill(
                            icon: Icons.location_on_outlined,
                            text: cv.location,
                          ),
                        if (cv.email.isNotEmpty)
                          _MiniPill(icon: Icons.mail_outline, text: cv.email),
                        if (cv.skills.isNotEmpty)
                          _MiniPill(
                            icon: Icons.sell_outlined,
                            text: _firstSkills(cv.skills),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CardMenu(
                onPreview: onTap,
                onEdit: onEdit,
                onDuplicate: onDuplicate,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _firstSkills(List<String> skills) {
    if (skills.isEmpty) return '';
    if (skills.length == 1) return skills.first;
    return '${skills.first} +${skills.length - 1}';
  }

  String _initials(String s) {
    final parts =
        s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '👤';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}

class _TemplateBadge extends StatelessWidget {
  final String templateId;
  const _TemplateBadge({required this.templateId});

  String _prettyName(String id) {
    switch (id) {
      case "modern_cv":
        return "Modern";
      case "professional_cv":
        return "Professional";
      case "creative_cv":
        return "Creative";
      case "minimal_cv":
        return "Minimal";
      default:
        return "Default";
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.primary.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 13, color: scheme.primary),
          const SizedBox(width: 5),
          Text(
            _prettyName(templateId),
            style: TextStyle(
              fontSize: 12,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _CardMenu({
    required this.onPreview,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (v) {
        switch (v) {
          case 'preview':
            onPreview();
            break;
          case 'edit':
            onEdit();
            break;
          case 'duplicate':
            onDuplicate();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder:
          (ctx) => [
            const PopupMenuItem(
              value: 'preview',
              child: ListTile(
                leading: Icon(Icons.visibility_outlined),
                title: Text('Preview'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: ListTile(
                leading: Icon(Icons.copy_outlined),
                title: Text('Duplicate'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: scheme.error),
                title: Text('Delete', style: TextStyle(color: scheme.error)),
              ),
            ),
          ],
      icon: const Icon(Icons.more_vert),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'No CVs yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first CV to get started.',
              style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: FilledButton(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Create CV'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 56, color: scheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceVariant.withOpacity(.6);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, _) {
        return Container(
          height: 76,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

class _TrimmedColumn extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  const _TrimmedColumn({
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
