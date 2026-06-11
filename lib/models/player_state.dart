import 'package:flutter/material.dart';
import 'dart:math';

class PlayerState extends ChangeNotifier {
  int pointsDeVie = 20;
  int pointsDeVieMax = 20;
  List<String> inventaire = ['Excalibur Junior'];
  
  bool estEvanoui = false;
  bool estMort = false;

  final Random _random = Random();

  // --- GESTION DE LA SANTÉ ET DE L'INVENTAIRE ---

  void modifierPointsDeVie(int valeur) {
    pointsDeVie += valeur;
    
    if (pointsDeVie > pointsDeVieMax) {
      pointsDeVie = pointsDeVieMax;
    }
    
    if (pointsDeVie <= 0) {
      pointsDeVie = 0;
      estMort = true;
      estEvanoui = true;
    } else if (pointsDeVie <= 5) {
      estEvanoui = true;
      estMort = false;
    } else {
      estEvanoui = false;
      estMort = false;
    }
    
    notifyListeners(); 
  }

  void ajouterObjet(String objet) {
    inventaire.add(objet);
    notifyListeners();
  }

  bool possedeObjet(String objet) {
    return inventaire.contains(objet);
  }

  void retirerObjet(String objet) {
    inventaire.remove(objet);
    notifyListeners();
  }


  // --- MOTEUR DE RÈGLES ET DE COMBAT ---

  int lancerDes(int nombreDeDes) {
    int total = 0;
    for (int i = 0; i < nombreDeDes; i++) {
      total += _random.nextInt(6) + 1;
    }
    return total;
  }

  int calculerDommages(int jetDeDes, {int seuilTouche = 6, int degatsFixes = 0, int bonusDommage = 0}) {
    if (degatsFixes > 0) {
      return degatsFixes;
    }

    if (jetDeDes > seuilTouche) {
      return (jetDeDes - seuilTouche) + bonusDommage;
    }
    
    return 0;
  }

  Map<String, dynamic> attaqueDePip() {
    int jet = lancerDes(2);
    int seuil = 6;
    int bonus = 0;

    String armeUtilisee = 'Mains nues';
    if (possedeObjet('Excalibur Junior')) {
      armeUtilisee = 'Excalibur Junior';
      bonus = 5; 
    }

    int dommages = calculerDommages(jet, seuilTouche: seuil, bonusDommage: bonus);

    return {
      'jet': jet,
      'touche': dommages > 0,
      'dommages': dommages,
      'arme': armeUtilisee,
      'message': dommages > 0 
          ? "Vous avez obtenu $jet ! L'attaque réussit et inflige $dommages Points de Dommage avec $armeUtilisee."
          : "Vous avez obtenu $jet. L'attaque échoue lamentablement..."
    };
  }
}
