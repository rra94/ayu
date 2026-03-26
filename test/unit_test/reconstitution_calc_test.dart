import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/utils/calc/reconstitution_calc.dart';

void main() {
  group('ReconstitutionCalc', () {
    test('BPC-157 standard reconstitution', () {
      // 5mg peptide + 2ml BAC water = 2500mcg/ml
      // 10 units on 100-unit syringe = 0.1ml = 250mcg
      final result = ReconstitutionCalc.calculate(
        peptideMg: 5, bacWaterMl: 2, doseUnits: 10,
      );
      expect(result.concentrationMcgPerMl, 2500);
      expect(result.doseMcg, 250);
      expect(result.dosesPerVial, 20);
    });

    test('TB-500 reconstitution', () {
      // 5mg + 1ml = 5000mcg/ml, 50 units = 0.5ml = 2500mcg
      final result = ReconstitutionCalc.calculate(
        peptideMg: 5, bacWaterMl: 1, doseUnits: 50,
      );
      expect(result.concentrationMcgPerMl, 5000);
      expect(result.doseMcg, 2500);
      expect(result.dosesPerVial, 2);
    });

    test('Semaglutide reconstitution', () {
      // 3mg + 1.5ml = 2000mcg/ml, 5 units = 0.05ml = 100mcg
      final result = ReconstitutionCalc.calculate(
        peptideMg: 3, bacWaterMl: 1.5, doseUnits: 5,
      );
      expect(result.concentrationMcgPerMl, 2000);
      expect(result.doseMcg, 100);
      expect(result.dosesPerVial, 30);
    });

    test('zero dose units returns zero', () {
      final result = ReconstitutionCalc.calculate(
        peptideMg: 5, bacWaterMl: 2, doseUnits: 0,
      );
      expect(result.doseMcg, 0);
      expect(result.dosesPerVial, 0);
    });
  });

  group('Injection site rotation', () {
    test('empty history returns first site', () {
      expect(ReconstitutionCalc.suggestNextSite([]), 'abdomen_left');
    });

    test('rotates through sites in order', () {
      expect(
        ReconstitutionCalc.suggestNextSite(['abdomen_left', 'abdomen_right', 'thigh_left']),
        'thigh_right',
      );
    });

    test('wraps around after last site', () {
      expect(
        ReconstitutionCalc.suggestNextSite(['glute_right']),
        'abdomen_left',
      );
    });

    test('unknown site returns first', () {
      expect(
        ReconstitutionCalc.suggestNextSite(['unknown_site']),
        'abdomen_left',
      );
    });
  });
}
