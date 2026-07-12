import 'package:flutter/material.dart';

/// Metadata for each calculator in the Mining Calculator Suite.
class CalculatorDefinition {
  const CalculatorDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

const kMassUnits = ['g', 'kg', 't', 'oz'];
const kGradeUnits = ['ppm', '%'];

const kCalculators = <CalculatorDefinition>[
  CalculatorDefinition(
    id: 'gold-value',
    title: 'Gold Value',
    subtitle: 'Weight, purity & price per gram',
    icon: Icons.monetization_on_outlined,
    route: '/calculators/gold-value',
  ),
  CalculatorDefinition(
    id: 'recovery',
    title: 'Recovery',
    subtitle: 'Feed vs tail grade recovery %',
    icon: Icons.trending_up_outlined,
    route: '/calculators/recovery',
  ),
  CalculatorDefinition(
    id: 'ore-grade',
    title: 'Ore Grade',
    subtitle: 'Gold grams per tonne processed',
    icon: Icons.landscape_outlined,
    route: '/calculators/ore-grade',
  ),
  CalculatorDefinition(
    id: 'cyanide',
    title: 'Cyanide Dosage',
    subtitle: 'NaCN kg/t from target ppm',
    icon: Icons.science_outlined,
    route: '/calculators/cyanide',
  ),
  CalculatorDefinition(
    id: 'slurry',
    title: 'Slurry Density',
    subtitle: 'Percent solids in slurry',
    icon: Icons.water_drop_outlined,
    route: '/calculators/slurry',
  ),
  CalculatorDefinition(
    id: 'ph',
    title: 'pH Adjustment',
    subtitle: 'Acid/base volume estimate',
    icon: Icons.opacity_outlined,
    route: '/calculators/ph',
  ),
  CalculatorDefinition(
    id: 'moisture',
    title: 'Moisture Correction',
    subtitle: 'Dry weight from wet sample',
    icon: Icons.grain_outlined,
    route: '/calculators/moisture',
  ),
  CalculatorDefinition(
    id: 'units',
    title: 'Unit Converter',
    subtitle: 'Mass & concentration units',
    icon: Icons.swap_horiz_outlined,
    route: '/calculators/units',
  ),
];

CalculatorDefinition calculatorById(String id) =>
    kCalculators.firstWhere((c) => c.id == id);
