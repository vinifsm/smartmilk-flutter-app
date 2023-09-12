import 'package:test_app/models/Animal.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AnimalReport {
  late String user;
  late List<Animal> list;
  AnimalReport({required this.list, required this.user});
}

class AnimalPrintReport {
  AnimalReport report;
  AnimalPrintReport({
    required this.report,
  });

  var peso = 0.0;
  var qtd = 0.0;

  generatePDF() async {
    report.list.forEach((element) {
      peso += element.peso;
      qtd++;
    });
    final pw.Document doc = pw.Document();
    final pw.Font customFont =
        pw.Font.ttf((await rootBundle.load('assets/font/RobotoSlabt.ttf')));
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
            margin: pw.EdgeInsets.zero,
            theme:
                pw.ThemeData(defaultTextStyle: pw.TextStyle(font: customFont))),
        header: _buildHeader,
        footer: _buildPrice,
        build: (context) => _buildContent(context),
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
        color: PdfColors.black,
        height: 150,
        child: pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.PdfLogo()),
                        pw.Text('Relatório de Animais Cadastrados',
                            style: const pw.TextStyle(
                                fontSize: 22, color: PdfColors.white))
                      ]),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('SmartMilk',
                          style: const pw.TextStyle(
                              fontSize: 22, color: PdfColors.white)),
                    ],
                  )
                ])));
  }

  List<pw.Widget> _buildContent(pw.Context context) {
    return [
      pw.Padding(
          padding: const pw.EdgeInsets.only(top: 30, left: 25, right: 25),
          child: _buildContentClient()),
      pw.Padding(
          padding: const pw.EdgeInsets.only(top: 50, left: 25, right: 25),
          child: _contentTable(context)),
    ];
  }

  pw.Widget _buildContentClient() {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _titleText('Usuário'),
              pw.Text(report.user[0].toUpperCase() + report.user.substring(1)),
            ],
          ),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            _titleText('Data'),
            pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()))
          ])
        ]);
  }

  _titleText(String text) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(text,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)));
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = [
      'Código',
      'Nome',
      'Numeração',
      'Produção Atual de Leite',
      'Peso'
    ];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerHeight: 25,
      cellHeight: 40,
      // Define o alinhamento das células, onde a chave é a coluna
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      // Define um estilo para o cabeçalho da tabela
      headerStyle: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.blue,
        fontWeight: pw.FontWeight.bold,
      ),
      // Define um estilo para a célula
      cellStyle: const pw.TextStyle(
        fontSize: 10,
      ),
      headers: tableHeaders,
      // retorna os valores da tabela, de acordo com a linha e a coluna
      data: List<List<String>>.generate(
        report.list.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => _getValueIndex(report.list[row], col),
        ),
      ),
    );
  }

  /// Retorna o valor correspondente a coluna
  String _getValueIndex(Animal animal, int col) {
    switch (col) {
      case 0:
        return animal.id.toString();
      case 1:
        return animal.nome;
      case 2:
        return animal.numero.toString();
      case 3:
        return animal.produzLeite ? 'Produz Leite' : 'Não Produz Leite';
      case 4:
        return animal.peso.toString();
    }
    return '';
  }

  /// Formata o valor informado na formatação pt/BR
  String _formatValue(double value) {
    final NumberFormat numberFormat = new NumberFormat("#,##0.00", "pt_BR");
    return numberFormat.format(value);
  }

  /// Retorna o rodapé da página
  pw.Widget _buildPrice(pw.Context context) {
    return pw.Container(
      color: PdfColors.black,
      height: 130,
      child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Padding(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 0),
                          child: pw.Text('Peso médio',
                              style:
                                  const pw.TextStyle(color: PdfColors.white))),
                      pw.Text('${(peso / qtd).toStringAsFixed(2)}',
                          style: const pw.TextStyle(
                              color: PdfColors.white, fontSize: 22))
                    ]))
          ]),
    );
  }
}
