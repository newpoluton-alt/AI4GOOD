import 'package:flutter/widgets.dart';

import '../../../core/localization/app_localizations.dart';

class DataReviewStrings {
  const DataReviewStrings(this.languageCode);

  final String languageCode;

  bool get isFrench => languageCode == 'fr';

  String get welcome => isFrench ? 'Bienvenue' : 'Welcome';
  String get dataUpload => isFrench ? 'Import de données' : 'Data upload';
  String get myData => isFrench ? 'Mes données' : 'My data';
  String get aiDataAnalysis =>
      isFrench ? 'Analyse IA des données' : 'AI data analysis';
  String get uploadSubtitle => isFrench
      ? 'Importez un fichier Excel ou CSV'
      : 'Import an Excel or CSV file';
  String get myDataSubtitle => isFrench
      ? 'Consultez, téléchargez ou supprimez vos fichiers'
      : 'View, download, or remove your files';
  String get analysisSubtitle => isFrench
      ? 'Sélectionnez des données finalisées et lancez MadAInsight'
      : 'Select finalized data and run MadAInsight';
  String get uploadPrompt =>
      isFrench ? 'Importez vos données ici' : 'Please upload your data here';
  String get uploading => isFrench ? 'Import en cours...' : 'Uploading...';
  String get uploadComplete => isFrench ? 'Import terminé' : 'Upload complete';
  String get dataPreview => isFrench ? 'Aperçu des données' : 'Data preview';
  String get aiReview =>
      isFrench ? 'Révision MadAInsight' : 'MadAInsight review';
  String get back => isFrench ? 'Retour' : 'Go back';
  String get close => isFrench ? 'Fermer' : 'Close';
  String get view => isFrench ? 'Voir' : 'View';
  String get delete => isFrench ? 'Supprimer' : 'Delete';
  String get deleteAll => isFrench ? 'Tout supprimer' : 'Delete all';
  String get cancel => isFrench ? 'Annuler' : 'Cancel';
  String get nextStep => isFrench ? 'Étape suivante' : 'Next step';
  String get analyzeNow => isFrench ? 'Analyser maintenant' : 'Analyze now';
  String get exportPdf => isFrench ? 'Exporter en PDF' : 'Export to PDF';
  String get copy => isFrench ? 'Copier' : 'Copy';
  String get copied => isFrench ? 'Rapport copié.' : 'Report copied.';
  String get pdfSaved => isFrench ? 'PDF enregistré.' : 'PDF saved.';
  String get openDownload =>
      isFrench ? 'Téléchargement ouvert.' : 'Download opened.';
  String get noRows => isFrench ? 'Aucune ligne à afficher.' : 'No rows yet.';
  String get noFiles =>
      isFrench ? 'Aucun fichier pour le moment.' : 'No files yet.';
  String get noEligibleDatasets => isFrench
      ? 'Aucun jeu de données finalisé pour l’analyse.'
      : 'No finalized datasets are ready for analysis.';
  String get row => isFrench ? 'Ligne' : 'Row';
  String get sheet => isFrench ? 'Feuille' : 'Sheet';
  String get page => isFrench ? 'Page' : 'Page';
  String pageOf(int page, int totalPages) {
    return isFrench
        ? 'Page $page sur $totalPages'
        : 'Page $page of $totalPages';
  }

  String rowsShown(int first, int last, int total) {
    return isFrench
        ? 'Lignes $first-$last sur $total'
        : 'Rows $first-$last of $total';
  }

  String get previousPage => isFrench ? 'Page précédente' : 'Previous page';
  String get nextPage => isFrench ? 'Page suivante' : 'Next page';
  String get firstPage => isFrench ? 'Première page' : 'First page';
  String get lastPage => isFrench ? 'Dernière page' : 'Last page';
  String get number => isFrench ? 'Numéro' : 'Number';
  String get fileName => isFrench ? 'Nom du fichier' : 'File name';
  String get uploadDate => isFrench ? 'Date d’import' : 'Upload date';
  String get manage => isFrench ? 'Gérer' : 'Manage';
  String get status => isFrench ? 'Statut' : 'Status';
  String get project => isFrench ? 'Projet' : 'Project';
  String get rows => isFrench ? 'Lignes' : 'Rows';
  String get selectDataForAnalysis => isFrench
      ? 'Sélectionnez vos données pour MadAInsight'
      : 'Select your data for MadAInsight';
  String get instructionsTitle =>
      isFrench ? 'Instructions MadAInsight' : 'MadAInsight instructions';
  String get instructionsSubtitle => isFrench
      ? 'Donnez des consignes sur la façon dont MadAInsight doit interpréter les données'
      : 'Tell MadAInsight how to interpret the data';
  String get typeInstructions =>
      isFrench ? 'Tapez vos instructions ici' : 'Type your instructions here';
  String get reportTitle =>
      isFrench ? 'Rapport MadAInsight' : 'MadAInsight report';
  String get aiCaution => isFrench
      ? 'MadAInsight peut faire des erreurs, vérifiez attentivement'
      : 'MadAInsight can make mistakes, so check carefully';
  String get report => isFrench ? 'Rapport' : 'Report';
  String get deleteOneQuestion => isFrench
      ? 'Voulez-vous supprimer ces données ?'
      : 'Are you sure you want to delete the data?';
  String get deleteAllQuestion => isFrench
      ? 'Voulez-vous supprimer toutes vos données ?'
      : 'Are you sure you want to delete all data?';
  String get goBackWithoutExportQuestion => isFrench
      ? 'Voulez-vous revenir sans exporter ?'
      : 'Are you sure you want to go back without exporting?';
  String get changesMade => isFrench
      ? 'Les modifications ont été faites !'
      : 'Changes have been made!';
  String get noIssuesFound => isFrench
      ? 'Aucune erreur détectée. Le fichier peut être finalisé.'
      : 'No issues were found. The file can be finalized.';
  String get reviewDetectedErrors => isFrench
      ? 'MadAInsight a détecté des erreurs'
      : 'MadAInsight detected errors';
  String get reviewDetectedErrorsSubtitle => isFrench
      ? 'Vérifiez les corrections suggérées avant de modifier le tableau importé.'
      : 'Review the suggested corrections before modifying the imported table.';
  String get acceptAll => isFrench ? 'Tout accepter' : 'Accept all';
  String get rejectAll => isFrench ? 'Tout refuser' : 'Reject all';
  String get accept => isFrench ? 'Accepter' : 'Accept';
  String get reject => isFrench ? 'Refuser' : 'Reject';
  String get rejectAllPending =>
      isFrench ? 'Tout refuser en attente' : 'Reject all pending';
  String get reviewRequired =>
      isFrench ? 'Vérification requise' : 'Review required';
  String get cell => isFrench ? 'cellule' : 'cell';
  String get cells => isFrench ? 'cellules' : 'cells';
  String get type => isFrench ? 'type' : 'type';
  String get types => isFrench ? 'types' : 'types';
  String get suggestedAction =>
      isFrench ? 'Action suggérée' : 'Suggested action';
  String get markAbnormal =>
      isFrench ? 'Marquer comme anormal' : 'Mark as abnormal';
  String get flagOnly => isFrench ? 'Signalement uniquement' : 'Flag only';
  String get excludeRow => isFrench
      ? 'Exclure la ligne de l’export traité'
      : 'Exclude row from processed export';
  String get accepted => isFrench ? 'accepté' : 'accepted';
  String get rejected => isFrench ? 'refusé' : 'rejected';
  String get pending => isFrench ? 'en attente' : 'pending';
  String get chooseAtLeastOne => isFrench
      ? 'Sélectionnez au moins un jeu de données.'
      : 'Select at least one dataset.';
  String get enterInstructions => isFrench
      ? 'Saisissez des instructions pour MadAInsight.'
      : 'Enter MadAInsight instructions.';
  String get loading => isFrench ? 'Chargement...' : 'Loading...';
  String get retry => isFrench ? 'Réessayer' : 'Retry';
  String get sessionExpired => isFrench
      ? 'Votre session a expiré. Reconnectez-vous.'
      : 'Your session expired. Please sign in again.';
}

extension DataReviewStringsX on BuildContext {
  DataReviewStrings get drStrings {
    return DataReviewStrings(l10n.languageCode);
  }
}
