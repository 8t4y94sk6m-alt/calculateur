import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'dart:ui';

void main() => runApp(const ApplicationPoutreApp());

class ApplicationPoutreApp extends StatelessWidget {
  const ApplicationPoutreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculateur de Poutre',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const CalculateurPoutrePage(),
    );
  }
}

class CalculateurPoutrePage extends StatefulWidget {
  const CalculateurPoutrePage({super.key});

  @override
  State<CalculateurPoutrePage> createState() => _CalculateurPoutrePageState();
}

class _CalculateurPoutrePageState extends State<CalculateurPoutrePage> {
  final _hauteurTotaleCtrl = TextEditingController(text: "131 3/4");
  final _epaisseurDalleCtrl = TextEditingController(text: "12");
  final _hauteurPoutreCtrl = TextEditingController(text: "10");
  final _distanceAxeCtrl = TextEditingController(text: "117 1/2");
  final _hauteurCadreCtrl = TextEditingController(text: "72");
  final _colonneCtrl = TextEditingController(text: "11");

  double hTotale = 131.75;
  double eDalle = 12.0;
  double hPoutre = 10.0;
  double distAxe = 117.5;
  double hCadre = 72.0;
  double dimColonne = 11.0;

  String? errHTotale, errEDalle, errHPoutre, errDistAxe, errHCadre, errColonne;

  @override
  void initState() {
    super.initState();
    _executerRecalcul();
  }

  double _analyserValeur(String texte, Function(String?) setError) {
    final t = texte.trim();
    if (t.isEmpty) {
      setError("Champ requis");
      return 0.0;
    }

    try {
      double valeur;
      if (t.contains(' ')) {
        final parts = t.split(RegExp(r'\s+'));
        if (parts.length == 2) {
          double entier = double.parse(parts[0]);
          double frac = Fraction.fromString(parts[1]).toDouble();
          valeur = entier + frac;
        } else {
          throw const FormatException();
        }
      } else if (t.contains('/')) {
        valeur = Fraction.fromString(t).toDouble();
      } else {
        valeur = double.parse(t);
      }

      if (valeur <= 0) {
        setError("Doit être supérieur à 0");
        return 0.0;
      }

      setError(null);
      return valeur;
    } catch (e) {
      setError("Format invalide (ex: 131 3/4)");
      return 0.0;
    }
  }

  void _executerRecalcul() {
    setState(() {
      hTotale = _analyserValeur(_hauteurTotaleCtrl.text, (err) => errHTotale = err);
      eDalle = _analyserValeur(_epaisseurDalleCtrl.text, (err) => errEDalle = err);
      hPoutre = _analyserValeur(_hauteurPoutreCtrl.text, (err) => errHPoutre = err);
      distAxe = _analyserValeur(_distanceAxeCtrl.text, (err) => errDistAxe = err);
      hCadre = _analyserValeur(_hauteurCadreCtrl.text, (err) => errHCadre = err);
      dimColonne = _analyserValeur(_colonneCtrl.text, (err) => errColonne = err);
    });
  }

  String _convertirEnFractionMixte(double decimal) {
    if (decimal <= 0 || decimal.isNaN || decimal.isInfinite) return "0 \"";
    int entier = decimal.floor();
    double reste = decimal - entier;
    
    if (reste < 0.01) return "$entier \"";
    
    try {
      int seiziemes = (reste * 16).round();
      if (seiziemes == 0) return "$entier \"";
      if (seiziemes == 16) return "${entier + 1} \"";
      
      final frac = Fraction(seiziemes, 16).reduce();
      
      return entier == 0 ? "$frac \"" : "$entier $frac \"";
    } catch (e) {
      return "${decimal.toStringAsFixed(2)} \"";
    }
  }

  bool get unChampEstInvalide =>
      errHTotale != null || errEDalle != null || errHPoutre != null ||
      errDistAxe != null || errHCadre != null || errColonne != null;

  @override
  Widget build(BuildContext context) {
    double r1Hauteur = hTotale - eDalle - hPoutre - 0.75;
    double r2Longueur = distAxe - (2 * 0.5 * dimColonne);
    double r3Hauteur = distAxe + (2 * 0.5 * dimColonne);
    double r5Hauteur = hPoutre - 0.75 - 3.25;
    double r6Longueur = r3Hauteur; 
    double r6Hauteur = hPoutre - 0.75;
    double r7Total = hTotale - eDalle - hPoutre - 13.75 - hCadre;
    double r7Divise = r7Total / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculateur Poutre Symétrique"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("ENTRÉE DE DONNÉES (pouces)", Colors.green.shade700),
              const SizedBox(height: 12),
              
              _buildChampSaisie("Hauteur totale :", _hauteurTotaleCtrl, errHTotale),
              _buildChampSaisie("Épaisseur de la dalle :", _epaisseurDalleCtrl, errEDalle),
              _buildChampSaisie("Hauteur de la poutre :", _hauteurPoutreCtrl, errHPoutre),
              _buildChampSaisie("Distance axe en axe :", _distanceAxeCtrl, errDistAxe),
              _buildChampSaisie("Hauteur du cadre :", _hauteurCadreCtrl, errHCadre),
              _buildChampSaisie("Colonne (largeur/longueur) :", _colonneCtrl, errColonne),

              const SizedBox(height: 24),
              const Divider(thickness: 2, color: Colors.grey),
              const SizedBox(height: 16),

              _buildSectionHeader("PROJET #1 - RÉSULTATS", Colors.orange.shade800),
              const SizedBox(height: 12),

              if (unChampEstInvalide)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text("Calculs suspendus : veuillez corriger les erreurs.", style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                )
              else ...[
                _buildCardResultat("1. Hauteur coffrage de colonne", "Hauteur", r1Hauteur),
                _buildCardResultat("2. Plancher de la poutre", "Longueur", r2Longueur),
                _buildCardResultat("3. Lisses murets de la poutre", "Longueur (Axe+col)", r3Hauteur),
                _buildCardResultat("5. Montants murets poutre", "Hauteur", r5Hauteur),
                _buildCardResultatDouble("6. Parois de la poutre (contreplaqué)", "Longueur", r6Longueur, "Hauteur", r6Hauteur),
                _buildCardResultatDouble("7. Ajustement des vérins (approx.)", "Total restant", r7Total, "Divisé par 2 (Vérin)", r7Divise),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String titre, Color couleur) {
    return Row(
      children: [
        Container(width: 6, height: 24, color: couleur),
        const SizedBox(width: 8),
        Text(titre, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: couleur)),
      ],
    );
  }

  Widget _buildChampSaisie(String label, TextEditingController ctrl, String? errorText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
          Expanded(
            flex: 4,
            child: TextField(
              controller: ctrl,
              onChanged: (_) => _executerRecalcul(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                errorText: errorText,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                filled: true,
                fillColor: Colors.green.withOpacity(0.06),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green.shade300)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.teal, width: 2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardResultat(String item, String typeMesure, double valeur) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(typeMesure, style: TextStyle(color: Colors.grey.shade700, fontSize: 12))])),
          Text(_convertirEnFractionMixte(valeur), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.fractions()])),
        ],
      ),
    );
  }

  Widget _buildCardResultatDouble(String item, String label1, double val1, String label2, double val2) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label1, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                    Text(
                      _convertirEnFractionMixte(val1),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.fractions()]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label2, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                    Text(
                      _convertirEnFractionMixte(val2),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.fractions()]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
