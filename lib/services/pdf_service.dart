import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:piaget/models/assessment_model.dart';
import 'package:piaget/models/user_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndShareReport(
    AssessmentResult result,
    LearnerProfile learner,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM d, yyyy – h:mm a');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPdfHeader(result, learner, dateFormat),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildScoreSection(result),
          pw.SizedBox(height: 20),
          _buildStageSection(result),
          pw.SizedBox(height: 20),
          _buildCriteriaSection(result),
          pw.SizedBox(height: 20),
          _buildStrengthsSection(result),
          pw.SizedBox(height: 20),
          _buildDevelopmentAreasSection(result),
          pw.SizedBox(height: 20),
          _buildRecommendationsSection(result),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'MindTrack_Report_${learner.name.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(result.completedAt)}.pdf',
    );
  }

  static Future<void> printReport(
    AssessmentResult result,
    LearnerProfile learner,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMMM d, yyyy – h:mm a');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPdfHeader(result, learner, dateFormat),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildScoreSection(result),
          pw.SizedBox(height: 20),
          _buildStageSection(result),
          pw.SizedBox(height: 20),
          _buildCriteriaSection(result),
          pw.SizedBox(height: 20),
          _buildStrengthsSection(result),
          pw.SizedBox(height: 20),
          _buildDevelopmentAreasSection(result),
          pw.SizedBox(height: 20),
          _buildRecommendationsSection(result),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _buildPdfHeader(
    AssessmentResult result,
    LearnerProfile learner,
    DateFormat dateFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MindTrack Assessment Report',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Piaget Cognitive Development Assessment',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Text(
                '${result.overallScore.toStringAsFixed(1)}%',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: PdfColors.blue200, thickness: 1.5),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Learner: ${learner.name}', style: const pw.TextStyle(fontSize: 11)),
            pw.Text('Age: ${learner.age} years', style: const pw.TextStyle(fontSize: 11)),
            if (learner.className != null)
              pw.Text('Class: ${learner.className}', style: const pw.TextStyle(fontSize: 11)),
            pw.Text('Date: ${dateFormat.format(result.completedAt)}', style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by MindTrack - Piaget Assessment Tool',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildScoreSection(AssessmentResult result) {
    final scoreColor = result.overallScore >= 80
        ? PdfColors.green700
        : result.overallScore >= 60
            ? PdfColors.orange700
            : PdfColors.red700;

    final scoreLabel = result.overallScore >= 90
        ? 'Excellent'
        : result.overallScore >= 80
            ? 'Very Good'
            : result.overallScore >= 70
                ? 'Good'
                : result.overallScore >= 60
                    ? 'Fair'
                    : 'Needs Improvement';

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            children: [
              pw.Text('Overall Score', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(
                '${result.overallScore.toStringAsFixed(1)}%',
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: scoreColor),
              ),
              pw.SizedBox(height: 4),
              pw.Text(scoreLabel, style: pw.TextStyle(fontSize: 11, color: scoreColor)),
            ],
          ),
          pw.Column(
            children: [
              pw.Text('Cognitive Stage', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(
                result.assessmentStage,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.purple700),
              ),
            ],
          ),
          pw.Column(
            children: [
              pw.Text('Criteria Assessed', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(
                '${result.criteriaResults.length}',
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStageSection(AssessmentResult result) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.purple200),
        color: PdfColors.purple50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Identified Cognitive Stage',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.purple800),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            result.identifiedStage,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCriteriaSection(AssessmentResult result) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Criteria Results',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.5),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(4),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                _tableHeader('Criterion'),
                _tableHeader('Status'),
                _tableHeader('Score'),
                _tableHeader('Feedback'),
              ],
            ),
            ...result.criteriaResults.map((c) {
              final statusColor = c.status == CriterionStatus.achieved
                  ? PdfColors.green700
                  : c.status == CriterionStatus.developing
                      ? PdfColors.orange700
                      : PdfColors.red700;
              final statusText = c.status == CriterionStatus.achieved
                  ? 'Achieved'
                  : c.status == CriterionStatus.developing
                      ? 'Developing'
                      : 'Not Yet';

              return pw.TableRow(
                children: [
                  _tableCell(c.criterionName),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(statusText, style: pw.TextStyle(fontSize: 10, color: statusColor, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${c.score.toStringAsFixed(0)}%', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ),
                  _tableCell(c.feedback),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static pw.Widget _buildStrengthsSection(AssessmentResult result) {
    if (result.strengths.isEmpty) return pw.SizedBox();
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.green200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Strengths',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
          ),
          pw.SizedBox(height: 8),
          ...result.strengths.map((s) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.Text('  +  ', style: pw.TextStyle(color: PdfColors.green700, fontWeight: pw.FontWeight.bold)),
                    pw.Expanded(child: pw.Text(s, style: const pw.TextStyle(fontSize: 11))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static pw.Widget _buildDevelopmentAreasSection(AssessmentResult result) {
    if (result.developmentAreas.isEmpty) return pw.SizedBox();
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.orange200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Areas for Development',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800),
          ),
          pw.SizedBox(height: 8),
          ...result.developmentAreas.map((d) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.Text('  >  ', style: pw.TextStyle(color: PdfColors.orange700, fontWeight: pw.FontWeight.bold)),
                    pw.Expanded(child: pw.Text(d, style: const pw.TextStyle(fontSize: 11))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static pw.Widget _buildRecommendationsSection(AssessmentResult result) {
    if (result.suggestedActivities.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Personalized Development Plan',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        ...result.suggestedActivities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          final cleanText = activity.replaceFirst(RegExp(r'^[🎯📈💡🌟]\s*'), '');

          String activityType = 'Activity';
          PdfColor activityColor = PdfColors.blue700;
          if (activity.contains('🎯') || activity.startsWith('🎯')) {
            activityType = 'Priority Focus';
            activityColor = PdfColors.red700;
          } else if (activity.contains('📈') || activity.startsWith('📈')) {
            activityType = 'Reinforce';
            activityColor = PdfColors.orange700;
          } else if (activity.contains('💡') || activity.startsWith('💡')) {
            activityType = 'Enrichment';
            activityColor = PdfColors.purple700;
          } else if (activity.contains('🌟') || activity.startsWith('🌟')) {
            activityType = 'Continue';
            activityColor = PdfColors.green700;
          }

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        activityType,
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: activityColor),
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text('#${index + 1}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(cleanText, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
