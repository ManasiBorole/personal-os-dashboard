import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:personal_os_dashboard/core/utils/date_utils.dart' as app_date;
import 'package:personal_os_dashboard/features/meetings/domain/entities/meeting.dart';

/// Generates PDF documents for meetings.
final class MeetingPdfExporter {
  const MeetingPdfExporter();

  Future<Uint8List> export(Meeting meeting) async {
    final doc = pw.Document();
    final dateLabel = app_date.DateUtils.formatDisplayDateTime(meeting.startTime);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              meeting.title,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          _row('Date & Time', dateLabel),
          _row('Duration', '${meeting.durationMinutes} minutes'),
          if (meeting.location != null) _row('Location', meeting.location!),
          _row('Status', meeting.status.label),
          if (meeting.reminderAt != null)
            _row(
              'Reminder',
              app_date.DateUtils.formatDisplayDateTime(meeting.reminderAt!),
            ),
          pw.SizedBox(height: 16),
          pw.Text('Agenda', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(meeting.agenda.isEmpty ? '-' : meeting.agenda),
          pw.SizedBox(height: 16),
          pw.Text(
            'Participants (${meeting.participants.length})',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          if (meeting.participants.isEmpty)
            pw.Text('-')
          else
            ...meeting.participants.map(
              (p) => pw.Text(
                '- ${p.name} (${p.role})${p.email.isNotEmpty ? ' - ${p.email}' : ''}',
              ),
            ),
          pw.SizedBox(height: 16),
          pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(meeting.notes.isEmpty ? '-' : meeting.notes),
          pw.SizedBox(height: 16),
          pw.Text(
            'Follow Up',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(meeting.followUp.isEmpty ? '-' : meeting.followUp),
          if (meeting.attachments.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Attachments',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            ...meeting.attachments.map((a) => pw.Text('- ${a.name}')),
          ],
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
