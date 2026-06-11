import 'package:flutter/material.dart';
import 'dart:math'; // Nécessaire pour générer des nombres aléatoires (les dés)

class PlayerState extends ChangeNotifier {
  int pointsDeVie = 20;
  int pointsDeVieMax = 20;
  List<String> inventaire = ['Excalibur Junior'];
  
  // Nouveaux statuts basés sur les règles
  bool estEvanoui = false;
  bool estMort = false;

  // Le générateur d'aléatoire pour nos lancers de dés
  final Random _random = Random();

  // --- GESTION DE LA SANTÉ ET DE L'INVENTAIRE ---

  void modifierPointsDeVie(int valeur) {
    pointsDeVie += valeur;
    
    if (pointsDeVie > pointsDeVieMax) {
      pointsDeVie = pointsDeVieMax;
    }
    
    // Application stricte des règles de la Quête du Graal :
    if (pointsDeVie <= 0) {
      pointsDeVie = 0;
      estMort = true;
      estEvanoui = true; // S'il est mort, il est techniquement évanoui aussi
    } else if (pointsDeVie <= 5) {
      // À 5 PV ou moins, Pip s'évanouit
      estEvanoui = true;
      estMort = false;
    } else {
      // Tout va bien
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

  /// Simule le lancer d'un certain nombre de dés à 6 faces
  int lancerDes(int nombreDeDes) {
    int total = 0;
    for (int i = 0; i < nombreDeDes; i++) {
      total += _random.nextInt(6) + 1; // Génère un nombre entre 1 et 6
    }
    return total;
  }

  /// Calcule les dommages infligés par une attaque
  /// Par défaut : il faut faire plus de 6, et les dommages = (Jet - 6)
  int calculerDommages(int jetDeDes, {int seuilTouche = 6, int degatsFixes = 0
