import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/contact_model.dart';

class ExcelService {
  Future<void> exportContacts(List<BusinessContact> contacts, {String folderName = "All_Contacts"}) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Contacts'];
    
    // Add Header
    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Company'),
      TextCellValue('Job Title'),
      TextCellValue('Email'),
      TextCellValue('Phone'),
      TextCellValue('Website'),
      TextCellValue('Address'),
      TextCellValue('LinkedIn'),
    ]);

    // Add Data
    for (var contact in contacts) {
      sheet.appendRow([
        TextCellValue(contact.name),
        TextCellValue(contact.company ?? ""),
        TextCellValue(contact.jobTitle ?? ""),
        TextCellValue(contact.email ?? ""),
        TextCellValue(contact.phone ?? ""),
        TextCellValue(contact.website ?? ""),
        TextCellValue(contact.address ?? ""),
        TextCellValue(contact.linkedin ?? ""),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final filePath = "${directory.path}/$folderName.xlsx";
    final fileBytes = excel.save();
    
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      await Share.shareXFiles([XFile(filePath)], text: 'Exported Contacts from CardVault');
    }
  }
}
