import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ExportData<T extends Object> {
  final List<T> data;
  final List<String> Function(T) headings;
  final List<String> Function(T) cellItems;
  final String? fileName;

  ExportData({
    this.fileName,
    required this.data,
    required this.headings,
    required this.cellItems,
  });

  List<String> getCellValue(T item) {
    return cellItems(item);
  }

  List<String> getHeadings() {
    return headings(data[0]);
  }

  //to EXCEL

  Future<(Exception?, String?)> toExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      for (var i = 0; i < getHeadings().length; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(getHeadings()[i]);
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .cellStyle = CellStyle(
          bold: true,
          // fontFamily: getCellValue(data[0], i),
          //fontSize: 12,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          textWrapping: TextWrapping.WrapText,
        );
      }
      for (var i = 0; i < data.length; i++) {
        for (var j = 0; j < getCellValue(data[i]).length; j++) {
          sheetObject
              .cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
              .value = TextCellValue(getCellValue(data[i])[j]);
        }
      }
      //increase width of columns to fit content
      for (var i = 0; i < getHeadings().length; i++) {
        sheetObject.setColumnAutoFit(i);
      }

      // save file in document folder
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String appDocumentsPath = appDocumentsDir.path;
      final String filePath = '$appDocumentsPath/$fileName';
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath).writeAsBytesSync(fileBytes);
        return Future.value((null, filePath));
      } else {
        return Future.value((Exception('File not created'), null));
      }
    } catch (e) {
      return Future.value((Exception(e.toString()), null));
    }
  }

  // to pdf
  Future<(Exception?, String?)> toPdf() async {
    try{
final PdfDocument document = PdfDocument();
// Add a new page to the document.
      final PdfPage page = document.pages.add();
// Create a PDF grid class to add tables.
      final PdfGrid grid = PdfGrid();
// Specify the columns count to the grid.
      grid.columns.add(count: getHeadings().length);
// Create the header row of the grid.
      final PdfGridRow headerRow = grid.headers.add(1)[0];
// Set style
      headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(126, 151, 173));
      headerRow.style.textBrush = PdfBrushes.white;
      headerRow.style.font = PdfStandardFont(PdfFontFamily.helvetica, 10,
          style: PdfFontStyle.regular);
// Add header values

      for (var i = 0; i < getHeadings().length; i++) {
        headerRow.cells[i].value = getHeadings()[i];
      }
// Add rows
      for (var i = 0; i < data.length; i++) {
        final PdfGridRow row = grid.rows.add();
        for (var j = 0; j < getCellValue(data[i]).length; j++) {
          row.cells[j].value = getCellValue(data[i])[j];
        }
      }
// Draw the grid to the PDF page.
      grid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, 0, page.getClientSize().width,
              page.getClientSize().height));
// Save the document.
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      final String appDocumentsPath = appDocumentsDir.path;
      final String filePath = '$appDocumentsPath/$fileName';
      File(filePath).writeAsBytesSync(await document.save());
      document.dispose();
      return Future.value((null, filePath));
    }catch(e){
      return Future.value((Exception(e.toString()), null));
    }
  }
}
