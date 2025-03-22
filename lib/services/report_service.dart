import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/candidate_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';

class ReportService {
  // show format selection dialog
  Future<String?> showExportFormatDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocale.exportFormat.getString(context)),
          content: Text(AppLocale.selectExportFormat.getString(context)),
          actions: <Widget>[
            TextButton(
              child: const Text('Excel'),
              onPressed: () {
                Navigator.of(context).pop('excel');
              },
            ),
            TextButton(
              child: const Text('PDF'),
              onPressed: () {
                Navigator.of(context).pop('pdf');
              },
            ),
            TextButton(
              child: Text(AppLocale.cancel.getString(context)),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      },
    );
  }

  // main export function - can be called from any page
  Future<void> exportVotingReport({
    required BuildContext context,
    required VotingEvent votingEvent,
    required String votingEventDate,
    required String votingEventTime,
    required bool isEnded,
    required Candidate? winner,
    required String generatedBy,
    required Function(bool, String) updateLoadingState,
  }) async {
    updateLoadingState(true, AppLocale.generatingReport.getString(context));
    
    try {
      // show format selection dialog
      final exportFormat = await showExportFormatDialog(context);
      if (exportFormat == null) {
        updateLoadingState(false, '');
        return;
      }
      
      if (exportFormat == 'excel') {
        await exportToExcel(
          context: context,
          votingEvent: votingEvent,
          votingEventDate: votingEventDate,
          votingEventTime: votingEventTime,
          isEnded: isEnded,
          winner: winner,
          generatedBy: generatedBy,
        );
      } else {
        await exportToPdf(
          context: context,
          votingEvent: votingEvent,
          votingEventDate: votingEventDate,
          votingEventTime: votingEventTime,
          isEnded: isEnded,
          winner: winner,
          generatedBy: generatedBy,
        );
      }
      
      SnackbarUtil.showSnackBar(
        context, 
        AppLocale.reportExportedSuccessfully.getString(context)
      );
    } catch (e) {
      print("Error exporting report: $e");
      SnackbarUtil.showSnackBar(
        context, 
        "${AppLocale.errorExportingReport.getString(context)}: $e"
      );
    } finally {
      updateLoadingState(false, '');
    }
  }

  // export to Excel
  Future<void> exportToExcel({
    required BuildContext context,
    required VotingEvent votingEvent,
    required String votingEventDate,
    required String votingEventTime,
    required bool isEnded,
    required Candidate? winner,
    required String generatedBy,
  }) async {
    // create a new Excel document
    final excel = Excel.createExcel();
    
    // remove the default sheet
    excel.delete('Sheet1');
    
    // create a sheet for the voting event details
    final detailSheet = excel['Voting Event Details'];
    
    // add title row with styling
    final titleStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
      horizontalAlign: HorizontalAlign.Center,
    );
    
    // add header for voting event details
    detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('Voting Event Report')
      ..cellStyle = titleStyle;
    
    // merge cells for the title
    detailSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
                      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0));
    
    // define a header style
    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#000000'),
      backgroundColorHex: ExcelColor.fromHexString('#D9E1F2'),
    );
    
    // add event information rows
    int rowIndex = 2;
    
    // add voting event details
    _addExcelRow(detailSheet, rowIndex++, 'Voting Event ID:', votingEvent.votingEventID, headerStyle);
    _addExcelRow(detailSheet, rowIndex++, 'Title:', votingEvent.title, headerStyle);
    _addExcelRow(detailSheet, rowIndex++, 'Description:', votingEvent.description, headerStyle);
    _addExcelRow(detailSheet, rowIndex++, 'Date:', votingEventDate, headerStyle);
    _addExcelRow(detailSheet, rowIndex++, 'Time:', votingEventTime, headerStyle);
    _addExcelRow(detailSheet, rowIndex++, 'Status:', votingEvent.status.name, headerStyle);
    _addExcelRow(detailSheet, rowIndex++, 'Total Votes Cast:', '${votingEvent.voters.length}', headerStyle);
    
    // add a space between sections
    rowIndex += 2;
    
    // add candidate information section header
    detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = TextCellValue('Candidate Information')
      ..cellStyle = titleStyle;
    
    detailSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
                      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
    rowIndex += 2;
    
    // add candidate table headers
    _addExcelTableHeader(detailSheet, rowIndex++, ['Name', 'User ID', 'Bio', 'Votes Received'], headerStyle);
    
    // sort candidates by votes (descending)
    final sortedCandidates = List<Candidate>.from(votingEvent.candidates)
      ..sort((a, b) => b.votesReceived.compareTo(a.votesReceived));
    
    // add candidate information
    for (var candidate in sortedCandidates) {
      detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = TextCellValue(candidate.name);
      detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = TextCellValue(candidate.userID);
      detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = TextCellValue(candidate.bio);
      detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = TextCellValue(candidate.votesReceived.toString());
      rowIndex++;
    }
    
    // add a space and winner information if voting has ended
    if (isEnded && winner != null) {
      rowIndex += 2;
      
      // add winner section header
      detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = TextCellValue('Winner Information')
        ..cellStyle = titleStyle;
      
      detailSheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
                        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
      rowIndex += 2;
      
      // add winner information
      _addExcelRow(detailSheet, rowIndex++, 'Winner:', winner.name, headerStyle);
      _addExcelRow(detailSheet, rowIndex++, 'Votes Received:', '${winner.votesReceived}', headerStyle);
      
      // calculate winning percentage safely
      final double winningPercentage = votingEvent.voters.isNotEmpty 
          ? (winner.votesReceived / votingEvent.voters.length * 100) 
          : 0.0;
      
      _addExcelRow(detailSheet, rowIndex++, 'Winning Percentage:', 
          '${winningPercentage.toStringAsFixed(2)}%', headerStyle);
    }
    
    // auto-fit columns
    for (var i = 0; i < 4; i++) {
      detailSheet.setColumnAutoFit(i);
    }
    
    // save the file
    final bytes = excel.encode();
    
    // get the app directory
    final directory = await getApplicationDocumentsDirectory();
    final dateFormat = DateFormat('yyyyMMdd_HHmmss');
    final fileName = 'voting_report_${dateFormat.format(DateTime.now())}.xlsx';
    final path = '${directory.path}/$fileName';
    
    // write to file
    final file = File(path);
    await file.writeAsBytes(bytes!);
    
    // share the file
    await Share.shareXFiles([XFile(path)], text: 'Voting Event Report');
  }

  // helper methods for Excel
  void _addExcelRow(Sheet sheet, int rowIndex, String label, String value, CellStyle headerStyle) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = TextCellValue(label)
      ..cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
      .value = TextCellValue(value);
  }

  void _addExcelTableHeader(Sheet sheet, int rowIndex, List<String> headers, CellStyle style) {
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex))
        ..value = TextCellValue(headers[i])
        ..cellStyle = style;
    }
  }

  // export to PDF
  Future<void> exportToPdf({
    required BuildContext context,
    required VotingEvent votingEvent,
    required String votingEventDate,
    required String votingEventTime,
    required bool isEnded,
    required Candidate? winner,
    required String generatedBy,
  }) async {
    // create a PDF document
    final pdf = pw.Document();
    
    // create a PDF theme with default fonts (removing Google Fonts dependency for simplification)
    // if you want to use Google Fonts, you'll need to add the printing package and PdfGoogleFonts
    
    // add pages to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // title
            pw.Header(
              level: 0,
              child: pw.Text('Voting Event Report', 
                style: pw.TextStyle(
                  fontSize: 24, 
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700
                )
              ),
            ),
            pw.SizedBox(height: 20),
            
            // voting event details
            pw.Header(level: 1, text: 'Voting Event Details'),
            _buildPdfInfoRow('Voting Event ID:', votingEvent.votingEventID),
            _buildPdfInfoRow('Title:', votingEvent.title),
            _buildPdfInfoRow('Description:', votingEvent.description),
            _buildPdfInfoRow('Date:', votingEventDate),
            _buildPdfInfoRow('Time:', votingEventTime),
            _buildPdfInfoRow('Status:', votingEvent.status.name == 'available' ? 
                            'Available' : 'Deprecated'),
            _buildPdfInfoRow('Total Votes Cast:', '${votingEvent.voters.length}'),
            pw.SizedBox(height: 20),
            
            // candidate information
            pw.Header(level: 1, text: 'Candidate Information'),
            _buildCandidatesTable(votingEvent.candidates),
            pw.SizedBox(height: 20),
            
            // winner information (if voting has ended)
            if (isEnded && winner != null) ...[
              pw.Header(level: 1, text: 'Winner Information'),
              _buildPdfInfoRow('Winner:', winner.name),
              _buildPdfInfoRow('Votes Received:', '${winner.votesReceived}'),
              
              // calculate winning percentage safely
              _buildPdfInfoRow(
                'Winning Percentage:', 
                '${(votingEvent.voters.isNotEmpty ? (winner.votesReceived / votingEvent.voters.length * 100) : 0).toStringAsFixed(2)}%'
              ),
            ],
            
            // signature and timestamp
            pw.SizedBox(height: 40),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
                pw.Text('Generated by: $generatedBy'),
              ],
            ),
          ];
        },
      ),
    );
    
    // get the directory
    final directory = await getApplicationDocumentsDirectory();
    final dateFormat = DateFormat('yyyyMMdd_HHmmss');
    final fileName = 'voting_report_${dateFormat.format(DateTime.now())}.pdf';
    final path = '${directory.path}/$fileName';
    
    // save the PDF
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    
    // share the PDF
    await Share.shareXFiles([XFile(path)], text: 'Voting Event Report');
  }

  // helper methods for PDF
  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCandidatesTable(List<Candidate> candidates) {
    // sort candidates by votes (descending)
    final sortedCandidates = List<Candidate>.from(candidates)
      ..sort((a, b) => b.votesReceived.compareTo(a.votesReceived));
    
    return pw.Table.fromTextArray(
      border: null,
      headerAlignment: pw.Alignment.centerLeft,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
      },
      headers: ['Name', 'User ID', 'Bio', 'Votes'],
      data: sortedCandidates.map((candidate) => [
        candidate.name,
        candidate.userID,
        candidate.bio,
        candidate.votesReceived.toString(),
      ]).toList(),
    );
  }
}