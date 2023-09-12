import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardCard {
  final String title;
  final IconData? icon;
  final SvgPicture? svg;
  final String routeName;

  DashboardCard(this.title, this.icon, this.svg, this.routeName);

  static getData() {
    return [
      DashboardCard(
          'Animal',
          null,
          SvgPicture.asset(
            'assets/images/cow-icon.svg',
            height: 50,
          ),
          '/ViewSearchAnimal'),
      DashboardCard(
          'Aplicação', FontAwesome5Solid.syringe, null, '/ViewSearchAplicacao'),
      DashboardCard(
          'Gestação',
          null,
          SvgPicture.asset(
            'assets/images/fetus-icon.svg',
            height: 50,
          ),
          '/ViewSearchGestacao'),
      DashboardCard('Lote', Icons.crop, null, '/ViewManageLote'),
      DashboardCard(
          'Medicação', Icons.medical_services, null, '/ViewSearchMedicacao'),
      DashboardCard(
          'Produção',
          null,
          SvgPicture.asset(
            'assets/images/milk-icon.svg',
            height: 50,
          ),
          '/ViewManageProducao'),
    ];
  }
}
