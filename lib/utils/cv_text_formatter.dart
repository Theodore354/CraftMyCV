import 'package:cv_helper_app/models/index.dart';

/// Converts a structured CvModel into a plain-text CV.
/// This is what we'll send to the AI when enhancing.
String cvToPlainText(CvModel cv) {
  final buffer = StringBuffer();

  // ===== Header =====
  final name = cv.fullName.trim();
  if (name.isNotEmpty) {
    buffer.writeln(name);
  }

  final contacts = <String>[];
  if (cv.email.trim().isNotEmpty) contacts.add(cv.email.trim());
  if (cv.phone.trim().isNotEmpty) contacts.add(cv.phone.trim());
  if (cv.location.trim().isNotEmpty) contacts.add(cv.location.trim());

  if (contacts.isNotEmpty) {
    buffer.writeln(contacts.join(' • '));
  }

  buffer.writeln(); // blank line

  // ===== Work Experience =====
  if (cv.workExperience.isNotEmpty) {
    buffer.writeln('WORK EXPERIENCE');
    for (final w in cv.workExperience) {
      final job = w.jobTitle.trim();
      final company = w.company.trim();
      final titleLine = [
        if (job.isNotEmpty) job,
        if (company.isNotEmpty) company,
      ].join(' — ');
      if (titleLine.isNotEmpty) {
        buffer.writeln(titleLine);
      }

      final start = w.start.trim();
      final end = w.end.trim();
      final dateLine = [
        if (start.isNotEmpty) start,
        if (end.isNotEmpty) end,
      ].join(' — ');
      if (dateLine.isNotEmpty) {
        buffer.writeln(dateLine);
      }

      final resp = (w.responsibilities ?? '').trim();
      if (resp.isNotEmpty) {
        buffer.writeln(resp);
      }

      buffer.writeln(); // space between roles
    }
  }

  // ===== Education =====
  if (cv.education.isNotEmpty) {
    buffer.writeln('EDUCATION');
    for (final e in cv.education) {
      final degree = e.degree.trim();
      final inst = e.institution.trim();
      final titleLine = [
        if (degree.isNotEmpty) degree,
        if (inst.isNotEmpty) inst,
      ].join(' — ');
      if (titleLine.isNotEmpty) {
        buffer.writeln(titleLine);
      }

      final start = e.start.trim();
      final end = e.end.trim();
      final dateLine = [
        if (start.isNotEmpty) start,
        if (end.isNotEmpty) end,
      ].join(' — ');
      if (dateLine.isNotEmpty) {
        buffer.writeln(dateLine);
      }

      final desc = (e.description ?? '').trim();
      if (desc.isNotEmpty) {
        buffer.writeln(desc);
      }

      buffer.writeln();
    }
  }

  // ===== Skills =====
  if (cv.skills.isNotEmpty) {
    buffer.writeln('SKILLS');
    buffer.writeln(cv.skills.join(', '));
  }

  return buffer.toString().trim();
}
