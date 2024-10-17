// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// class HouseRentHistory extends StatefulWidget {
//   @override
//   _HouseRentHistoryState createState() => _HouseRentHistoryState();
// }
//
// class _HouseRentHistoryState extends State<HouseRentHistory> {
//
//   // Define your other controllers and state variables here
//
//   Future<void> _printReceipt() async {
//     final pdf = pw.Document();
//
//     pdf.addPage(pw.Page(
//       build: (pw.Context context) {
//         return pw.Center(
//           child: pw.Column(
//             children: [
//               pw.Text('House Rent Receipt', style: pw.TextStyle(fontSize: 24)),
//               pw.SizedBox(height: 20),
//               pw.Text('Date: ____________'),
//               pw.Text('Receipt No: ____________'),
//               pw.Text('Received From: ____________________'),
//               pw.Text('the amount of \$____________'),
//               pw.Text('For Payment of ____________________'),
//               pw.Text('From _____________ to ____________'),
//               pw.Checkbox(value: false, label: pw.Text('Cash')),
//               pw.Checkbox(value: false, label: pw.Text('Cheque No: ______________')),
//               pw.Checkbox(value: false, label: pw.Text('Money Order')),
//               pw.SizedBox(height: 20),
//               pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Text('Total Amount to be Received: ____________'),
//                   pw.Text('Amount Received: ____________'),
//                   pw.Text('Balance Due: ____________'),
//                 ],
//               ),
//               pw.SizedBox(height: 20),
//               pw.Text('Received BY: _____________________ [Name]'),
//               pw.Text('Address: _________________________'),
//               pw.Text('Phone: _________________________'),
//             ],
//           ),
//         );
//       },
//     ));
//
//     // Printing or saving the PDF
//     await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('House Rent History'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Your other widgets and fields
//
//             const SizedBox(height: 10),
//             Center(
//               child: AnimatedButton(
//                 onPressed: _printReceipt, // Call the print receipt function
//                 text: "Print Rent Slip", // Button text
//                 buttonColor: Colors.blue, // Button color
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
