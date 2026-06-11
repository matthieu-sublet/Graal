import 'package:flutter/material.dart';

class PlayerState extends ChangeNotifier {
  int pointsDeVie = 20;
  int pointsDeVieMax = 20;
  List<String> inventaire = ['Excalibur Junior'];

  void modifierPointsDeVie(int valeur) {
    pointsDeVie += valeur;
    if (pointsDeVie > pointsDeVieMax) {
      pointsDeVie = pointsDeVieMax;
    }
    if (pointsDeVie <= 0) {
      pointsDeVie = 0;
      // Game Over à gérer plus tard
    }
    notifyListeners(); // Met à jour l'écran visuellement
  }

  void ajouterObjet(String objet) {
    inventaire.add(objet);
    notifyListeners();
  }

  bool possedeObjet(String objet) {
    return inventaire.contains(objet);
  }
}
