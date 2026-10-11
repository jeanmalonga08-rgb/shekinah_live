import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @aLaLuneBalconyAfter.
  ///
  /// In fr, this message translates to:
  /// **'Balcon — après travaux'**
  String get aLaLuneBalconyAfter;

  /// No description provided for @aLaLuneNoCommunique.
  ///
  /// In fr, this message translates to:
  /// **'Aucun communiqué disponible pour le moment.'**
  String get aLaLuneNoCommunique;

  /// No description provided for @aLaLuneOfficialCommunique.
  ///
  /// In fr, this message translates to:
  /// **'Communiqué officiel'**
  String get aLaLuneOfficialCommunique;

  /// No description provided for @aLaLuneRecentPredications.
  ///
  /// In fr, this message translates to:
  /// **'Prédications du mois'**
  String get aLaLuneRecentPredications;

  /// No description provided for @aLaLuneSanctuaryAfter.
  ///
  /// In fr, this message translates to:
  /// **'Sanctuaire — après travaux'**
  String get aLaLuneSanctuaryAfter;

  /// No description provided for @aLaLuneSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Annonces en vigueur et photos du Temple Moriah.'**
  String get aLaLuneSubtitle;

  /// No description provided for @aLaLuneTitle.
  ///
  /// In fr, this message translates to:
  /// **'A la lune'**
  String get aLaLuneTitle;

  /// No description provided for @aboutAppPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos de l\'application'**
  String get aboutAppPageTitle;

  /// No description provided for @aboutChurchFocusedP1.
  ///
  /// In fr, this message translates to:
  /// **'Les plateformes publiques, telles que YouTube et d\'autres, constituent de précieux moyens de diffusion. Toutefois, leur environnement propose également de nombreux contenus qui ne sont pas liés à la vie ou à la mission de l\'Église. Lorsqu\'un fidèle recherche une prédication ou un cantique, il peut ainsi être rapidement exposé à d\'autres vidéos, recommandations et contenus susceptibles de détourner son attention.'**
  String get aboutChurchFocusedP1;

  /// No description provided for @aboutChurchFocusedP2.
  ///
  /// In fr, this message translates to:
  /// **'Cette application a donc été pensée pour offrir un espace numérique davantage centré sur les ressources de l\'Église. Le membre y accède avec une intention précise et retrouve directement les contenus qui lui sont destinés, sans avoir à parcourir un environnement rempli de contenus externes.'**
  String get aboutChurchFocusedP2;

  /// No description provided for @aboutChurchFocusedP3.
  ///
  /// In fr, this message translates to:
  /// **'Cette approche est particulièrement importante pour les jeunes et les enfants, mais elle bénéficie également à tout fidèle qui souhaite consacrer son temps numérique aux enseignements, aux cultes et aux ressources de l\'Église.'**
  String get aboutChurchFocusedP3;

  /// No description provided for @aboutChurchFocusedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Un environnement centré sur la vie de l\'Église'**
  String get aboutChurchFocusedTitle;

  /// No description provided for @aboutContinuityP1.
  ///
  /// In fr, this message translates to:
  /// **'Cette application ne remplace pas le site internet ni les autres plateformes de communication de l\'Église. Elle vient compléter les moyens existants en proposant une expérience adaptée à l\'usage quotidien du smartphone.'**
  String get aboutContinuityP1;

  /// No description provided for @aboutContinuityP2.
  ///
  /// In fr, this message translates to:
  /// **'Elle permet ainsi de rapprocher davantage les membres de la vie de l\'Église, y compris ceux qui ne peuvent pas être présents physiquement à un culte en raison de leurs obligations professionnelles, de leur éloignement géographique ou de toute autre circonstance.'**
  String get aboutContinuityP2;

  /// No description provided for @aboutContinuityP3.
  ///
  /// In fr, this message translates to:
  /// **'À travers cette application, nous avons voulu mettre la technologie au service d\'un objectif essentiel : faciliter l\'accès à la Parole, aux enseignements et à la vie de l\'Église, partout et à tout moment.'**
  String get aboutContinuityP3;

  /// No description provided for @aboutContinuityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une continuité entre l\'Église et ses membres'**
  String get aboutContinuityTitle;

  /// No description provided for @aboutDeveloperServiceP1.
  ///
  /// In fr, this message translates to:
  /// **'Cette application est le fruit d\'une démarche de développement réalisée avec le souci de proposer un outil simple, accessible, moderne et utile aux membres.'**
  String get aboutDeveloperServiceP1;

  /// No description provided for @aboutDeveloperServiceP2.
  ///
  /// In fr, this message translates to:
  /// **'Notre volonté, en tant que développeur, n\'est pas simplement de créer une application de plus, mais de mettre nos compétences techniques au service d\'une vision : utiliser les outils numériques disponibles aujourd\'hui pour faciliter la communication de l\'Église et contribuer, à notre niveau, à la diffusion de la Parole de Dieu.'**
  String get aboutDeveloperServiceP2;

  /// No description provided for @aboutDeveloperServiceP3.
  ///
  /// In fr, this message translates to:
  /// **'Que cet outil puisse être utile aux frères et sœurs, faciliter leur accès aux ressources de l\'Église et contribuer à maintenir le lien avec la communauté, où qu\'ils se trouvent.'**
  String get aboutDeveloperServiceP3;

  /// No description provided for @aboutDeveloperServiceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une réalisation au service de l\'Église'**
  String get aboutDeveloperServiceTitle;

  /// No description provided for @aboutLibraryP1.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Tabernacle met depuis longtemps le Message à disposition des croyants grâce au programme Kosher sur ordinateur et aux clés USB distribuées dans l\'Église. Ces outils, déjà bien connus des fidèles, ont permis à de nombreux croyants et prédicateurs d\'étudier, de méditer et de prêcher la Parole dans des contextes variés.'**
  String get aboutLibraryP1;

  /// No description provided for @aboutLibraryP2.
  ///
  /// In fr, this message translates to:
  /// **'La Bibliothèque de l\'application prolonge cette même démarche sur le smartphone. Elle ne se limite pas à offrir aux croyants un accès pratique aux Pépites d\'or et aux publications : elle répond surtout aux besoins des prédicateurs, qui peuvent désormais emporter le Message avec eux partout — en déplacement, en visite, lors de réunions ou dans des lieux où un ordinateur ou une clé USB ne sont pas disponibles.'**
  String get aboutLibraryP2;

  /// No description provided for @aboutLibraryP3.
  ///
  /// In fr, this message translates to:
  /// **'Les messages peuvent être téléchargés pour une consultation hors connexion, avec un lecteur adapté à l\'étude de la Parole. Ce que Kosher et les supports USB offrent déjà sur le bureau ou à la chaire, la Bibliothèque le met désormais à portée de main, au service de l\'édification personnelle comme du ministère.'**
  String get aboutLibraryP3;

  /// No description provided for @aboutLibraryTitle.
  ///
  /// In fr, this message translates to:
  /// **'La Bibliothèque : porter le Message sur mobile'**
  String get aboutLibraryTitle;

  /// No description provided for @aboutWhyDeveloper.
  ///
  /// In fr, this message translates to:
  /// **'Développée par le frère Jean Malonga, croyant et membre de Shekinah Tabernacle, cette application a été conçue pour répondre aux besoins concrets des fidèles de notre assemblée.'**
  String get aboutWhyDeveloper;

  /// No description provided for @aboutWhyIntro.
  ///
  /// In fr, this message translates to:
  /// **'Cette application a été conçue avec une conviction simple : la technologie peut être mise au service de la diffusion de la Parole de Dieu et de la communion entre les membres de l\'Église.'**
  String get aboutWhyIntro;

  /// No description provided for @aboutWhyP1.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui, l\'Église dispose déjà de plusieurs moyens de communication, notamment son site internet et les plateformes numériques, qui permettent de diffuser les prédications, les cultes, les cantiques, les annonces et les différentes activités de l\'Église. Ces outils jouent un rôle important dans la communication et l\'édification des fidèles.'**
  String get aboutWhyP1;

  /// No description provided for @aboutWhyP2.
  ///
  /// In fr, this message translates to:
  /// **'Cependant, l\'accès à ces contenus n\'est pas toujours aussi simple qu\'il pourrait l\'être. Beaucoup de membres disposent d\'un smartphone, mais ne sont pas nécessairement à l\'aise avec la navigation sur Internet ou avec les différentes manipulations nécessaires pour retrouver une prédication, accéder au culte en direct ou revoir un enseignement.'**
  String get aboutWhyP2;

  /// No description provided for @aboutWhyP3.
  ///
  /// In fr, this message translates to:
  /// **'C\'est pour répondre à cette réalité que cette application mobile dédiée à l\'Église a été développée : offrir aux membres un accès simple, direct et organisé aux contenus et aux activités de l\'Église, depuis leur smartphone.'**
  String get aboutWhyP3;

  /// No description provided for @aboutWhyP4.
  ///
  /// In fr, this message translates to:
  /// **'L\'application permet notamment de retrouver facilement les cultes en direct, les prédications, les enseignements, les cantiques, les programmes, les annonces et les autres ressources spirituelles. Elle facilite également la réception d\'informations importantes grâce aux notifications, notamment pour rappeler les horaires des cultes, signaler le début d\'un direct ou informer de la disponibilité de nouveaux contenus.'**
  String get aboutWhyP4;

  /// No description provided for @aboutWhyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi cette application ?'**
  String get aboutWhyTitle;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get all;

  /// No description provided for @allItems.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get allItems;

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Tabernacle'**
  String get appName;

  /// No description provided for @appShortName.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah'**
  String get appShortName;

  /// No description provided for @archivesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune prédication trouvée.'**
  String get archivesEmpty;

  /// No description provided for @archivesEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre mot-clé ou revenez plus tard.'**
  String get archivesEmptyHint;

  /// No description provided for @archivesLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les prédications.'**
  String get archivesLoadError;

  /// No description provided for @archivesLoadMore.
  ///
  /// In fr, this message translates to:
  /// **'Charger plus'**
  String get archivesLoadMore;

  /// No description provided for @archivesSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une prédication...'**
  String get archivesSearchHint;

  /// No description provided for @archivesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prédications'**
  String get archivesTitle;

  /// No description provided for @assemblyAddress.
  ///
  /// In fr, this message translates to:
  /// **'18 Boulevard Lumumba, Matete — Kinshasa, RDC'**
  String get assemblyAddress;

  /// No description provided for @assemblyAddressLine1.
  ///
  /// In fr, this message translates to:
  /// **'18 Boulevard Lumumba, Matete'**
  String get assemblyAddressLine1;

  /// No description provided for @assemblyAddressLine2.
  ///
  /// In fr, this message translates to:
  /// **'B.P. 10.493 KINSHASA'**
  String get assemblyAddressLine2;

  /// No description provided for @assemblyAddressLine3.
  ///
  /// In fr, this message translates to:
  /// **'RÉPUBLIQUE DÉMOCRATIQUE DU CONGO'**
  String get assemblyAddressLine3;

  /// No description provided for @audio.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @audioPlaybackTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture audio'**
  String get audioPlaybackTitle;

  /// No description provided for @authAcceptTerms.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les conditions d\'utilisation et la politique de confidentialité de Shekinah Tabernacle.'**
  String get authAcceptTerms;

  /// No description provided for @authAcceptTermsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez accepter les conditions d\'utilisation.'**
  String get authAcceptTermsRequired;

  /// No description provided for @authAccountCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé. Bienvenue dans l\'espace fidèle.'**
  String get authAccountCreated;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? '**
  String get authAlreadyHaveAccount;

  /// No description provided for @authConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get authConfirmPassword;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez le mot de passe'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authContinueWithoutAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez continuer à suivre les cultes sans compte.'**
  String get authContinueWithoutAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccount;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccountTitle;

  /// No description provided for @authCreateAccountUnavailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'La création de compte en ligne n\'est pas encore disponible. Vous pouvez continuer à utiliser l\'application sans compte.'**
  String get authCreateAccountUnavailableMessage;

  /// No description provided for @authCreateAccountUnavailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription indisponible'**
  String get authCreateAccountUnavailableTitle;

  /// No description provided for @authCreateMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get authCreateMyAccount;

  /// No description provided for @authCredentialsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez renseigner l\'e-mail et le mot de passe.'**
  String get authCredentialsRequired;

  /// No description provided for @authDefaultDisplayName.
  ///
  /// In fr, this message translates to:
  /// **'Fidèle'**
  String get authDefaultDisplayName;

  /// No description provided for @authEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get authEmail;

  /// No description provided for @authEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'E-mail invalide'**
  String get authEmailInvalid;

  /// No description provided for @authEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'E-mail requis'**
  String get authEmailRequired;

  /// No description provided for @authFaithfulSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace fidèle'**
  String get authFaithfulSpace;

  /// No description provided for @authForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgotPassword;

  /// No description provided for @authForgotPasswordSoon.
  ///
  /// In fr, this message translates to:
  /// **'La réinitialisation du mot de passe sera bientôt disponible.'**
  String get authForgotPasswordSoon;

  /// No description provided for @authFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get authFullName;

  /// No description provided for @authFullNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet requis'**
  String get authFullNameRequired;

  /// No description provided for @authLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLogin;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour accéder à votre profil et à vos préférences.'**
  String get authLoginSubtitle;

  /// No description provided for @authLoginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie. Bienvenue.'**
  String get authLoginSuccess;

  /// No description provided for @authNameMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 3 caractères'**
  String get authNameMinLength;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caractères'**
  String get authPasswordMinLength;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get authPasswordMismatch;

  /// No description provided for @authPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get authPasswordRequired;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Numéro invalide'**
  String get authPhoneInvalid;

  /// No description provided for @authPhoneOptional.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone (optionnel)'**
  String get authPhoneOptional;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez l\'espace fidèle pour synchroniser vos préférences et votre activité.'**
  String get authRegisterSubtitle;

  /// No description provided for @branhamAngelVisitP1.
  ///
  /// In fr, this message translates to:
  /// **'Les visions ont continué. Ses collègues dans le ministère lui ont dit que ses visions ne venaient pas de Dieu. Cela l\'a troublé profondément. Le fardeau est devenu trop lourd à porter ; il est alors parti dans un lieu sauvage pour chercher la volonté de Dieu. C\'est là, dans une vieille cabane de trappeur, que l\'Ange du Seigneur lui a donné sa commission : « Si tu amènes les gens à te croire, et que tu es sincère quand tu pries, rien ne résistera à tes prières, pas même le cancer. »'**
  String get branhamAngelVisitP1;

  /// No description provided for @branhamAngelVisitP2.
  ///
  /// In fr, this message translates to:
  /// **'Tous les doutes avaient disparu. Maintenant, il avait une commission, et il est allé de l\'avant avec assurance.'**
  String get branhamAngelVisitP2;

  /// No description provided for @branhamBaptistCaption.
  ///
  /// In fr, this message translates to:
  /// **'Comme Jean-Baptiste, le prophète a été confirmé dans les eaux du baptême.'**
  String get branhamBaptistCaption;

  /// No description provided for @branhamBaptistQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Comme Jean fut envoyé avec un Message pour la première venue, ceci est également le second Message pour la seconde venue. »'**
  String get branhamBaptistQuote;

  /// No description provided for @branhamBeginningP1.
  ///
  /// In fr, this message translates to:
  /// **'L\'aube venait tout juste de percer l\'obscurité de ce ciel frais d\'avril. L\'unique fenêtre en bois s\'ouvrit pour laisser entrer la lumière matinale dans la minuscule cabane d\'une seule pièce. À l\'intérieur, le jeune Charles Branham mit ses mains dans ses salopettes flambant neuves et regarda sa femme âgée de 15 ans. « Nous l\'appellerons William », dit le père.'**
  String get branhamBeginningP1;

  /// No description provided for @branhamBeginningP2.
  ///
  /// In fr, this message translates to:
  /// **'Une Lumière surnaturelle entra par la fenêtre. La Lumière se déplaça dans la pièce et s\'arrêta au-dessus du lit où se trouvait le nouveau-né. C\'est cette même Lumière qui avait fait sortir les enfants hébreux d\'Égypte. C\'est cette même Lumière qui avait rencontré Paul sur le chemin de Damas. Et c\'est Elle qui allait maintenant conduire cet enfant destiné à appeler l\'Épouse de Christ à sortir du monde. Cette Lumière n\'était nul autre que l\'Ange du Seigneur, la Colonne de Feu : Elle était de nouveau apparue à l\'homme.'**
  String get branhamBeginningP2;

  /// No description provided for @branhamBeginningP3.
  ///
  /// In fr, this message translates to:
  /// **'« Et là, dans cette petite cabane en rondins, ce matin du 6 avril, la sage-femme a ouvert la fenêtre pour laisser pénétrer la lumière, afin que maman et papa puissent voir comment j\'étais. C\'est alors qu\'une Lumière de la grandeur d\'un oreiller est entrée par la fenêtre en tourbillonnant. Elle a décrit un cercle autour de l\'endroit où je me trouvais et Elle est descendue sur le lit. Plusieurs montagnards se tenaient là. Ils pleuraient. »'**
  String get branhamBeginningP3;

  /// No description provided for @branhamBeginningP4.
  ///
  /// In fr, this message translates to:
  /// **'La modeste demeure se trouvait dans les collines du sud du Kentucky, près de la petite ville de Burkesville. C\'était le 6 avril 1909. Le bébé était le premier des dix enfants qu\'ont eus Charles et Ella Branham.'**
  String get branhamBeginningP4;

  /// No description provided for @branhamBeginningQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Quand je suis né dans une petite cabane là-bas au Kentucky, l\'Ange du Seigneur est entré par la fenêtre et s\'est tenu là. C\'était une Colonne de Feu. »'**
  String get branhamBeginningQuote;

  /// No description provided for @branhamClosingQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Un grand prophète a paru parmi nous et Dieu a visité son peuple. »'**
  String get branhamClosingQuote;

  /// No description provided for @branhamClosingRef.
  ///
  /// In fr, this message translates to:
  /// **'Luc 7:16'**
  String get branhamClosingRef;

  /// No description provided for @branhamDoctrineP1.
  ///
  /// In fr, this message translates to:
  /// **'Ses enseignements et doctrines strictement basés sur les Saintes Ecritures, la Bible, qu\'il reconnaît comme la seule autorité en matière de foi, ont montré que c\'est le Seigneur Jésus-Christ, la Divinité suprême, qui est le seul vrai Dieu fait chair, et que Son Nom, Jésus-Christ, est le seul Vrai Nom parmi les hommes pour le salut ; que seule la foi en Lui amène à la Vie Eternelle, et que le seul baptême biblique est celui par immersion dans le Nom du Seigneur Jésus-Christ.'**
  String get branhamDoctrineP1;

  /// No description provided for @branhamFactBirth.
  ///
  /// In fr, this message translates to:
  /// **'Né le 6 avril 1909 à Burkesville, Kentucky (États-Unis)'**
  String get branhamFactBirth;

  /// No description provided for @branhamFactMalachi.
  ///
  /// In fr, this message translates to:
  /// **'Prophète de Malachie 4:5-6 — préparer l\'Épouse à l\'Enlèvement'**
  String get branhamFactMalachi;

  /// No description provided for @branhamFactMinistry.
  ///
  /// In fr, this message translates to:
  /// **'Campagnes de guérison, visions et miracles confirmés par des milliers de témoins'**
  String get branhamFactMinistry;

  /// No description provided for @branhamFactPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Photo de la Colonne de Feu authentifiée par George J. Lacy (expert FBI), 1950'**
  String get branhamFactPhoto;

  /// No description provided for @branhamHeaderSummary.
  ///
  /// In fr, this message translates to:
  /// **'Prophète confirmé par Dieu pour notre génération, porteur du Message du temps de la fin et des signes surnaturels.'**
  String get branhamHeaderSummary;

  /// No description provided for @branhamHealingRevivalP1.
  ///
  /// In fr, this message translates to:
  /// **'Des centaines de milliers de personnes ont assisté aux campagnes Branham. Des milliers ont été guéris au Nom du Seigneur Jésus-Christ. D\'autres évangélistes, comme Oral Roberts, T. L. Osborn et A. A. Allen, ont bientôt suivi Frère Branham et ont commencé leurs propres campagnes de réveil de guérison.'**
  String get branhamHealingRevivalP1;

  /// No description provided for @branhamHoustonQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Je ne peux guérir personne. Voici ce que je peux dire. Quand je suis né dans l\'État du Kentucky, une Lumière est entrée dans la pièce de ce petit abri où je me trouvais. Depuis ce temps-là, Elle m\'a accompagné. C\'est un Ange de Dieu. Tout au long de ma vie, Il m\'a dit des choses qui sont arrivées, et je les ai dites exactement comme Il me les a dites. Et je mets au défi n\'importe qui de m\'indiquer une seule déclaration faite au Nom du Seigneur qui ne se soit pas accomplie exactement comme annoncé. »'**
  String get branhamHoustonQuote;

  /// No description provided for @branhamIntroP1.
  ///
  /// In fr, this message translates to:
  /// **'En ce temps de la fin, Dieu a visité cette dernière génération de manière extraordinaire par le ministère prophétique de son serviteur, William Marrion Branham. Né le 6 avril 1909 à Burkesville, Kentucky, USA, sa vie particulière a été marquée par des phénomènes surnaturels tels que : visions et prophéties (qui se sont toujours accomplies), apparition des anges, guérisons miracles, résurrection des morts, etc. William Marrion Branham est réellement un prophète envoyé par le Dieu tout puissant avec des signes et des prodiges pour préparer le peuple à l\'Enlèvement avant la venue du grand et terrible jour du jugement de Dieu, comme annoncé et promis.'**
  String get branhamIntroP1;

  /// No description provided for @branhamPillarP1.
  ///
  /// In fr, this message translates to:
  /// **'Frère Branham décrit souvent une Colonne de Feu qui a confirmé son ministère. Elle était présente à sa naissance, elle a été vue par des milliers de personnes sur la rive de la rivière Ohio, et elle semblait le suivre partout où il allait.'**
  String get branhamPillarP1;

  /// No description provided for @branhamPillarP2.
  ///
  /// In fr, this message translates to:
  /// **'C\'est en 1950 que le Seigneur a donné aux croyants, et aux incroyants, la preuve infaillible que cette Colonne de Feu accompagnait le prophète. La soirée au stade Sam Houston fut entourée de controverse : un débat sur la guérison Divine opposa le révérend F. F. Bosworth à un pasteur sceptique.'**
  String get branhamPillarP2;

  /// No description provided for @branhamPillarP3.
  ///
  /// In fr, this message translates to:
  /// **'Frère Bosworth démontra l\'authenticité de la guérison par des preuves bibliques, puis demanda à tous ceux qui avaient été guéris de se lever. Des milliers de personnes se levèrent. Le sceptique lança ce défi : « Que ce guérisseur Divin s\'avance. Qu\'il se produise. »'**
  String get branhamPillarP3;

  /// No description provided for @branhamPillarP4.
  ///
  /// In fr, this message translates to:
  /// **'Frère Bosworth invita Frère Branham à venir sur l\'estrade. Le prophète, rempli du Saint-Esprit, donna la réponse suivante :'**
  String get branhamPillarP4;

  /// No description provided for @branhamPillarP5.
  ///
  /// In fr, this message translates to:
  /// **'Après ces paroles, le Saint-Esprit est descendu sur l\'estrade ; le photographe prit une photo. Sur cette dernière photographie se trouvait la Colonne de Feu sous une forme visible, suspendue au-dessus de la tête du prophète de Dieu, William Marrion Branham. Frère Branham déclara : « Dieu rendra témoignage. Je n\'ajouterai rien. »'**
  String get branhamPillarP5;

  /// No description provided for @branhamPillarP6.
  ///
  /// In fr, this message translates to:
  /// **'La photo fut transmise à George J. Lacy, examinateur professionnel en documents contestés pour le FBI américain, qui confirma l\'authenticité de la photo en tant qu\'expert.'**
  String get branhamPillarP6;

  /// No description provided for @branhamPillarWitnessQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Les enfants d\'Israël furent témoins de la Colonne de Feu qui conduisait Moïse, et aujourd\'hui, les gens ont été témoins de cette même Colonne de Feu qui a conduit un autre prophète. »'**
  String get branhamPillarWitnessQuote;

  /// No description provided for @branhamScriptureHoseaQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Par un prophète, l\'Eternel fit monter Israël hors d\'Egypte, et par un prophète Israël fut gardé »'**
  String get branhamScriptureHoseaQuote;

  /// No description provided for @branhamScriptureHoseaRef.
  ///
  /// In fr, this message translates to:
  /// **'Osée 12:13'**
  String get branhamScriptureHoseaRef;

  /// No description provided for @branhamScriptureMalachiQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Voici, je vous enverrai Elie, le prophète, avant que le jour de l\'Eternel arrive, ce jour grand et redoutable. Il ramènera le cœur… des enfants à leurs pères. De peur que je ne vienne frapper le pays d\'interdit. »'**
  String get branhamScriptureMalachiQuote;

  /// No description provided for @branhamScriptureMalachiRef.
  ///
  /// In fr, this message translates to:
  /// **'Malachie 4:5-6'**
  String get branhamScriptureMalachiRef;

  /// No description provided for @branhamSectionAngelVisit.
  ///
  /// In fr, this message translates to:
  /// **'La Visitation d\'un Ange'**
  String get branhamSectionAngelVisit;

  /// No description provided for @branhamSectionBeginning.
  ///
  /// In fr, this message translates to:
  /// **'Le début'**
  String get branhamSectionBeginning;

  /// No description provided for @branhamSectionDoctrine.
  ///
  /// In fr, this message translates to:
  /// **'Ses enseignements'**
  String get branhamSectionDoctrine;

  /// No description provided for @branhamSectionIntro.
  ///
  /// In fr, this message translates to:
  /// **'Sa vie et son ministère'**
  String get branhamSectionIntro;

  /// No description provided for @branhamSectionPillarOfFire.
  ///
  /// In fr, this message translates to:
  /// **'La Colonne de Feu'**
  String get branhamSectionPillarOfFire;

  /// No description provided for @branhamSectionVisions.
  ///
  /// In fr, this message translates to:
  /// **'Visites surnaturelles'**
  String get branhamSectionVisions;

  /// No description provided for @branhamSectionYouth.
  ///
  /// In fr, this message translates to:
  /// **'Les jeunes années'**
  String get branhamSectionYouth;

  /// No description provided for @branhamSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Le Prophète de Malachie 4:5-6'**
  String get branhamSubtitle;

  /// No description provided for @branhamTitle.
  ///
  /// In fr, this message translates to:
  /// **'William Marrion Branham'**
  String get branhamTitle;

  /// No description provided for @branhamVisionsP1.
  ///
  /// In fr, this message translates to:
  /// **'Il était enfant lorsque l\'Ange lui parla pour la première fois, lui disant qu\'il allait habiter et passer sa vie près d\'une ville du nom de New Albany. Deux ans plus tard, sa famille alla s\'installer à Jeffersonville, dans l\'Indiana, à quelques kilomètres seulement de New Albany. Quelques années plus tard, l\'Ange parla de nouveau au jeune prophète. C\'était une journée tranquille de septembre : le garçon s\'assit à l\'ombre d\'un grand peuplier. Tout à coup, une Voix parla : « Ne bois pas, ne fume pas et ne souille ton corps d\'aucune façon, tu auras une œuvre à accomplir quand tu seras plus âgé. » Effrayé, le garçon de sept ans laissa tomber ses seaux et courut vers sa mère.'**
  String get branhamVisionsP1;

  /// No description provided for @branhamVisionsP2.
  ///
  /// In fr, this message translates to:
  /// **'Le Seigneur lui donnait des visions du futur. Et comme pour les prophètes qui l\'ont précédé, les visions n\'ont jamais failli.'**
  String get branhamVisionsP2;

  /// No description provided for @branhamYouthIntro.
  ///
  /// In fr, this message translates to:
  /// **'Durant toute sa vie, Frère Branham aspira à être dans des endroits sauvages. À 18 ans, il quitta l\'Indiana pour les montagnes accidentées de l\'Ouest. Son séjour en Arizona fut cependant de courte durée, car il fut forcé de rentrer.'**
  String get branhamYouthIntro;

  /// No description provided for @branhamYouthQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Un jour j\'ai décidé que j\'avais trouvé un moyen de me débarrasser de cet appel : j\'irais dans l\'Ouest travailler dans un ranch. Mon ami, Dieu est tout aussi grand là-bas que n\'importe où. Puissiez-vous tirer profit de mon expérience. Quand Il vous appelle, répondez-Lui. » Il partit en Arizona fuir le Dieu d\'Amour, mais la vie de ranch ne comblera pas son âme. Après la mort de son frère Édouard, Dieu traita de nouveau avec lui. Cher lecteur, quand Il appelle, répondez-Lui.'**
  String get branhamYouthQuote;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @cantiqueCategoryEnsemble.
  ///
  /// In fr, this message translates to:
  /// **'Chants d\'ensemble'**
  String get cantiqueCategoryEnsemble;

  /// No description provided for @cantiqueCategoryIndividual.
  ///
  /// In fr, this message translates to:
  /// **'Chants individuels'**
  String get cantiqueCategoryIndividual;

  /// No description provided for @cantiqueCategoryInstrumental.
  ///
  /// In fr, this message translates to:
  /// **'Instrumentale'**
  String get cantiqueCategoryInstrumental;

  /// No description provided for @cantiqueCategoryShieldOfDavid.
  ///
  /// In fr, this message translates to:
  /// **'Chants Bouclier De David'**
  String get cantiqueCategoryShieldOfDavid;

  /// No description provided for @cantiqueCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun cantique} =1{1 cantique} other{{count} cantiques}}'**
  String cantiqueCount(int count);

  /// No description provided for @cantiqueMediaAudio.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get cantiqueMediaAudio;

  /// No description provided for @cantiqueMediaAudioVideo.
  ///
  /// In fr, this message translates to:
  /// **'Audio · Vidéo'**
  String get cantiqueMediaAudioVideo;

  /// No description provided for @cantiqueMediaGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Média'**
  String get cantiqueMediaGeneric;

  /// No description provided for @cantiqueMediaVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get cantiqueMediaVideo;

  /// No description provided for @cantiqueUntitled.
  ///
  /// In fr, this message translates to:
  /// **'Cantique'**
  String get cantiqueUntitled;

  /// No description provided for @cantiquesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun cantique trouvé.'**
  String get cantiquesEmpty;

  /// No description provided for @cantiquesEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre mot-clé ou revenez plus tard.'**
  String get cantiquesEmptyHint;

  /// No description provided for @cantiquesLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les cantiques.'**
  String get cantiquesLoadError;

  /// No description provided for @cantiquesNumber.
  ///
  /// In fr, this message translates to:
  /// **'N° {number}'**
  String cantiquesNumber(int number);

  /// No description provided for @cantiquesSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un cantique...'**
  String get cantiquesSearchHint;

  /// No description provided for @cantiquesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cantiques'**
  String get cantiquesTitle;

  /// No description provided for @ceremoniesBaptism.
  ///
  /// In fr, this message translates to:
  /// **'Baptême'**
  String get ceremoniesBaptism;

  /// No description provided for @ceremoniesDedication.
  ///
  /// In fr, this message translates to:
  /// **'Dédicace'**
  String get ceremoniesDedication;

  /// No description provided for @ceremoniesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cérémonies'**
  String get ceremoniesTitle;

  /// No description provided for @ceremoniesWedding.
  ///
  /// In fr, this message translates to:
  /// **'Mariage'**
  String get ceremoniesWedding;

  /// No description provided for @ceremonyCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune cérémonie} =1{1 cérémonie} other{{count} cérémonies}}'**
  String ceremonyCount(int count);

  /// No description provided for @churchTagline.
  ///
  /// In fr, this message translates to:
  /// **'Interdénominationnelle'**
  String get churchTagline;

  /// No description provided for @communiqueFallbackMessage.
  ///
  /// In fr, this message translates to:
  /// **'Consultez le site Shekinah Tabernacle pour les communiqués en vigueur.'**
  String get communiqueFallbackMessage;

  /// No description provided for @communiqueFallbackReadMore.
  ///
  /// In fr, this message translates to:
  /// **'Lire plus'**
  String get communiqueFallbackReadMore;

  /// No description provided for @communiqueFallbackTitle.
  ///
  /// In fr, this message translates to:
  /// **'Communiqué Officiel'**
  String get communiqueFallbackTitle;

  /// No description provided for @contactAboutApp.
  ///
  /// In fr, this message translates to:
  /// **'Développée par le frère Jean Malonga pour offrir un accès simple aux sermons, cantiques et communiqués de l\'assemblée.'**
  String get contactAboutApp;

  /// No description provided for @contactAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get contactAddress;

  /// No description provided for @contactAssembly.
  ///
  /// In fr, this message translates to:
  /// **'Assemblée'**
  String get contactAssembly;

  /// No description provided for @contactCopyright.
  ///
  /// In fr, this message translates to:
  /// **'© 2026 Shekinah Tabernacle · v{version}'**
  String contactCopyright(String version);

  /// No description provided for @contactEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get contactEmail;

  /// No description provided for @contactMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get contactMap;

  /// No description provided for @contactPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get contactPhone;

  /// No description provided for @contactSendEmail.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un e-mail'**
  String get contactSendEmail;

  /// No description provided for @contactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contactTitle;

  /// No description provided for @contactWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsApp;

  /// No description provided for @countdownChronoWithDays.
  ///
  /// In fr, this message translates to:
  /// **'{days}j {time}'**
  String countdownChronoWithDays(int days, String time);

  /// No description provided for @countdownMinutesOnly.
  ///
  /// In fr, this message translates to:
  /// **'{minutes}min {seconds}s'**
  String countdownMinutesOnly(String minutes, String seconds);

  /// No description provided for @countdownNow.
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get countdownNow;

  /// No description provided for @countdownWithDays.
  ///
  /// In fr, this message translates to:
  /// **'{days}j {hours}h {minutes}min'**
  String countdownWithDays(int days, String hours, String minutes);

  /// No description provided for @countdownWithHours.
  ///
  /// In fr, this message translates to:
  /// **'{hours}h {minutes}min {seconds}s'**
  String countdownWithHours(String hours, String minutes, String seconds);

  /// No description provided for @cultesJoinLive.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre le live'**
  String get cultesJoinLive;

  /// No description provided for @cultesService.
  ///
  /// In fr, this message translates to:
  /// **'Culte — {day}'**
  String cultesService(String day);

  /// No description provided for @cultesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Programme des cultes'**
  String get cultesTitle;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @deleteOfflineConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Retirer « {title} » de la mémoire de l\'appareil ?'**
  String deleteOfflineConfirm(String title);

  /// No description provided for @deleteQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ?'**
  String get deleteQuestion;

  /// No description provided for @downloadAlreadySaved.
  ///
  /// In fr, this message translates to:
  /// **'Déjà téléchargé · disponible hors ligne dans l\'onglet Hors ligne.'**
  String get downloadAlreadySaved;

  /// No description provided for @downloadAudioUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Audio indisponible.'**
  String get downloadAudioUnavailable;

  /// No description provided for @downloadAvailableOffline.
  ///
  /// In fr, this message translates to:
  /// **'Disponible hors ligne'**
  String get downloadAvailableOffline;

  /// No description provided for @downloadChooseFormat.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le format à télécharger'**
  String get downloadChooseFormat;

  /// No description provided for @downloadChooseQuality.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une qualité vidéo'**
  String get downloadChooseQuality;

  /// No description provided for @downloadConvertToAudio.
  ///
  /// In fr, this message translates to:
  /// **'Convertir en audio'**
  String get downloadConvertToAudio;

  /// No description provided for @downloadConvertToAudioHint.
  ///
  /// In fr, this message translates to:
  /// **'Convertit sur le serveur et enregistre l\'audio hors-ligne'**
  String get downloadConvertToAudioHint;

  /// No description provided for @audioConversionChooseQuality.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une qualité audio'**
  String get audioConversionChooseQuality;

  /// No description provided for @audioConversionProfileEconomy.
  ///
  /// In fr, this message translates to:
  /// **'Économique — Opus 48 kb/s'**
  String get audioConversionProfileEconomy;

  /// No description provided for @audioConversionProfileEconomyHint.
  ///
  /// In fr, this message translates to:
  /// **'Fichier le plus léger, idéal en data mobile'**
  String get audioConversionProfileEconomyHint;

  /// No description provided for @audioConversionProfileStandard.
  ///
  /// In fr, this message translates to:
  /// **'Standard — Opus 64 kb/s'**
  String get audioConversionProfileStandard;

  /// No description provided for @audioConversionProfileStandardHint.
  ///
  /// In fr, this message translates to:
  /// **'Bon équilibre qualité / taille (recommandé)'**
  String get audioConversionProfileStandardHint;

  /// No description provided for @audioConversionProfileCompatible.
  ///
  /// In fr, this message translates to:
  /// **'Compatible — AAC 96 kb/s'**
  String get audioConversionProfileCompatible;

  /// No description provided for @audioConversionProfileCompatibleHint.
  ///
  /// In fr, this message translates to:
  /// **'Meilleure compatibilité lecteurs'**
  String get audioConversionProfileCompatibleHint;

  /// No description provided for @audioConversionInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Conversion en cours…'**
  String get audioConversionInProgress;

  /// No description provided for @audioConversionStarting.
  ///
  /// In fr, this message translates to:
  /// **'Démarrage de la conversion…'**
  String get audioConversionStarting;

  /// No description provided for @audioConversionProgressPercent.
  ///
  /// In fr, this message translates to:
  /// **'{percent} %'**
  String audioConversionProgressPercent(int percent);

  /// No description provided for @audioConversionFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la conversion audio'**
  String get audioConversionFailed;

  /// No description provided for @audioConversionUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Conversion audio serveur indisponible.'**
  String get audioConversionUnavailable;

  /// No description provided for @audioConversionSourceUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'La source vidéo n\'est pas accessible.'**
  String get audioConversionSourceUnavailable;

  /// No description provided for @audioConversionUnsupportedSource.
  ///
  /// In fr, this message translates to:
  /// **'La source vidéo n\'est pas compatible avec la conversion.'**
  String get audioConversionUnsupportedSource;

  /// No description provided for @audioConversionTimeout.
  ///
  /// In fr, this message translates to:
  /// **'La conversion a dépassé le délai imparti.'**
  String get audioConversionTimeout;

  /// No description provided for @audioConversionAlreadyRunning.
  ///
  /// In fr, this message translates to:
  /// **'Une conversion est déjà en cours pour ce média.'**
  String get audioConversionAlreadyRunning;

  /// No description provided for @audioConversionReady.
  ///
  /// In fr, this message translates to:
  /// **'Votre audio est prêt'**
  String get audioConversionReady;

  /// No description provided for @audioConversionManagerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conversions audio'**
  String get audioConversionManagerTitle;

  /// No description provided for @audioConversionManagerEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversion en cours.'**
  String get audioConversionManagerEmpty;

  /// No description provided for @audioConversionManagerSummary.
  ///
  /// In fr, this message translates to:
  /// **'{active} en cours · {total} au total'**
  String audioConversionManagerSummary(int active, int total);

  /// No description provided for @audioConversionManagerErrors.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 échec} other{{count} échecs}}'**
  String audioConversionManagerErrors(int count);

  /// No description provided for @audioConversionAddedToQueue.
  ///
  /// In fr, this message translates to:
  /// **'Conversion ajoutée — l\'app reste utilisable.'**
  String get audioConversionAddedToQueue;

  /// No description provided for @downloadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec du téléchargement'**
  String get downloadFailed;

  /// No description provided for @downloadInApp.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger dans l\'app'**
  String get downloadInApp;

  /// No description provided for @downloadInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Un téléchargement est déjà en cours.'**
  String get downloadInProgress;

  /// No description provided for @downloadQueued.
  ///
  /// In fr, this message translates to:
  /// **'En file d\'attente'**
  String get downloadQueued;

  /// No description provided for @downloadAddedToQueue.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté à la file de téléchargement.'**
  String get downloadAddedToQueue;

  /// No description provided for @downloadAlreadyInQueue.
  ///
  /// In fr, this message translates to:
  /// **'Ce téléchargement est déjà dans la file.'**
  String get downloadAlreadyInQueue;

  /// No description provided for @downloadResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get downloadResume;

  /// No description provided for @downloadResumeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout reprendre'**
  String get downloadResumeAll;

  /// No description provided for @downloadResumeStarted.
  ///
  /// In fr, this message translates to:
  /// **'Reprise du téléchargement…'**
  String get downloadResumeStarted;

  /// No description provided for @downloadPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get downloadPause;

  /// No description provided for @downloadPaused.
  ///
  /// In fr, this message translates to:
  /// **'En pause'**
  String get downloadPaused;

  /// No description provided for @downloadSpeedPerSec.
  ///
  /// In fr, this message translates to:
  /// **'{size}/s'**
  String downloadSpeedPerSec(String size);

  /// No description provided for @downloadManagerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargements'**
  String get downloadManagerTitle;

  /// No description provided for @downloadManagerEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun téléchargement en cours.'**
  String get downloadManagerEmpty;

  /// No description provided for @downloadManagerSummary.
  ///
  /// In fr, this message translates to:
  /// **'{active} en cours · {total} au total'**
  String downloadManagerSummary(int active, int total);

  /// No description provided for @downloadManagerErrors.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 échec — touchez pour reprendre} other{{count} échecs — touchez pour reprendre}}'**
  String downloadManagerErrors(int count);

  /// No description provided for @libraryDownloadAllQueued.
  ///
  /// In fr, this message translates to:
  /// **'{queued} ajouté(s) à la file · {skipped} déjà enregistré(s)'**
  String libraryDownloadAllQueued(int queued, int skipped);

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @downloadOfflineSaved.
  ///
  /// In fr, this message translates to:
  /// **'Déjà enregistré — disponible dans l\'onglet Hors ligne.'**
  String get downloadOfflineSaved;

  /// No description provided for @downloadOfflineTabHint.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez l\'audio ou la vidéo pour l\'écouter sans connexion.'**
  String get downloadOfflineTabHint;

  /// No description provided for @downloadProgress.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement… {percent} %'**
  String downloadProgress(int percent);

  /// No description provided for @downloadProgressActive.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement en cours…'**
  String get downloadProgressActive;

  /// No description provided for @downloadQualitiesUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Qualités indisponibles.'**
  String get downloadQualitiesUnavailable;

  /// No description provided for @downloadRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get downloadRetry;

  /// No description provided for @downloadVideoFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de télécharger cette vidéo.'**
  String get downloadVideoFailed;

  /// No description provided for @downloadVideoUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo indisponible.'**
  String get downloadVideoUnavailable;

  /// No description provided for @ecamoFactBiblePriority.
  ///
  /// In fr, this message translates to:
  /// **'L\'enseignement biblique est la priorité absolue'**
  String get ecamoFactBiblePriority;

  /// No description provided for @ecamoFactEnrolled.
  ///
  /// In fr, this message translates to:
  /// **'Plus d\'un millier d\'enfants inscrits'**
  String get ecamoFactEnrolled;

  /// No description provided for @ecamoFactNonProfit.
  ///
  /// In fr, this message translates to:
  /// **'Initiative de la Fondation Shekinah, sans visée mercantile'**
  String get ecamoFactNonProfit;

  /// No description provided for @ecamoFactSpiritualShelter.
  ///
  /// In fr, this message translates to:
  /// **'Abri spirituel pour les enfants de Shekinah Tabernacle'**
  String get ecamoFactSpiritualShelter;

  /// No description provided for @ecamoFactVision.
  ///
  /// In fr, this message translates to:
  /// **'Vision : une société modèle fondée sur la Parole de Dieu'**
  String get ecamoFactVision;

  /// No description provided for @ecamoHeaderSummary.
  ///
  /// In fr, this message translates to:
  /// **'Une école biblique au sein de la Fondation Shekinah, bastion d\'une éducation où les valeurs spirituelles, morales et sociales les plus fondamentales sont dispensées et préservées.'**
  String get ecamoHeaderSummary;

  /// No description provided for @ecamoLabel.
  ///
  /// In fr, this message translates to:
  /// **'ECAMO'**
  String get ecamoLabel;

  /// No description provided for @ecamoScriptureQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Mon peuple, écoute mes instructions ! Prêtez l\'oreille aux paroles de ma bouche !... »'**
  String get ecamoScriptureQuote;

  /// No description provided for @ecamoScriptureRef.
  ///
  /// In fr, this message translates to:
  /// **'Psaume 78:1-8'**
  String get ecamoScriptureRef;

  /// No description provided for @ecamoSectionInspiration.
  ///
  /// In fr, this message translates to:
  /// **'Notre inspiration'**
  String get ecamoSectionInspiration;

  /// No description provided for @ecamoSectionInspirationP1.
  ///
  /// In fr, this message translates to:
  /// **'Dans l\'Ancien Testament, Jokébed et Amram construisirent une « arche » pour protéger Moïse contre le massacre ordonné par Pharaon. Dans le Nouveau Testament, Joseph et Marie, divinement avertis, fuirent en Égypte pour protéger l\'Enfant Jésus contre le génocide planifié par Hérode.'**
  String get ecamoSectionInspirationP1;

  /// No description provided for @ecamoSectionInspirationP2.
  ///
  /// In fr, this message translates to:
  /// **'Les pères fondateurs des États-Unis, conscients de l\'impact de la Parole de Dieu dans le façonnement de l\'être humain, accordèrent une très grande importance à l\'enseignement de la Bible dans les écoles. C\'est ce qui fit de l\'Amérique une grande nation, productrice d\'éminentes personnalités à l\'instar d\'Abraham Lincoln.'**
  String get ecamoSectionInspirationP2;

  /// No description provided for @ecamoSectionSchool.
  ///
  /// In fr, this message translates to:
  /// **'L\'École Chrétienne Arche de Moïse'**
  String get ecamoSectionSchool;

  /// No description provided for @ecamoSectionSchoolP1.
  ///
  /// In fr, this message translates to:
  /// **'Face à ce fléau qui tend à ravager la jeunesse de Shekinah Tabernacle, nous avons été conduits à fonder l\'École Chrétienne Arche de Moïse (ECAMO) au sein de la Fondation Shekinah, pour servir d\'abri à nos enfants. L\'objectif premier de cette école biblique est de garder nos enfants loin de l\'influence polluée du monde, l\'apprentissage de la Bible devant primer.'**
  String get ecamoSectionSchoolP1;

  /// No description provided for @ecamoSectionSchoolP2.
  ///
  /// In fr, this message translates to:
  /// **'Nous avons compris que la Parole doit prendre l\'enfant en charge alors que son cerveau est encore vierge. De la sorte, à la fin de ses études, il sera un homme tout fait. Magistrat ou avocat, il aura conscience que la corruption va à l\'encontre de la Bible ; médecin, il aura conscience que l\'avortement volontaire est un meurtre ; pour le gestionnaire public, le vol est un péché.'**
  String get ecamoSectionSchoolP2;

  /// No description provided for @ecamoSectionSchoolP3.
  ///
  /// In fr, this message translates to:
  /// **'Ce ne sont donc que de tels bons citoyens qui formeront une société où il fera bon vivre.'**
  String get ecamoSectionSchoolP3;

  /// No description provided for @ecamoSectionYouthChallenge.
  ///
  /// In fr, this message translates to:
  /// **'Le défi de notre jeunesse'**
  String get ecamoSectionYouthChallenge;

  /// No description provided for @ecamoSectionYouthChallengeP1.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui, notre jeunesse est devenue une proie pour le diable qui la déprave et la manipule à son gré au travers de la musique, des films obscènes, de la télévision, de l\'internet et surtout de la déconfiture du système scolaire due au rejet en bloc du véritable enseignement biblique.'**
  String get ecamoSectionYouthChallengeP1;

  /// No description provided for @ecamoSectionYouthChallengeP2.
  ///
  /// In fr, this message translates to:
  /// **'La délinquance juvénile gagne du terrain, celle des parents s\'y associe, les églises sont à la solde du diable avec des prédicateurs sans Saint-Esprit, et même sans morale. L\'école ne produit plus rien : on y entre bon, on en sort deux fois enfant de l\'enfer. Notre jeunesse n\'a plus de modèle digne de ce nom.'**
  String get ecamoSectionYouthChallengeP2;

  /// No description provided for @ecamoSectionYouthChallengeP3.
  ///
  /// In fr, this message translates to:
  /// **'Ce ravage est mondial. Un peu partout, on se plaint du comportement des jeunes, en accomplissement des prophéties de la Bible sur la rébellion des enfants. À quel avenir doit-on s\'attendre pour notre société et pour la jeunesse de Shekinah Tabernacle en particulier ?'**
  String get ecamoSectionYouthChallengeP3;

  /// No description provided for @ecamoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'École Chrétienne Arche de Moïse'**
  String get ecamoSubtitle;

  /// No description provided for @ecamoTitle.
  ///
  /// In fr, this message translates to:
  /// **'ECAMO'**
  String get ecamoTitle;

  /// No description provided for @filterBy.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par'**
  String get filterBy;

  /// No description provided for @filterFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get filterFormat;

  /// No description provided for @filterYear.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get filterYear;

  /// No description provided for @filterPreacher.
  ///
  /// In fr, this message translates to:
  /// **'Prédicateur'**
  String get filterPreacher;

  /// No description provided for @filterMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus de filtres'**
  String get filterMore;

  /// No description provided for @filterMoreActive.
  ///
  /// In fr, this message translates to:
  /// **'Plus de filtres ({count})'**
  String filterMoreActive(int count);

  /// No description provided for @filterType.
  ///
  /// In fr, this message translates to:
  /// **'Type de culte'**
  String get filterType;

  /// No description provided for @filterTime.
  ///
  /// In fr, this message translates to:
  /// **'Moment'**
  String get filterTime;

  /// No description provided for @filterLocation.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get filterLocation;

  /// No description provided for @filterResetExtra.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get filterResetExtra;

  /// No description provided for @filterApplyExtra.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get filterApplyExtra;

  /// No description provided for @fondationFactAssembly.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Tabernacle — assemblée interdénominationnelle'**
  String get fondationFactAssembly;

  /// No description provided for @fondationFactMissionWorks.
  ///
  /// In fr, this message translates to:
  /// **'Œuvres missionnaires : Publications, ECAMO et plus'**
  String get fondationFactMissionWorks;

  /// No description provided for @fondationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fondation Shekinah'**
  String get fondationLabel;

  /// No description provided for @fondationMessageNations.
  ///
  /// In fr, this message translates to:
  /// **'Le Message pour les nations'**
  String get fondationMessageNations;

  /// No description provided for @fondationMessageNationsP1.
  ///
  /// In fr, this message translates to:
  /// **'Prophète majeur envoyé conformément aux promesses bibliques, frère Branham était conscient que son Message devait parcourir le monde et atteindre les coins les plus reculés de notre planète.'**
  String get fondationMessageNationsP1;

  /// No description provided for @fondationMessageNationsP2.
  ///
  /// In fr, this message translates to:
  /// **'Sur recommandation du Seigneur, il a manifesté un grand souci de voir le Message, évangile du temps de la fin, être diffusé sous forme de bandes, de brochures et de livres pour servir de témoignage à toutes les nations.'**
  String get fondationMessageNationsP2;

  /// No description provided for @fondationScriptureQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Oh ! Je voudrais que mes paroles fussent écrites, qu\'elles fussent écrites dans un livre. Je voudrais qu\'avec un burin de fer et avec du plomb, elles fussent pour toujours gravées dans le roc… »'**
  String get fondationScriptureQuote;

  /// No description provided for @fondationScriptureRef.
  ///
  /// In fr, this message translates to:
  /// **'Job 19:23-24'**
  String get fondationScriptureRef;

  /// No description provided for @fondationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fondation Shekinah'**
  String get fondationTitle;

  /// No description provided for @fondationWordForAll.
  ///
  /// In fr, this message translates to:
  /// **'La Parole pour tous'**
  String get fondationWordForAll;

  /// No description provided for @fondationWordForAllP1.
  ///
  /// In fr, this message translates to:
  /// **'La volonté de Dieu est que tous les hommes arrivent à la connaissance de la Vérité qui est Sa Parole. Car c\'est celle-ci qui les affranchit et les sanctifie. N\'a-t-Il pas dit que Mon peuple meurt à cause de l\'ignorance ?'**
  String get fondationWordForAllP1;

  /// No description provided for @fondationWordForAllP2.
  ///
  /// In fr, this message translates to:
  /// **'Quand Dieu a donné la loi à Moïse, Il l\'a écrite Lui-même sur des tables qu\'Il a alors confiées à Son prophète pour L\'apporter au peuple.'**
  String get fondationWordForAllP2;

  /// No description provided for @fondationWrittenWord.
  ///
  /// In fr, this message translates to:
  /// **'La Parole écrite à travers les âges'**
  String get fondationWrittenWord;

  /// No description provided for @fondationWrittenWordP1.
  ///
  /// In fr, this message translates to:
  /// **'Jérémie a reçu un message de la part de Dieu et Baruk, son secrétaire, l\'a mis à l\'écrit afin qu\'il soit lu au peuple. En son temps, le Seigneur Jésus a choisi douze apôtres pour répandre le message et quelques-uns parmi eux et d\'autres hommes appelés par Dieu ont mis à l\'écrit Ses Paroles et Sa Vie pour qu\'il soit porté à toutes les générations futures.'**
  String get fondationWrittenWordP1;

  /// No description provided for @fondationWrittenWordP2.
  ///
  /// In fr, this message translates to:
  /// **'Après sa conversion et son appel au ministère, Paul a écrit lui-même sous forme de lettres les commandements du Seigneur à l\'intention de l\'Église.'**
  String get fondationWrittenWordP2;

  /// No description provided for @genericError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get genericError;

  /// No description provided for @homeALaLune.
  ///
  /// In fr, this message translates to:
  /// **'A la lune'**
  String get homeALaLune;

  /// No description provided for @homeAfterReconstruction.
  ///
  /// In fr, this message translates to:
  /// **'Après reconstruction'**
  String get homeAfterReconstruction;

  /// No description provided for @homeChecking.
  ///
  /// In fr, this message translates to:
  /// **'Vérification…'**
  String get homeChecking;

  /// No description provided for @homeCommuniqueBadge.
  ///
  /// In fr, this message translates to:
  /// **'Communiqué'**
  String get homeCommuniqueBadge;

  /// No description provided for @homeCommuniqueBody.
  ///
  /// In fr, this message translates to:
  /// **'Consultez les annonces officielles publiées pour l\'assemblée.'**
  String get homeCommuniqueBody;

  /// No description provided for @homeCommuniquesInEffect.
  ///
  /// In fr, this message translates to:
  /// **'Communiqués en vigueur'**
  String get homeCommuniquesInEffect;

  /// No description provided for @homeConsultALaLune.
  ///
  /// In fr, this message translates to:
  /// **'Consulter A la lune'**
  String get homeConsultALaLune;

  /// No description provided for @homeFeatured.
  ///
  /// In fr, this message translates to:
  /// **'À la une'**
  String get homeFeatured;

  /// No description provided for @homeBranhamAudioTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sermons de William Branham'**
  String get homeBranhamAudioTitle;

  /// No description provided for @homeBranhamAudioBody.
  ///
  /// In fr, this message translates to:
  /// **'Tous les sermons audio du prophète William Marrion Branham, disponibles en plusieurs langues.'**
  String get homeBranhamAudioBody;

  /// No description provided for @homeBranhamAudioAction.
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get homeBranhamAudioAction;

  /// No description provided for @homeImportantAnnouncements.
  ///
  /// In fr, this message translates to:
  /// **'Annonces importantes'**
  String get homeImportantAnnouncements;

  /// No description provided for @homeLive.
  ///
  /// In fr, this message translates to:
  /// **'En direct'**
  String get homeLive;

  /// No description provided for @homeLiveSince.
  ///
  /// In fr, this message translates to:
  /// **'EN DIRECT DEPUIS'**
  String get homeLiveSince;

  /// No description provided for @homeLiveStreaming.
  ///
  /// In fr, this message translates to:
  /// **'Live streaming'**
  String get homeLiveStreaming;

  /// No description provided for @homeMenuSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode, langue et profil'**
  String get homeMenuSubtitle;

  /// No description provided for @homeMenuTitle.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get homeMenuTitle;

  /// No description provided for @homeMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get homeMyProfile;

  /// No description provided for @homeNextService.
  ///
  /// In fr, this message translates to:
  /// **'PROCHAIN CULTE'**
  String get homeNextService;

  /// No description provided for @homeNextServiceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prochain culte'**
  String get homeNextServiceLabel;

  /// No description provided for @homeOfficialAnnouncement.
  ///
  /// In fr, this message translates to:
  /// **'Annonce officielle'**
  String get homeOfficialAnnouncement;

  /// No description provided for @homeOfficialCommunique.
  ///
  /// In fr, this message translates to:
  /// **'Communiqué officiel'**
  String get homeOfficialCommunique;

  /// No description provided for @homeOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get homeOffline;

  /// No description provided for @homePredicationBadge.
  ///
  /// In fr, this message translates to:
  /// **'Prédication'**
  String get homePredicationBadge;

  /// No description provided for @homeRecentPredications.
  ///
  /// In fr, this message translates to:
  /// **'Prédications récentes'**
  String get homeRecentPredications;

  /// No description provided for @homeRecentPredicationsBody.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez les dernières prédications du mois en cours.'**
  String get homeRecentPredicationsBody;

  /// No description provided for @homeScriptureBanner.
  ///
  /// In fr, this message translates to:
  /// **'Malachie 4:4-6  ·  Luc 17:30  ·  Apocalypse 10:1-7'**
  String get homeScriptureBanner;

  /// No description provided for @homeSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher prédications, cantiques...'**
  String get homeSearchHint;

  /// No description provided for @homeTempleMoriah.
  ///
  /// In fr, this message translates to:
  /// **'Temple Moriah'**
  String get homeTempleMoriah;

  /// No description provided for @homeTheLive.
  ///
  /// In fr, this message translates to:
  /// **'Le Direct'**
  String get homeTheLive;

  /// No description provided for @homeThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get homeThisMonth;

  /// No description provided for @homeTimeRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Temps restant'**
  String get homeTimeRemaining;

  /// No description provided for @homeWeeklySchedule.
  ///
  /// In fr, this message translates to:
  /// **'Horaires de la semaine'**
  String get homeWeeklySchedule;

  /// No description provided for @inBrief.
  ///
  /// In fr, this message translates to:
  /// **'En bref'**
  String get inBrief;

  /// No description provided for @langChinese.
  ///
  /// In fr, this message translates to:
  /// **'中文'**
  String get langChinese;

  /// No description provided for @langEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get langFrench;

  /// No description provided for @langPortuguese.
  ///
  /// In fr, this message translates to:
  /// **'Português'**
  String get langPortuguese;

  /// No description provided for @langSpanish.
  ///
  /// In fr, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @learnMore.
  ///
  /// In fr, this message translates to:
  /// **'En savoir plus'**
  String get learnMore;

  /// No description provided for @libraryAllCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get libraryAllCategories;

  /// No description provided for @libraryBackToYears.
  ///
  /// In fr, this message translates to:
  /// **'Retour aux années'**
  String get libraryBackToYears;

  /// No description provided for @libraryBooksAvailable.
  ///
  /// In fr, this message translates to:
  /// **'{count} ouvrages disponibles'**
  String libraryBooksAvailable(int count);

  /// No description provided for @libraryCatalogLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le catalogue.'**
  String get libraryCatalogLoadError;

  /// No description provided for @libraryCategoryDivers.
  ///
  /// In fr, this message translates to:
  /// **'Divers'**
  String get libraryCategoryDivers;

  /// No description provided for @libraryCategoryFaithDoctrine.
  ///
  /// In fr, this message translates to:
  /// **'Foi et Doctrine'**
  String get libraryCategoryFaithDoctrine;

  /// No description provided for @libraryCategoryFamily.
  ///
  /// In fr, this message translates to:
  /// **'La Famille'**
  String get libraryCategoryFamily;

  /// No description provided for @libraryCategoryMarriage.
  ///
  /// In fr, this message translates to:
  /// **'Le Mariage'**
  String get libraryCategoryMarriage;

  /// No description provided for @libraryCategorySpecial.
  ///
  /// In fr, this message translates to:
  /// **'Spécial'**
  String get libraryCategorySpecial;

  /// No description provided for @libraryCategoryWoman.
  ///
  /// In fr, this message translates to:
  /// **'La Femme'**
  String get libraryCategoryWoman;

  /// No description provided for @libraryDownloadAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout télécharger'**
  String get libraryDownloadAll;

  /// No description provided for @libraryDownloadAllConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger tous les éléments affichés ({count}) pour une lecture hors ligne ?'**
  String libraryDownloadAllConfirm(int count);

  /// No description provided for @libraryDownloadAllDone.
  ///
  /// In fr, this message translates to:
  /// **'{downloaded} téléchargé(s), {skipped} déjà disponible(s).'**
  String libraryDownloadAllDone(int downloaded, int skipped);

  /// No description provided for @libraryDownloadAllProgress.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement {current}/{total}'**
  String libraryDownloadAllProgress(int current, int total);

  /// No description provided for @libraryHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get libraryHome;

  /// No description provided for @libraryHomeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Pépite d\'or : citations rassemblées sur différents sujets prêchés par le Pasteur Richard Diyoka, tirées du Message de William Marrion Branham et de la Bible. Shekinah Publication : sermons du prophète William Branham traduits et imprimés par Shekinah Publications.'**
  String get libraryHomeDescription;

  /// No description provided for @libraryPepitesDescription.
  ///
  /// In fr, this message translates to:
  /// **'Citations rassemblées sur différents sujets prêchés par le Pasteur Richard Diyoka, tirées du Message de William Marrion Branham et de la Bible.'**
  String get libraryPepitesDescription;

  /// No description provided for @libraryPublicationDescription.
  ///
  /// In fr, this message translates to:
  /// **'Sermons du prophète William Branham traduits et imprimés par Shekinah Publications.'**
  String get libraryPublicationDescription;

  /// No description provided for @libraryBackToHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get libraryBackToHome;

  /// No description provided for @libraryLoadingPdf.
  ///
  /// In fr, this message translates to:
  /// **'Chargement du PDF…'**
  String get libraryLoadingPdf;

  /// No description provided for @libraryMessageCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}'**
  String libraryMessageCount(int count);

  /// No description provided for @libraryMessagesAvailable.
  ///
  /// In fr, this message translates to:
  /// **'{count} messages disponibles'**
  String libraryMessagesAvailable(int count);

  /// No description provided for @libraryNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get libraryNoResults;

  /// No description provided for @libraryOpenExternally.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans une autre application'**
  String get libraryOpenExternally;

  /// No description provided for @libraryOpenPdf.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le PDF'**
  String get libraryOpenPdf;

  /// No description provided for @libraryReadOffline.
  ///
  /// In fr, this message translates to:
  /// **'Lire hors ligne'**
  String get libraryReadOffline;

  /// No description provided for @libraryOfflineLink.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque hors ligne'**
  String get libraryOfflineLink;

  /// No description provided for @libraryOfflineLinkSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Documents déjà téléchargés'**
  String get libraryOfflineLinkSubtitle;

  /// No description provided for @libraryPdfLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'afficher ce PDF.'**
  String get libraryPdfLoadError;

  /// No description provided for @libraryPepites.
  ///
  /// In fr, this message translates to:
  /// **'Pépites d\'or'**
  String get libraryPepites;

  /// No description provided for @libraryPublication.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Publication'**
  String get libraryPublication;

  /// No description provided for @libraryPublicationYearsHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une année pour afficher les messages.'**
  String get libraryPublicationYearsHint;

  /// No description provided for @librarySortBy.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get librarySortBy;

  /// No description provided for @librarySortByDateAsc.
  ///
  /// In fr, this message translates to:
  /// **'Date (plus ancien)'**
  String get librarySortByDateAsc;

  /// No description provided for @librarySortByDateDesc.
  ///
  /// In fr, this message translates to:
  /// **'Date (plus récent)'**
  String get librarySortByDateDesc;

  /// No description provided for @librarySortByTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre (A-Z)'**
  String get librarySortByTitle;

  /// No description provided for @pdfReaderAnnotations.
  ///
  /// In fr, this message translates to:
  /// **'Annotations'**
  String get pdfReaderAnnotations;

  /// No description provided for @pdfReaderAnnotationsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Annotation enregistrée hors ligne.'**
  String get pdfReaderAnnotationsSaved;

  /// No description provided for @pdfReaderBookmark.
  ///
  /// In fr, this message translates to:
  /// **'Marquer la page'**
  String get pdfReaderBookmark;

  /// No description provided for @pdfReaderBookmarks.
  ///
  /// In fr, this message translates to:
  /// **'Signets'**
  String get pdfReaderBookmarks;

  /// No description provided for @pdfReaderClearAnnotations.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get pdfReaderClearAnnotations;

  /// No description provided for @pdfReaderGoToPage.
  ///
  /// In fr, this message translates to:
  /// **'Aller à la page'**
  String get pdfReaderGoToPage;

  /// No description provided for @pdfReaderHighlight.
  ///
  /// In fr, this message translates to:
  /// **'Surligner'**
  String get pdfReaderHighlight;

  /// No description provided for @pdfReaderMatchCount.
  ///
  /// In fr, this message translates to:
  /// **'{current} / {total}'**
  String pdfReaderMatchCount(int current, int total);

  /// No description provided for @pdfReaderNextMatch.
  ///
  /// In fr, this message translates to:
  /// **'Occurrence suivante'**
  String get pdfReaderNextMatch;

  /// No description provided for @pdfReaderNightMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode nuit'**
  String get pdfReaderNightMode;

  /// No description provided for @pdfReaderNoAnnotations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune annotation enregistrée.'**
  String get pdfReaderNoAnnotations;

  /// No description provided for @pdfReaderNoBookmarks.
  ///
  /// In fr, this message translates to:
  /// **'Aucun signet pour ce message.'**
  String get pdfReaderNoBookmarks;

  /// No description provided for @pdfReaderNoMatches.
  ///
  /// In fr, this message translates to:
  /// **'Aucune occurrence'**
  String get pdfReaderNoMatches;

  /// No description provided for @pdfReaderPageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Page {page}'**
  String pdfReaderPageLabel(int page);

  /// No description provided for @pdfReaderPageOf.
  ///
  /// In fr, this message translates to:
  /// **'{current} / {total}'**
  String pdfReaderPageOf(int current, int total);

  /// No description provided for @pdfReaderPreviousMatch.
  ///
  /// In fr, this message translates to:
  /// **'Occurrence précédente'**
  String get pdfReaderPreviousMatch;

  /// No description provided for @pdfReaderSearchCaseSensitive.
  ///
  /// In fr, this message translates to:
  /// **'Sensible à la casse'**
  String get pdfReaderSearchCaseSensitive;

  /// No description provided for @pdfReaderSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans le document…'**
  String get pdfReaderSearchHint;

  /// No description provided for @pdfReaderSearchInDocument.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans le message'**
  String get pdfReaderSearchInDocument;

  /// No description provided for @pdfReaderSearchWholeWord.
  ///
  /// In fr, this message translates to:
  /// **'Mot entier'**
  String get pdfReaderSearchWholeWord;

  /// No description provided for @pdfReaderSelectTextFirst.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez du texte dans le document.'**
  String get pdfReaderSelectTextFirst;

  /// No description provided for @pdfReaderUnderline.
  ///
  /// In fr, this message translates to:
  /// **'Souligner'**
  String get pdfReaderUnderline;

  /// No description provided for @pdfReaderSinglePageView.
  ///
  /// In fr, this message translates to:
  /// **'Page par page'**
  String get pdfReaderSinglePageView;

  /// No description provided for @pdfReaderContinuousView.
  ///
  /// In fr, this message translates to:
  /// **'Document entier'**
  String get pdfReaderContinuousView;

  /// No description provided for @pdfReaderPreviousPage.
  ///
  /// In fr, this message translates to:
  /// **'Page précédente'**
  String get pdfReaderPreviousPage;

  /// No description provided for @pdfReaderNextPage.
  ///
  /// In fr, this message translates to:
  /// **'Page suivante'**
  String get pdfReaderNextPage;

  /// No description provided for @pdfReaderZoomIn.
  ///
  /// In fr, this message translates to:
  /// **'Agrandir le texte'**
  String get pdfReaderZoomIn;

  /// No description provided for @pdfReaderZoomOut.
  ///
  /// In fr, this message translates to:
  /// **'Réduire le texte'**
  String get pdfReaderZoomOut;

  /// No description provided for @pdfReaderZoomReset.
  ///
  /// In fr, this message translates to:
  /// **'Taille normale'**
  String get pdfReaderZoomReset;

  /// No description provided for @pdfReaderZoomLevel.
  ///
  /// In fr, this message translates to:
  /// **'{percent} %'**
  String pdfReaderZoomLevel(int percent);

  /// No description provided for @libraryMustDownloadToRead.
  ///
  /// In fr, this message translates to:
  /// **'Ce document doit être téléchargé avant lecture pour permettre notes, surlignages et signets hors ligne.'**
  String get libraryMustDownloadToRead;

  /// No description provided for @libraryDownloadAndOpen.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger et ouvrir'**
  String get libraryDownloadAndOpen;

  /// No description provided for @librarySearchBooksHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une pépite…'**
  String get librarySearchBooksHint;

  /// No description provided for @librarySearchMessagesHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un message…'**
  String get librarySearchMessagesHint;

  /// No description provided for @librarySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Publications et ressources'**
  String get librarySubtitle;

  /// No description provided for @libraryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Library'**
  String get libraryTitle;

  /// No description provided for @libraryYearUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Date inconnue'**
  String get libraryYearUnknown;

  /// No description provided for @liveAssembly.
  ///
  /// In fr, this message translates to:
  /// **'Assemblée'**
  String get liveAssembly;

  /// No description provided for @liveAudioInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Audio en direct'**
  String get liveAudioInProgress;

  /// No description provided for @liveConnectedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes connecté au flux officiel Shekinah.'**
  String get liveConnectedMessage;

  /// No description provided for @liveCountdown.
  ///
  /// In fr, this message translates to:
  /// **'Compte à rebours'**
  String get liveCountdown;

  /// No description provided for @liveDirect.
  ///
  /// In fr, this message translates to:
  /// **'Direct'**
  String get liveDirect;

  /// No description provided for @liveFloatingAudio.
  ///
  /// In fr, this message translates to:
  /// **'Audio en direct'**
  String get liveFloatingAudio;

  /// No description provided for @liveFloatingVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo en direct'**
  String get liveFloatingVideo;

  /// No description provided for @liveFloatingWindow.
  ///
  /// In fr, this message translates to:
  /// **'Fenêtre flottante'**
  String get liveFloatingWindow;

  /// No description provided for @liveListenAudio.
  ///
  /// In fr, this message translates to:
  /// **'Écoute audio'**
  String get liveListenAudio;

  /// No description provided for @liveNextServiceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prochain culte'**
  String get liveNextServiceLabel;

  /// No description provided for @liveNoStream.
  ///
  /// In fr, this message translates to:
  /// **'Aucun live pour le moment'**
  String get liveNoStream;

  /// No description provided for @livePlayerMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le lecteur s\'ouvre sur le stream officiel (Vimeo / audio), sans quitter l\'application.'**
  String get livePlayerMessage;

  /// No description provided for @liveServiceInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Culte en direct'**
  String get liveServiceInProgress;

  /// No description provided for @liveSinceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Direct en cours depuis'**
  String get liveSinceLabel;

  /// No description provided for @liveTapToJoin.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour rejoindre le stream'**
  String get liveTapToJoin;

  /// No description provided for @liveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Streaming en direct'**
  String get liveTitle;

  /// No description provided for @liveWatchNow.
  ///
  /// In fr, this message translates to:
  /// **'Regarder maintenant'**
  String get liveWatchNow;

  /// No description provided for @liveWatchingSince.
  ///
  /// In fr, this message translates to:
  /// **'Vous suivez depuis {elapsed}'**
  String liveWatchingSince(String elapsed);

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get loading;

  /// No description provided for @mariageAnnounceBansBody.
  ///
  /// In fr, this message translates to:
  /// **'Les bans des couples dont le mariage est programmé seront lus pendant les cultes du dimanche. L\'assemblée est invitée à prier pour ces foyers à venir.'**
  String get mariageAnnounceBansBody;

  /// No description provided for @mariageAnnounceBansDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get mariageAnnounceBansDateLabel;

  /// No description provided for @mariageAnnounceBansTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bans de mariage'**
  String get mariageAnnounceBansTitle;

  /// No description provided for @mariageAnnounceMoriahBody.
  ///
  /// In fr, this message translates to:
  /// **'En raison des travaux liés au sinistre du Temple Moriah, les célébrations peuvent être adaptées selon les indications du comité pastoral. Merci de votre compréhension.'**
  String get mariageAnnounceMoriahBody;

  /// No description provided for @mariageAnnounceMoriahDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get mariageAnnounceMoriahDateLabel;

  /// No description provided for @mariageAnnounceMoriahTitle.
  ///
  /// In fr, this message translates to:
  /// **'Célébrations à Moriah'**
  String get mariageAnnounceMoriahTitle;

  /// No description provided for @mariageAnnouncePrepBody.
  ///
  /// In fr, this message translates to:
  /// **'Des rencontres de préparation au mariage sont organisées sous la direction pastorale. Les dates sont communiquées après validation du dossier auprès de l\'église.'**
  String get mariageAnnouncePrepBody;

  /// No description provided for @mariageAnnouncePrepDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Permanent'**
  String get mariageAnnouncePrepDateLabel;

  /// No description provided for @mariageAnnouncePrepTitle.
  ///
  /// In fr, this message translates to:
  /// **'Préparation des fiancés'**
  String get mariageAnnouncePrepTitle;

  /// No description provided for @mariageAnnounceProcedureBody.
  ///
  /// In fr, this message translates to:
  /// **'Tout couple désirant célébrer son mariage à Shekinah Tabernacle est invité à se présenter au secrétariat pastoral pour le dossier, l\'accompagnement et les annonces publiques à l\'assemblée.'**
  String get mariageAnnounceProcedureBody;

  /// No description provided for @mariageAnnounceProcedureDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Information'**
  String get mariageAnnounceProcedureDateLabel;

  /// No description provided for @mariageAnnounceProcedureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annonce de mariage — procédure'**
  String get mariageAnnounceProcedureTitle;

  /// No description provided for @mariageFooter.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations sont diffusées par l\'église. Pour un dossier personnel, adressez-vous au secrétariat sur place — aucun formulaire n\'est à remplir ici.'**
  String get mariageFooter;

  /// No description provided for @mariageRequestInfo.
  ///
  /// In fr, this message translates to:
  /// **'Pour toute demande de cérémonie de mariage, contactez l\'assemblée.'**
  String get mariageRequestInfo;

  /// No description provided for @mariageRequestTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demande de mariage'**
  String get mariageRequestTitle;

  /// No description provided for @mariageSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Cérémonies enregistrées de l\'assemblée'**
  String get mariageSubtitle;

  /// No description provided for @mariageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cérémonies de mariage'**
  String get mariageTitle;

  /// No description provided for @mediaListenWatch.
  ///
  /// In fr, this message translates to:
  /// **'Écouter / regarder'**
  String get mediaListenWatch;

  /// No description provided for @mediaPlayAudio.
  ///
  /// In fr, this message translates to:
  /// **'Écouter l\'audio'**
  String get mediaPlayAudio;

  /// No description provided for @mediaPlayVideo.
  ///
  /// In fr, this message translates to:
  /// **'Lire la vidéo'**
  String get mediaPlayVideo;

  /// No description provided for @mediaStreamingAudio.
  ///
  /// In fr, this message translates to:
  /// **'Streaming audio'**
  String get mediaStreamingAudio;

  /// No description provided for @mediaStreamingOrOffline.
  ///
  /// In fr, this message translates to:
  /// **'Streaming ou lecture hors ligne si déjà téléchargé.'**
  String get mediaStreamingOrOffline;

  /// No description provided for @mediaStreamingVideo.
  ///
  /// In fr, this message translates to:
  /// **'Streaming vidéo'**
  String get mediaStreamingVideo;

  /// No description provided for @mediaInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Infos média'**
  String get mediaInfoTitle;

  /// No description provided for @mediaInfoHint.
  ///
  /// In fr, this message translates to:
  /// **'Type, durée et taille lorsque disponibles.'**
  String get mediaInfoHint;

  /// No description provided for @mediaUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Pas disponible pour le moment.'**
  String get mediaUnavailable;

  /// No description provided for @navCantiques.
  ///
  /// In fr, this message translates to:
  /// **'Cantiques'**
  String get navCantiques;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get navOffline;

  /// No description provided for @navPlus.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navPlus;

  /// No description provided for @navPredications.
  ///
  /// In fr, this message translates to:
  /// **'Prédications'**
  String get navPredications;

  /// No description provided for @networkError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion. Vérifiez votre internet.'**
  String get networkError;

  /// No description provided for @noLiveMessage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun live en cours pour le moment'**
  String get noLiveMessage;

  /// No description provided for @notificationUnread.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune notification non lue} =1{1 notification non lue} other{{count} notifications non lues}}'**
  String notificationUnread(int count);

  /// No description provided for @notificationsCommuniqueBody.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau communiqué disponible dans « A la lune ».'**
  String get notificationsCommuniqueBody;

  /// No description provided for @notificationsInEffect.
  ///
  /// In fr, this message translates to:
  /// **'En vigueur'**
  String get notificationsInEffect;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout lire'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsNextServiceBody.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche {time} — rejoignez le live.'**
  String notificationsNextServiceBody(String time);

  /// No description provided for @notificationsNoneUnread.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification non lue'**
  String get notificationsNoneUnread;

  /// No description provided for @notificationsPermanent.
  ///
  /// In fr, this message translates to:
  /// **'Permanent'**
  String get notificationsPermanent;

  /// No description provided for @notificationsReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel'**
  String get notificationsReminder;

  /// No description provided for @notificationsTheWord.
  ///
  /// In fr, this message translates to:
  /// **'La Parole'**
  String get notificationsTheWord;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsUnread.
  ///
  /// In fr, this message translates to:
  /// **'Non lue'**
  String get notificationsUnread;

  /// No description provided for @notreEgliseAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get notreEgliseAbout;

  /// No description provided for @notreEgliseHeaderSummary.
  ///
  /// In fr, this message translates to:
  /// **'Assemblée interdénominationnelle à Kinshasa, porteuse du Message de l\'Heure et engagée dans l\'œuvre missionnaire à travers le monde.'**
  String get notreEgliseHeaderSummary;

  /// No description provided for @notreEglisePastor.
  ///
  /// In fr, this message translates to:
  /// **'Notre Pasteur'**
  String get notreEglisePastor;

  /// No description provided for @notreEglisePastorGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Chers frères et sœurs, que la grâce et la paix vous soient accordés avec abondance de la part de Dieu et Père, le Seigneur Jésus-Christ, notre Sauveur et Rédempteur. Nous vous saluons très cordialement en Son Nom par ces paroles :'**
  String get notreEglisePastorGreeting;

  /// No description provided for @notreEglisePastorMessage.
  ///
  /// In fr, this message translates to:
  /// **'Mot du pasteur'**
  String get notreEglisePastorMessage;

  /// No description provided for @notreEglisePastorP1.
  ///
  /// In fr, this message translates to:
  /// **'Depuis quelques années, le nombre de ceux qui reçoivent les sermons du prophète William Marrion Branham traduits en français ainsi que dans d\'autres langues et édités par Shekinah Publications, ont exprimé le désir d\'en savoir un peu plus sur cette œuvre missionnaire, notamment sur son fondement, son fonctionnement, ses ressources et/ou ses moyens, etc.'**
  String get notreEglisePastorP1;

  /// No description provided for @notreEglisePastorP2.
  ///
  /// In fr, this message translates to:
  /// **'En outre, après ces seize années dans l\'œuvre du Seigneur, nous avons senti dans le cœur la nécessité de partager avec vous notre expérience dans ce domaine et d\'apporter tant soit peu notre réconfort à tous les ouvriers de la onzième heure qui sont dans le champ, pour l\'exécution de la grande et dernière commission du Seigneur à Son Église (Marc 16.15-16). Ainsi, aujourd\'hui, le Seigneur notre Dieu a mis sur notre cœur de publier toutes ces œuvres, qui nous pensons seront une bénédiction pour l\'épouse de Christ.'**
  String get notreEglisePastorP2;

  /// No description provided for @notreEglisePastorP3.
  ///
  /// In fr, this message translates to:
  /// **'Or, le Seigneur, notre Dieu, a de nouveau manifesté Son amour envers Son peuple en accomplissant en ce temps de la fin de grandes œuvres que nul autre âge n\'a connues. Les mystères restés cachés dans tous les âges ont été révélés aujourd\'hui et doivent être portés à la connaissance du peuple de Dieu pour qu\'il soit blanchi, purifié et préparé pour l\'enlèvement (Daniel 12.4-12). Cette œuvre poursuit un double objectif : partager avec vous l\'œuvre que le Seigneur accomplit parmi nous, une œuvre certes difficile, mais si merveilleuse, et amener le croyant à faire du salut des âmes perdues sa préoccupation majeure.'**
  String get notreEglisePastorP3;

  /// No description provided for @notreEglisePastorP4.
  ///
  /// In fr, this message translates to:
  /// **'Nous croyons que le même Saint-Esprit vous révélera votre part de responsabilité dans ce grand et immense travail d\'annoncer ce glorieux Évangile, le Message du temps de la fin, aux gens de notre temps, sachant que c\'est un âge très court et que le Seigneur est en train d\'accomplir une œuvre rapide.'**
  String get notreEglisePastorP4;

  /// No description provided for @notreEglisePastorP5.
  ///
  /// In fr, this message translates to:
  /// **'Que le Seigneur vous accorde donc Sa parfaite grâce pour saisir cette vision afin que tous ensemble, convaincus que le Message est la vérité, c\'est le salut de l\'humanité et la Lumière dans ce temps des ténèbres, nous nous sentions concernés pour L\'apporter à nos frères que l\'ennemi tient encore captifs à travers le monde, dans la superstition, dans l\'ignorance et dans les ténèbres. Puissions-nous sentir l\'urgence d\'unir nos efforts et nos talents pour apporter à ce monde mourant l\'Évangile de notre Seigneur Jésus-Christ et achever rapidement cette grande mission qu\'Il a confiée à Son Église. Puisse le Seigneur vous bénir richement.'**
  String get notreEglisePastorP5;

  /// No description provided for @notreEglisePastorSignature.
  ///
  /// In fr, this message translates to:
  /// **'Votre serviteur,'**
  String get notreEglisePastorSignature;

  /// No description provided for @notreEgliseSisterChurchPastor.
  ///
  /// In fr, this message translates to:
  /// **'Pasteur / Contact'**
  String get notreEgliseSisterChurchPastor;

  /// No description provided for @notreEgliseSisterChurches.
  ///
  /// In fr, this message translates to:
  /// **'Nos Églises sœurs'**
  String get notreEgliseSisterChurches;

  /// No description provided for @notreEgliseSisterChurchesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 église répertoriée} other{{count} églises répertoriées}}'**
  String notreEgliseSisterChurchesCount(int count);

  /// No description provided for @notreEgliseSisterChurchesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nos églises sœurs à travers le monde'**
  String get notreEgliseSisterChurchesSubtitle;

  /// No description provided for @notreEgliseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notre Église'**
  String get notreEgliseTitle;

  /// No description provided for @offlineAvailableBannerAudio.
  ///
  /// In fr, this message translates to:
  /// **'Audio disponible hors ligne'**
  String get offlineAvailableBannerAudio;

  /// No description provided for @offlineAvailableBannerBoth.
  ///
  /// In fr, this message translates to:
  /// **'Audio et vidéo disponibles hors ligne'**
  String get offlineAvailableBannerBoth;

  /// No description provided for @offlineAvailableBannerVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo disponible hors ligne'**
  String get offlineAvailableBannerVideo;

  /// No description provided for @offlineAvailableInApp.
  ///
  /// In fr, this message translates to:
  /// **'disponible dans l\'app'**
  String get offlineAvailableInApp;

  /// No description provided for @offlineCategoryCantique.
  ///
  /// In fr, this message translates to:
  /// **'Cantique'**
  String get offlineCategoryCantique;

  /// No description provided for @offlineCategoryCeremony.
  ///
  /// In fr, this message translates to:
  /// **'Cérémonie'**
  String get offlineCategoryCeremony;

  /// No description provided for @offlineCategoryLibraryPepite.
  ///
  /// In fr, this message translates to:
  /// **'Pépites (Library)'**
  String get offlineCategoryLibraryPepite;

  /// No description provided for @offlineCategoryLibraryPublication.
  ///
  /// In fr, this message translates to:
  /// **'Publication (Library)'**
  String get offlineCategoryLibraryPublication;

  /// No description provided for @offlineCategoryPredication.
  ///
  /// In fr, this message translates to:
  /// **'Prédication'**
  String get offlineCategoryPredication;

  /// No description provided for @offlineEmptyCantique.
  ///
  /// In fr, this message translates to:
  /// **'Aucun cantique enregistré'**
  String get offlineEmptyCantique;

  /// No description provided for @offlineEmptyCantiqueHint.
  ///
  /// In fr, this message translates to:
  /// **'Depuis un cantique, enregistrez l\'audio ou la vidéo pour y accéder ici.'**
  String get offlineEmptyCantiqueHint;

  /// No description provided for @offlineEmptyCeremony.
  ///
  /// In fr, this message translates to:
  /// **'Aucune cérémonie enregistrée'**
  String get offlineEmptyCeremony;

  /// No description provided for @offlineEmptyCeremonyHint.
  ///
  /// In fr, this message translates to:
  /// **'Les cérémonies de mariage téléchargées apparaîtront ici.'**
  String get offlineEmptyCeremonyHint;

  /// No description provided for @offlineEmptyLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Aucun document bibliothèque'**
  String get offlineEmptyLibrary;

  /// No description provided for @offlineEmptyLibraryHint.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargez des pépites d\'or ou des messages depuis la bibliothèque pour les lire hors ligne.'**
  String get offlineEmptyLibraryHint;

  /// No description provided for @offlineEmptyPredication.
  ///
  /// In fr, this message translates to:
  /// **'Aucune prédication enregistrée'**
  String get offlineEmptyPredication;

  /// No description provided for @offlineEmptyPredicationHint.
  ///
  /// In fr, this message translates to:
  /// **'Depuis une fiche prédication, utilisez « Télécharger dans l\'app » pour écouter sans connexion.'**
  String get offlineEmptyPredicationHint;

  /// No description provided for @offlineFileCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun fichier} =1{1 fichier} other{{count} fichiers}}'**
  String offlineFileCount(int count);

  /// No description provided for @offlineFileNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Fichier introuvable sur cet appareil.'**
  String get offlineFileNotFound;

  /// No description provided for @offlinePlaybackFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire ce fichier dans l\'application. Vous pouvez l\'ouvrir avec le lecteur système.'**
  String get offlinePlaybackFailed;

  /// No description provided for @offlineOpenExternally.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir avec le lecteur système'**
  String get offlineOpenExternally;

  /// No description provided for @offlineFileActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions sur le fichier'**
  String get offlineFileActions;

  /// No description provided for @offlineShareFile.
  ///
  /// In fr, this message translates to:
  /// **'Partager le fichier'**
  String get offlineShareFile;

  /// No description provided for @offlineShowInExplorer.
  ///
  /// In fr, this message translates to:
  /// **'Afficher dans l\'explorateur'**
  String get offlineShowInExplorer;

  /// No description provided for @offlineFileRevealed.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement du fichier ouvert.'**
  String get offlineFileRevealed;

  /// No description provided for @offlineFileLocationUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir l\'emplacement de ce fichier.'**
  String get offlineFileLocationUnavailable;

  /// No description provided for @offlineMobileFileHint.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez Partager pour enregistrer une copie ou l\'ouvrir dans une autre application.'**
  String get offlineMobileFileHint;

  /// No description provided for @offlineFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get offlineFilterAll;

  /// No description provided for @offlineLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les fichiers.'**
  String get offlineLoadError;

  /// No description provided for @offlineNextTrack.
  ///
  /// In fr, this message translates to:
  /// **'Piste suivante'**
  String get offlineNextTrack;

  /// No description provided for @offlineNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get offlineNoResults;

  /// No description provided for @offlineNoResultsHint.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre mot-clé ou changez le filtre Audio / Vidéo.'**
  String get offlineNoResultsHint;

  /// No description provided for @offlineUnknownPreacher.
  ///
  /// In fr, this message translates to:
  /// **'Prédicateur inconnu'**
  String get offlineUnknownPreacher;

  /// No description provided for @offlinePause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get offlinePause;

  /// No description provided for @offlinePlay.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get offlinePlay;

  /// No description provided for @offlinePlayerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecteur hors ligne'**
  String get offlinePlayerTitle;

  /// No description provided for @offlinePreviousTrack.
  ///
  /// In fr, this message translates to:
  /// **'Piste précédente'**
  String get offlinePreviousTrack;

  /// No description provided for @offlineRepeat.
  ///
  /// In fr, this message translates to:
  /// **'Répéter'**
  String get offlineRepeat;

  /// No description provided for @offlineSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un titre, prédicateur…'**
  String get offlineSearchHint;

  /// No description provided for @offlineShuffle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture aléatoire'**
  String get offlineShuffle;

  /// No description provided for @offlineSkipBack.
  ///
  /// In fr, this message translates to:
  /// **'Reculer de 10 s'**
  String get offlineSkipBack;

  /// No description provided for @offlineSkipForward.
  ///
  /// In fr, this message translates to:
  /// **'Avancer de 10 s'**
  String get offlineSkipForward;

  /// No description provided for @offlineFullscreen.
  ///
  /// In fr, this message translates to:
  /// **'Plein écran'**
  String get offlineFullscreen;

  /// No description provided for @offlineFullscreenExit.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le plein écran'**
  String get offlineFullscreenExit;

  /// No description provided for @offlineStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get offlineStop;

  /// No description provided for @offlineStorageSummary.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 fichier} other{{count} fichiers}} · {sizeMb} Mo'**
  String offlineStorageSummary(int count, String sizeMb);

  /// No description provided for @offlineTabCantiques.
  ///
  /// In fr, this message translates to:
  /// **'Cantiques'**
  String get offlineTabCantiques;

  /// No description provided for @offlineTabCeremonies.
  ///
  /// In fr, this message translates to:
  /// **'Cérémonies'**
  String get offlineTabCeremonies;

  /// No description provided for @offlineTabLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get offlineTabLibrary;

  /// No description provided for @offlineTabPredications.
  ///
  /// In fr, this message translates to:
  /// **'Prédications'**
  String get offlineTabPredications;

  /// No description provided for @offlineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get offlineTitle;

  /// No description provided for @offlineChooseSection.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une section pour parcourir vos fichiers enregistrés.'**
  String get offlineChooseSection;

  /// No description provided for @offlineSectionMedia.
  ///
  /// In fr, this message translates to:
  /// **'Médias'**
  String get offlineSectionMedia;

  /// No description provided for @offlineSectionMediaSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Prédications, cantiques et cérémonies'**
  String get offlineSectionMediaSubtitle;

  /// No description provided for @offlineSectionLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get offlineSectionLibrary;

  /// No description provided for @offlineSectionLibrarySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pépites d\'or et publications'**
  String get offlineSectionLibrarySubtitle;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @openPlayer.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le lecteur'**
  String get openPlayer;

  /// No description provided for @pastorName.
  ///
  /// In fr, this message translates to:
  /// **'Pasteur Richard Diyoka'**
  String get pastorName;

  /// No description provided for @pastorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pasteur Richard Diyoka Nsanguluja'**
  String get pastorTitle;

  /// No description provided for @pdf.
  ///
  /// In fr, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @playOfflineReady.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne · prêt'**
  String get playOfflineReady;

  /// No description provided for @plusAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get plusAbout;

  /// No description provided for @plusBranham.
  ///
  /// In fr, this message translates to:
  /// **'WILLIAM MARRION BRANHAM'**
  String get plusBranham;

  /// No description provided for @plusContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get plusContact;

  /// No description provided for @plusCultes.
  ///
  /// In fr, this message translates to:
  /// **'Programme des cultes'**
  String get plusCultes;

  /// No description provided for @plusDonations.
  ///
  /// In fr, this message translates to:
  /// **'Offrandes / Dons'**
  String get plusDonations;

  /// No description provided for @plusEcamo.
  ///
  /// In fr, this message translates to:
  /// **'ECAMO'**
  String get plusEcamo;

  /// No description provided for @plusFondation.
  ///
  /// In fr, this message translates to:
  /// **'Fondation Shekinah'**
  String get plusFondation;

  /// No description provided for @plusNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get plusNotifications;

  /// No description provided for @plusNotreEglise.
  ///
  /// In fr, this message translates to:
  /// **'Notre Église'**
  String get plusNotreEglise;

  /// No description provided for @plusPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get plusPrivacy;

  /// No description provided for @plusProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get plusProfile;

  /// No description provided for @plusPublication.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Publication'**
  String get plusPublication;

  /// No description provided for @plusSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get plusSettings;

  /// No description provided for @plusShareApp.
  ///
  /// In fr, this message translates to:
  /// **'Partager l\'application'**
  String get plusShareApp;

  /// No description provided for @plusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get plusTitle;

  /// No description provided for @predicationCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune prédication} =1{1 prédication} other{{count} prédications}}'**
  String predicationCount(int count);

  /// No description provided for @predicationTimeEvening.
  ///
  /// In fr, this message translates to:
  /// **'Soir'**
  String get predicationTimeEvening;

  /// No description provided for @predicationTimeMorning.
  ///
  /// In fr, this message translates to:
  /// **'Matin'**
  String get predicationTimeMorning;

  /// No description provided for @predicationTimeVigil.
  ///
  /// In fr, this message translates to:
  /// **'Veillée'**
  String get predicationTimeVigil;

  /// No description provided for @predicationTypeParentMeeting.
  ///
  /// In fr, this message translates to:
  /// **'Réunion de parents'**
  String get predicationTypeParentMeeting;

  /// No description provided for @predicationTypePrayerMeeting.
  ///
  /// In fr, this message translates to:
  /// **'Réunion de prière'**
  String get predicationTypePrayerMeeting;

  /// No description provided for @predicationTypeRegular.
  ///
  /// In fr, this message translates to:
  /// **'Service régulier'**
  String get predicationTypeRegular;

  /// No description provided for @predicationTypeSpecialMeeting.
  ///
  /// In fr, this message translates to:
  /// **'Réunion spéciale'**
  String get predicationTypeSpecialMeeting;

  /// No description provided for @predicationTypeSundaySchool.
  ///
  /// In fr, this message translates to:
  /// **'École du dimanche'**
  String get predicationTypeSundaySchool;

  /// No description provided for @predicationTypeYouthMeeting.
  ///
  /// In fr, this message translates to:
  /// **'Réunion de jeunes'**
  String get predicationTypeYouthMeeting;

  /// No description provided for @predicationUntitled.
  ///
  /// In fr, this message translates to:
  /// **'Prédication'**
  String get predicationUntitled;

  /// No description provided for @privacyAboutDescription.
  ///
  /// In fr, this message translates to:
  /// **'Application de streaming pour les cultes Shekinah Gospel'**
  String get privacyAboutDescription;

  /// No description provided for @privacyArchives.
  ///
  /// In fr, this message translates to:
  /// **'• Archives : Navigation vers le site officiel'**
  String get privacyArchives;

  /// No description provided for @privacyCommitmentFooter.
  ///
  /// In fr, this message translates to:
  /// **'Pour la gloire de Dieu et votre confidentialité'**
  String get privacyCommitmentFooter;

  /// No description provided for @privacyCommitmentSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Zéro collecte, transparence totale, protection absolue'**
  String get privacyCommitmentSubtitle;

  /// No description provided for @privacyCommitmentTitle.
  ///
  /// In fr, this message translates to:
  /// **'🙏 Notre engagement'**
  String get privacyCommitmentTitle;

  /// No description provided for @privacyContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact : jeanmalonga08@gmail.com'**
  String get privacyContact;

  /// No description provided for @privacyDeveloper.
  ///
  /// In fr, this message translates to:
  /// **'Développeur : Jean Malonga'**
  String get privacyDeveloper;

  /// No description provided for @privacyDontAds.
  ///
  /// In fr, this message translates to:
  /// **'• Aucune publicité : Pas de marketing ciblé'**
  String get privacyDontAds;

  /// No description provided for @privacyDontDatabase.
  ///
  /// In fr, this message translates to:
  /// **'• Aucune base de données : Rien stocké'**
  String get privacyDontDatabase;

  /// No description provided for @privacyDontSignup.
  ///
  /// In fr, this message translates to:
  /// **'• Aucune inscription : Pas de compte requis'**
  String get privacyDontSignup;

  /// No description provided for @privacyDontTrack.
  ///
  /// In fr, this message translates to:
  /// **'• Aucun tracking : Pas de suivi comportemental'**
  String get privacyDontTrack;

  /// No description provided for @privacyHowItWorks.
  ///
  /// In fr, this message translates to:
  /// **'🔍 Fonctionnement'**
  String get privacyHowItWorks;

  /// No description provided for @privacyLocalStorage.
  ///
  /// In fr, this message translates to:
  /// **'• Stockage local : Uniquement sur votre appareil'**
  String get privacyLocalStorage;

  /// No description provided for @privacyNoDataCollection.
  ///
  /// In fr, this message translates to:
  /// **'❌ AUCUNE COLLECTE DE DONNÉES'**
  String get privacyNoDataCollection;

  /// No description provided for @privacyNoDataItem1.
  ///
  /// In fr, this message translates to:
  /// **'• Shekinah Tabernacle ne collecte AUCUNE donnée personnelle'**
  String get privacyNoDataItem1;

  /// No description provided for @privacyNoDataItem2.
  ///
  /// In fr, this message translates to:
  /// **'• Pas de compte utilisateur ni de profil'**
  String get privacyNoDataItem2;

  /// No description provided for @privacyNoDataItem3.
  ///
  /// In fr, this message translates to:
  /// **'• Aucun suivi ou analytics'**
  String get privacyNoDataItem3;

  /// No description provided for @privacyNoDataItem4.
  ///
  /// In fr, this message translates to:
  /// **'• Aucune vente de données'**
  String get privacyNoDataItem4;

  /// No description provided for @privacyPermissionsItem1.
  ///
  /// In fr, this message translates to:
  /// **'• Internet : Pour accéder aux contenus web'**
  String get privacyPermissionsItem1;

  /// No description provided for @privacyPermissionsItem2.
  ///
  /// In fr, this message translates to:
  /// **'• Stockage : Pour les préférences locales'**
  String get privacyPermissionsItem2;

  /// No description provided for @privacyPermissionsItem3.
  ///
  /// In fr, this message translates to:
  /// **'• Aucune autre : Pas de GPS, contacts, etc.'**
  String get privacyPermissionsItem3;

  /// No description provided for @privacyPermissionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'📱 Permissions'**
  String get privacyPermissionsTitle;

  /// No description provided for @privacyProtectionItem1.
  ///
  /// In fr, this message translates to:
  /// **'• Aucune donnée à protéger : Puisque rien n\'est collecté'**
  String get privacyProtectionItem1;

  /// No description provided for @privacyProtectionItem2.
  ///
  /// In fr, this message translates to:
  /// **'• Connexion sécurisée : HTTPS pour le streaming'**
  String get privacyProtectionItem2;

  /// No description provided for @privacyProtectionItem3.
  ///
  /// In fr, this message translates to:
  /// **'• Code transparent : Open source et vérifiable'**
  String get privacyProtectionItem3;

  /// No description provided for @privacyProtectionItem4.
  ///
  /// In fr, this message translates to:
  /// **'• Contrôle total : Vous gérez vos propres données'**
  String get privacyProtectionItem4;

  /// No description provided for @privacyProtectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'🔒 Protection'**
  String get privacyProtectionTitle;

  /// No description provided for @privacyStreaming.
  ///
  /// In fr, this message translates to:
  /// **'• Streaming direct : Via WebView vers shekinahgospel.org'**
  String get privacyStreaming;

  /// No description provided for @privacySupport.
  ///
  /// In fr, this message translates to:
  /// **'• Support : Contact direct hors de l\'application'**
  String get privacySupport;

  /// No description provided for @privacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de Confidentialité'**
  String get privacyTitle;

  /// No description provided for @privacyVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version 1.0.0 - 20 Avril 2026'**
  String get privacyVersion;

  /// No description provided for @privacyWhatWeDontDo.
  ///
  /// In fr, this message translates to:
  /// **'✅ Ce que nous ne faisons PAS'**
  String get privacyWhatWeDontDo;

  /// No description provided for @privacyYourRightsItem1.
  ///
  /// In fr, this message translates to:
  /// **'• Liberté totale : Aucune contrainte ou tracking'**
  String get privacyYourRightsItem1;

  /// No description provided for @privacyYourRightsItem2.
  ///
  /// In fr, this message translates to:
  /// **'• Contrôle local : Uniquement sur votre appareil'**
  String get privacyYourRightsItem2;

  /// No description provided for @privacyYourRightsItem3.
  ///
  /// In fr, this message translates to:
  /// **'• Suppression : Données effacées à la désinstallation'**
  String get privacyYourRightsItem3;

  /// No description provided for @privacyYourRightsItem4.
  ///
  /// In fr, this message translates to:
  /// **'• Support : jeanmalonga08@gmail.com'**
  String get privacyYourRightsItem4;

  /// No description provided for @privacyYourRightsTitle.
  ///
  /// In fr, this message translates to:
  /// **'👤 Vos droits'**
  String get privacyYourRightsTitle;

  /// No description provided for @profileAccountInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations du compte'**
  String get profileAccountInfo;

  /// No description provided for @profileAssembly.
  ///
  /// In fr, this message translates to:
  /// **'Assemblée'**
  String get profileAssembly;

  /// No description provided for @profileAssemblyName.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Tabernacle — Matete'**
  String get profileAssemblyName;

  /// No description provided for @profileFaithfulAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte fidèle'**
  String get profileFaithfulAccount;

  /// No description provided for @profileLivesJoined.
  ///
  /// In fr, this message translates to:
  /// **'Lives\nrejoints'**
  String get profileLivesJoined;

  /// No description provided for @profileLoggedOut.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes déconnecté.'**
  String get profileLoggedOut;

  /// No description provided for @profileLoginPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour synchroniser vos préférences et retrouver votre activité sur tous vos appareils.'**
  String get profileLoginPrompt;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profileNotConnected.
  ///
  /// In fr, this message translates to:
  /// **'Non connecté'**
  String get profileNotConnected;

  /// No description provided for @profileNotificationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Live, communiqués, cultes'**
  String get profileNotificationsSubtitle;

  /// No description provided for @profilePhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get profilePhone;

  /// No description provided for @profilePrayerTopics.
  ///
  /// In fr, this message translates to:
  /// **'Sujets de prière'**
  String get profilePrayerTopics;

  /// No description provided for @profilePrayerTopicsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Annonces d\'intercession de l\'église'**
  String get profilePrayerTopicsSubtitle;

  /// No description provided for @profilePredicationsListened.
  ///
  /// In fr, this message translates to:
  /// **'Prédications\nécoutées'**
  String get profilePredicationsListened;

  /// No description provided for @profilePreferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get profilePreferences;

  /// No description provided for @profilePreferencesSaved.
  ///
  /// In fr, this message translates to:
  /// **'Préférences enregistrées localement.'**
  String get profilePreferencesSaved;

  /// No description provided for @profileRequestsSent.
  ///
  /// In fr, this message translates to:
  /// **'Requêtes\nenvoyées'**
  String get profileRequestsSent;

  /// No description provided for @profileSupportMoriah.
  ///
  /// In fr, this message translates to:
  /// **'Soutenir Moriah'**
  String get profileSupportMoriah;

  /// No description provided for @profileSupportMoriahSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Campagne de reconstruction'**
  String get profileSupportMoriahSubtitle;

  /// No description provided for @profileVisitor.
  ///
  /// In fr, this message translates to:
  /// **'Visiteur'**
  String get profileVisitor;

  /// No description provided for @profileVisitorMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode visiteur'**
  String get profileVisitorMode;

  /// No description provided for @publicationBrochuresDistributed.
  ///
  /// In fr, this message translates to:
  /// **'Plus de 33 millions de brochures distribuées gratuitement'**
  String get publicationBrochuresDistributed;

  /// No description provided for @publicationBrochuresProduced.
  ///
  /// In fr, this message translates to:
  /// **'Plus de 40 millions de brochures produites'**
  String get publicationBrochuresProduced;

  /// No description provided for @publicationBrowsePrinted.
  ///
  /// In fr, this message translates to:
  /// **'Consulter tous les Messages imprimés'**
  String get publicationBrowsePrinted;

  /// No description provided for @publicationFactCountries.
  ///
  /// In fr, this message translates to:
  /// **'60 pays desservis à travers le monde'**
  String get publicationFactCountries;

  /// No description provided for @publicationFactPrinted.
  ///
  /// In fr, this message translates to:
  /// **'808 messages imprimés en français'**
  String get publicationFactPrinted;

  /// No description provided for @publicationFactTitles.
  ///
  /// In fr, this message translates to:
  /// **'147 titres en langues nationales, 117 en langues étrangères'**
  String get publicationFactTitles;

  /// No description provided for @publicationFactTranslated.
  ///
  /// In fr, this message translates to:
  /// **'1206 messages traduits en 17 ans de travail'**
  String get publicationFactTranslated;

  /// No description provided for @publicationGoldenNuggets.
  ///
  /// In fr, this message translates to:
  /// **'Citations/Pépites d\'or rassemblées sur différents sujets'**
  String get publicationGoldenNuggets;

  /// No description provided for @publicationInNumbers.
  ///
  /// In fr, this message translates to:
  /// **'En chiffres'**
  String get publicationInNumbers;

  /// No description provided for @publicationJune2013.
  ///
  /// In fr, this message translates to:
  /// **'03 juin 2013 : Fin de la traduction en français'**
  String get publicationJune2013;

  /// No description provided for @publicationJune2013P1.
  ///
  /// In fr, this message translates to:
  /// **'Le lundi 3 juin 2013, date du 23ème anniversaire de Shekinah Tabernacle, les traducteurs de Shekinah Publications ont remis solennellement le dernier sermon traduit — « Le Son confus », prêché à Jeffersonville le 18 décembre 1960 — entre les mains du Révérend Pasteur Richard Diyoka, au Village Béthanie.'**
  String get publicationJune2013P1;

  /// No description provided for @publicationJune2013P2.
  ///
  /// In fr, this message translates to:
  /// **'L\'Épouse du monde francophone dispose ainsi de la totalité des sermons traduits en français prêchés par le prophète de Dieu William Marrion Branham. Ce jour marquait l\'achèvement de 17 ans de travail de traduction.'**
  String get publicationJune2013P2;

  /// No description provided for @publicationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Publications'**
  String get publicationLabel;

  /// No description provided for @publicationMessageForAge.
  ///
  /// In fr, this message translates to:
  /// **'Le Message pour cet âge'**
  String get publicationMessageForAge;

  /// No description provided for @publicationMessageForAgeP1.
  ///
  /// In fr, this message translates to:
  /// **'Le Révérend William Marrion Branham, que le Dieu Tout-Puissant a confirmé comme le prophète de Dieu pour notre génération, a reçu du Seigneur un Message pour cet âge, contenu dans plus ou moins 1200 sermons enregistrés sur des bandes magnétiques.'**
  String get publicationMessageForAgeP1;

  /// No description provided for @publicationMessageForAgeP2.
  ///
  /// In fr, this message translates to:
  /// **'Ce Message devait être traduit, dans plusieurs langues, pour être diffusé à travers le monde entier, pour l\'édification de l\'Église et la préparation de l\'Épouse du Seigneur Jésus-Christ. Shekinah Missions est convaincue que ce Message est l\'Évangile du Seigneur Jésus-Christ pour ce temps de la fin.'**
  String get publicationMessageForAgeP2;

  /// No description provided for @publicationMissionSummary.
  ///
  /// In fr, this message translates to:
  /// **'Traduction, impression et diffusion gratuite du Message du temps de la fin dans le monde entier, pour l\'édification de l\'Église.'**
  String get publicationMissionSummary;

  /// No description provided for @publicationOurMission.
  ///
  /// In fr, this message translates to:
  /// **'Notre mission'**
  String get publicationOurMission;

  /// No description provided for @publicationOurMissionP1.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Missions s\'est donné la charge de diffuser cette Bonne Nouvelle du Royaume par la traduction du Message dans les langues nationales et internationales, ainsi que par la prédication et l\'enseignement de la Parole de Dieu conformément au Message du temps de la fin et à la Bible (Éphésiens, chapitre 4).'**
  String get publicationOurMissionP1;

  /// No description provided for @publicationOurMissionP2.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Missions reçoit les demandes des sermons du prophète de Dieu, William Marrion Branham, et y répond en envoyant gratuitement ces sermons. 60 pays à travers le monde sont servis.'**
  String get publicationOurMissionP2;

  /// No description provided for @publicationScriptureQuote.
  ///
  /// In fr, this message translates to:
  /// **'« Louez l\'Éternel, invoquez son nom ! Faites connaître parmi les peuples ses hauts faits ! »'**
  String get publicationScriptureQuote;

  /// No description provided for @publicationScriptureRef.
  ///
  /// In fr, this message translates to:
  /// **'Psaume 105:1'**
  String get publicationScriptureRef;

  /// No description provided for @publicationTagline.
  ///
  /// In fr, this message translates to:
  /// **'Œuvre missionnaire pour l\'Épouse de Christ'**
  String get publicationTagline;

  /// No description provided for @publicationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Publication'**
  String get publicationTitle;

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @requetesFooter.
  ///
  /// In fr, this message translates to:
  /// **'Ces sujets sont publiés par l\'église pour l\'union de prière. Ils ne constituent pas un formulaire à remplir.'**
  String get requetesFooter;

  /// No description provided for @requetesHeader.
  ///
  /// In fr, this message translates to:
  /// **'Sujets de prière de l\'assemblée'**
  String get requetesHeader;

  /// No description provided for @requetesMission.
  ///
  /// In fr, this message translates to:
  /// **'Mission & ouvriers'**
  String get requetesMission;

  /// No description provided for @requetesMissionBody.
  ///
  /// In fr, this message translates to:
  /// **'Souvenons-nous des pasteurs, évangélistes et ouvriers envoyés dans les champs. Que la Parole accomplisse Malachie 4:5-6.'**
  String get requetesMissionBody;

  /// No description provided for @requetesMoriah.
  ///
  /// In fr, this message translates to:
  /// **'Intercession pour le Temple Moriah'**
  String get requetesMoriah;

  /// No description provided for @requetesMoriahBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'assemblée est appelée à prier sans relâche pour la reconstruction du Temple Moriah après l\'incendie du 17 mai 2026. Que le Seigneur relève Sa maison et fortifie Son peuple.'**
  String get requetesMoriahBody;

  /// No description provided for @requetesSick.
  ///
  /// In fr, this message translates to:
  /// **'Malades et hôpitaux'**
  String get requetesSick;

  /// No description provided for @requetesSickBody.
  ///
  /// In fr, this message translates to:
  /// **'Nous portons devant le Seigneur Jésus-Christ tous les frères et sœurs en souffrance, ainsi que les familles qui accompagnent leurs malades dans les hôpitaux de Kinshasa et ailleurs.'**
  String get requetesSickBody;

  /// No description provided for @requetesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Annonces officielles portées à l\'intercession par {appName}.'**
  String requetesSubtitle(String appName);

  /// No description provided for @requetesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Requêtes'**
  String get requetesTitle;

  /// No description provided for @requetesYouth.
  ///
  /// In fr, this message translates to:
  /// **'Jeunes & familles'**
  String get requetesYouth;

  /// No description provided for @requetesYouthBody.
  ///
  /// In fr, this message translates to:
  /// **'Prière pour la jeunesse de Shekinah Tabernacle, les foyers chrétiens et la préparation de l\'Épouse à la venue de notre Seigneur.'**
  String get requetesYouthBody;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher prédications, cantiques...'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour cette recherche.'**
  String get searchNoResults;

  /// No description provided for @searchSectionCantiques.
  ///
  /// In fr, this message translates to:
  /// **'Cantiques'**
  String get searchSectionCantiques;

  /// No description provided for @searchSectionPredications.
  ///
  /// In fr, this message translates to:
  /// **'Prédications'**
  String get searchSectionPredications;

  /// No description provided for @searchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get searchTitle;

  /// No description provided for @searchTypeHint.
  ///
  /// In fr, this message translates to:
  /// **'Tapez un titre, un prédicateur ou un cantique.'**
  String get searchTypeHint;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get seeAll;

  /// No description provided for @seeLess.
  ///
  /// In fr, this message translates to:
  /// **'Voir moins'**
  String get seeLess;

  /// No description provided for @seeMore.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus...'**
  String get seeMore;

  /// No description provided for @seeMoreArrow.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus →'**
  String get seeMoreArrow;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @settingsApplication.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get settingsApplication;

  /// No description provided for @settingsDeveloperContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact développeur'**
  String get settingsDeveloperContact;

  /// No description provided for @settingsInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get settingsInformation;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'application'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Consulter les conditions d\'utilisation'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsThemeSystem;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsWorshipSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Horaires de culte'**
  String get settingsWorshipSchedule;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @shareAppMessage.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez l’application {appName} : cultes en direct, prédications, cantiques et bien plus.\n\nPlay Store : {playStoreUrl}\nApple Store : le lien Apple sera bientôt disponible\nSite web : {websiteUrl}\n\nPartagez et invitez vos proches à rejoindre la communauté !'**
  String shareAppMessage(
    String appName,
    String playStoreUrl,
    String websiteUrl,
  );

  /// No description provided for @shareCantiqueBody.
  ///
  /// In fr, this message translates to:
  /// **'Cantique : {title}\n{subtitle}\n\nÉcoutez ce cantique dans l\'application {appName} :\n{playStoreUrl}\n\nSite : {websiteUrl}'**
  String shareCantiqueBody(
    String title,
    String subtitle,
    String appName,
    String playStoreUrl,
    String websiteUrl,
  );

  /// No description provided for @shareCantiqueSubject.
  ///
  /// In fr, this message translates to:
  /// **'Cantique : {title}'**
  String shareCantiqueSubject(String title);

  /// No description provided for @shareListenInApp.
  ///
  /// In fr, this message translates to:
  /// **'Écoutez cette prédication dans l\'application {appName} :'**
  String shareListenInApp(String appName);

  /// No description provided for @shareOfflineBody.
  ///
  /// In fr, this message translates to:
  /// **'{category} : {title}\n{subtitle}\n{format} · disponible dans l\'app\n\nRetrouvez ce contenu dans l\'application {appName} :\n{playStoreUrl}\n\nSite : {websiteUrl}'**
  String shareOfflineBody(
    String category,
    String title,
    String subtitle,
    String format,
    String appName,
    String playStoreUrl,
    String websiteUrl,
  );

  /// No description provided for @sharePredicationBody.
  ///
  /// In fr, this message translates to:
  /// **'Prédication : {title}\n{preacher}\n{date}\n\nÉcoutez cette prédication dans l\'application Shekinah Tabernacle :\n{playStoreUrl}\n\nSite : {archivesUrl}'**
  String sharePredicationBody(
    String title,
    String preacher,
    String date,
    String archivesUrl,
    String playStoreUrl,
  );

  /// No description provided for @sharePredicationSubject.
  ///
  /// In fr, this message translates to:
  /// **'Prédication : {title}'**
  String sharePredicationSubject(String title);

  /// No description provided for @shareSite.
  ///
  /// In fr, this message translates to:
  /// **'Site : {url}'**
  String shareSite(String url);

  /// No description provided for @sinistreAfterTitle.
  ///
  /// In fr, this message translates to:
  /// **'APRÈS LE FEU :'**
  String get sinistreAfterTitle;

  /// No description provided for @sinistreBadge.
  ///
  /// In fr, this message translates to:
  /// **'SINISTRE MAJEUR · 17 MAI 2026'**
  String get sinistreBadge;

  /// No description provided for @sinistreBadgeAfterFire.
  ///
  /// In fr, this message translates to:
  /// **'APRÈS L\'INCENDIE'**
  String get sinistreBadgeAfterFire;

  /// No description provided for @sinistreBadgeSplendid.
  ///
  /// In fr, this message translates to:
  /// **'DÉDICACE SPLENDIDE'**
  String get sinistreBadgeSplendid;

  /// No description provided for @sinistreBalconyBody.
  ///
  /// In fr, this message translates to:
  /// **'Le balcon endommagé après l\'incendie du dimanche 17 mai 2026.'**
  String get sinistreBalconyBody;

  /// No description provided for @sinistreBeforeBody.
  ///
  /// In fr, this message translates to:
  /// **'Le majestueux Temple Moriah étincelant de lumière lors de sa dédicace triomphale en Août 2018.'**
  String get sinistreBeforeBody;

  /// No description provided for @sinistreBeforeTitle.
  ///
  /// In fr, this message translates to:
  /// **'AVANT L\'ÉPREUVE :'**
  String get sinistreBeforeTitle;

  /// No description provided for @sinistreEntranceBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'entrée principale du Temple Moriah après l\'incendie du dimanche 17 mai 2026.'**
  String get sinistreEntranceBody;

  /// No description provided for @sinistreFacadeBody.
  ///
  /// In fr, this message translates to:
  /// **'La façade a subi d\'importants dommages structurels après l\'incendie.'**
  String get sinistreFacadeBody;

  /// No description provided for @sinistreFacadeTitle.
  ///
  /// In fr, this message translates to:
  /// **'FAÇADE PRINCIPALE'**
  String get sinistreFacadeTitle;

  /// No description provided for @sinistreNotificationBody.
  ///
  /// In fr, this message translates to:
  /// **'Incendie du 17 mai 2026. Soutenez la reconstruction du temple.'**
  String get sinistreNotificationBody;

  /// No description provided for @sinistreNotificationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sinistre Majeur — Temple Moriah'**
  String get sinistreNotificationTitle;

  /// No description provided for @sinistreRoofBody.
  ///
  /// In fr, this message translates to:
  /// **'La toiture touchée par l\'incendie du dimanche 17 mai 2026.'**
  String get sinistreRoofBody;

  /// No description provided for @sinistreSanctuaryBody.
  ///
  /// In fr, this message translates to:
  /// **'Le sanctuaire dévasté après l\'incendie du dimanche 17 mai 2026.'**
  String get sinistreSanctuaryBody;

  /// No description provided for @sinistreVideoBeforeBody.
  ///
  /// In fr, this message translates to:
  /// **'Le temple en pleine vie, résonnant des chants de louange de milliers de fidèles.'**
  String get sinistreVideoBeforeBody;

  /// No description provided for @sinistreVideoAfterBody.
  ///
  /// In fr, this message translates to:
  /// **'Les images saisissantes de l\'incendie dévastateur consumant le sanctuaire.'**
  String get sinistreVideoAfterBody;

  /// No description provided for @sinistreSupportReconstruction.
  ///
  /// In fr, this message translates to:
  /// **'Soutenir la reconstruction'**
  String get sinistreSupportReconstruction;

  /// No description provided for @sizeKilobytes.
  ///
  /// In fr, this message translates to:
  /// **'{size} Ko'**
  String sizeKilobytes(int size);

  /// No description provided for @sizeMegabytes.
  ///
  /// In fr, this message translates to:
  /// **'{size} Mo'**
  String sizeMegabytes(String size);

  /// No description provided for @splashConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au réseau…'**
  String get splashConnecting;

  /// No description provided for @splashLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get splashLoading;

  /// No description provided for @themeModeDark.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In fr, this message translates to:
  /// **'Mode clair'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Thème système'**
  String get themeModeSystem;

  /// No description provided for @thisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get thisWeek;

  /// No description provided for @timeoutError.
  ///
  /// In fr, this message translates to:
  /// **'La connexion a expiré. Veuillez réessayer.'**
  String get timeoutError;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @unavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible'**
  String get unavailable;

  /// No description provided for @video.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get video;

  /// No description provided for @videoPlaybackHint.
  ///
  /// In fr, this message translates to:
  /// **'La vidéo est lue dans le lecteur ci-dessus. Utilisez les contrôles pour mettre en pause ou passer en plein écran.'**
  String get videoPlaybackHint;

  /// No description provided for @videoRelatedCantiques.
  ///
  /// In fr, this message translates to:
  /// **'Cantiques à regarder'**
  String get videoRelatedCantiques;

  /// No description provided for @videoRelatedPredications.
  ///
  /// In fr, this message translates to:
  /// **'Prédications similaires ou récentes'**
  String get videoRelatedPredications;

  /// No description provided for @visionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nous croyons au Message prêché par William Marrion Branham, accomplissant Malachie 4:5-6. À travers le Cri, ce Message appelle une Épouse à se préparer à la venue de notre Seigneur Jésus-Christ.'**
  String get visionMessage;

  /// No description provided for @visionTitle.
  ///
  /// In fr, this message translates to:
  /// **'La Parole pour l\'Épouse'**
  String get visionTitle;

  /// No description provided for @website.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get website;

  /// No description provided for @welcomeBlessing.
  ///
  /// In fr, this message translates to:
  /// **'Que la présence de Dieu vous accompagne'**
  String get welcomeBlessing;

  /// No description provided for @worshipAt.
  ///
  /// In fr, this message translates to:
  /// **'À {time}'**
  String worshipAt(String time);

  /// No description provided for @worshipSunday.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get worshipSunday;

  /// No description provided for @worshipThursday.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get worshipThursday;

  /// No description provided for @worshipTimeEvening.
  ///
  /// In fr, this message translates to:
  /// **'17h00'**
  String get worshipTimeEvening;

  /// No description provided for @worshipTimeSunday.
  ///
  /// In fr, this message translates to:
  /// **'09h30'**
  String get worshipTimeSunday;

  /// No description provided for @worshipWednesday.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get worshipWednesday;

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// No description provided for @downloadDataSaver.
  ///
  /// In fr, this message translates to:
  /// **'Économie de données (720p)'**
  String get downloadDataSaver;

  /// No description provided for @downloadDataSaverHint.
  ///
  /// In fr, this message translates to:
  /// **'Qualité nette sur téléphone, moins de données'**
  String get downloadDataSaverHint;

  /// No description provided for @downloadAudioDataHint.
  ///
  /// In fr, this message translates to:
  /// **'Beaucoup plus léger que la vidéo'**
  String get downloadAudioDataHint;

  /// No description provided for @plusUserManual.
  ///
  /// In fr, this message translates to:
  /// **'Manuel d\'utilisation'**
  String get plusUserManual;

  /// No description provided for @userManualTitle.
  ///
  /// In fr, this message translates to:
  /// **'Manuel d\'utilisation'**
  String get userManualTitle;

  /// No description provided for @userManualSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Guide détaillé pour suivre les cultes, explorer les archives et maîtriser toutes les fonctions de l\'application.'**
  String get userManualSubtitle;

  /// No description provided for @userManualIntroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get userManualIntroTitle;

  /// No description provided for @userManualIntroBody.
  ///
  /// In fr, this message translates to:
  /// **'Shekinah Tabernacle est l\'application officielle de l\'Assemblée Shekinah Tabernacle. Elle regroupe le culte en direct, les archives de prédications, les cantiques, la bibliothèque numérique et vos médias téléchargés.\n\n• Six onglets en bas de l\'écran organisent la navigation principale.\n• Cinq langues sont disponibles : français, anglais, espagnol, portugais et chinois.\n• Internet est nécessaire pour le streaming et les téléchargements ; seuls les fichiers déjà enregistrés se lisent hors connexion.\n• Ouvrez chaque section ci-dessous pour un mode d\'emploi pas à pas.'**
  String get userManualIntroBody;

  /// No description provided for @userManualNavTitle.
  ///
  /// In fr, this message translates to:
  /// **'Navigation'**
  String get userManualNavTitle;

  /// No description provided for @userManualNavBody.
  ///
  /// In fr, this message translates to:
  /// **'La barre inférieure comporte six onglets permanents :\n\n• Accueil — tableau de bord, statut du direct, annonces et raccourcis.\n• Prédications — catalogue complet des sermons archivés.\n• Cantiques — hymnes en audio ou vidéo.\n• Hors ligne — fichiers enregistrés sur l\'appareil.\n• Bibliothèque — livres, pépites d\'or et publications PDF.\n• Plus — contenus complémentaires, contact, réglages et ce manuel.\n\nPendant un direct, une fenêtre flottante peut rester visible par-dessus les autres écrans pour continuer l\'écoute en naviguant.'**
  String get userManualNavBody;

  /// No description provided for @userManualHomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get userManualHomeTitle;

  /// No description provided for @userManualHomeBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'écran d\'accueil centralise les informations utiles au quotidien :\n\n• En-tête — cloche (notifications), profil, menu (thème clair/sombre/système, langue, manuel).\n• Recherche — barre en haut ; ouvre la recherche globale prédications + cantiques.\n• Bannière Direct — rouge et animée si un culte est en cours ; sinon compte à rebours vers le prochain service.\n• À la une — carrousel de communiqués et prédications récentes ; « Tout voir » ouvre la page dédiée.\n• Temple Moriah — accès à la campagne de reconstruction.\n• Programme hebdomadaire — prochains cultes ; « Voir plus » ouvre l\'horaire complet.\n• Annonces importantes — communiqués en vigueur de l\'assemblée.\n\nTirez la page vers le bas pour actualiser le statut du direct.'**
  String get userManualHomeBody;

  /// No description provided for @userManualLiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Culte en direct'**
  String get userManualLiveTitle;

  /// No description provided for @userManualLiveBody.
  ///
  /// In fr, this message translates to:
  /// **'Accédez au direct via la bannière rouge sur l\'accueil.\n\nRejoindre le culte\n• Touchez le bouton de lecture central pour démarrer.\n• Choisissez Vidéo (Vimeo) ou Audio (flux radio Shekinah).\n• Sélectionnez la langue disponible : FR, EN ou PT selon le flux.\n\nPendant le direct\n• Le badge LIVE confirme la diffusion en cours.\n• Vidéo : plein écran via l\'icône dédiée ; fenêtre flottante pour continuer ailleurs dans l\'app.\n• Sous le lecteur vidéo : barre indiquant votre temps d\'écoute et la durée totale du live.\n• Le statut se rafraîchit automatiquement ; tirez vers le bas pour forcer l\'actualisation.\n• Ajustez le volume avec les boutons physiques du téléphone.\n\nEn cas de problème\n• Un message clair s\'affiche (connexion ou flux indisponible).\n• Touchez Réessayer après avoir vérifié votre Internet.\n\nHors direct\n• L\'écran affiche l\'horaire et le compte à rebours du prochain culte.'**
  String get userManualLiveBody;

  /// No description provided for @userManualPredicationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prédications'**
  String get userManualPredicationsTitle;

  /// No description provided for @userManualPredicationsBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'onglet Prédications donne accès aux archives du site shekinahgospel.org.\n\nRecherche et filtres\n• Barre de recherche — titre, prédicateur ou lieu (texte libre).\n• Année et Prédicateur — deux filtres côte à côte sur la même ligne.\n• Plus de filtres — type de culte, moment (matin/soir/veillée) et lieu (lieux normalisés).\n• Un badge rouge indique le nombre de filtres actifs ; un résumé s\'affiche sous le bouton.\n• Choisir un prédicateur efface l\'année pour afficher tout son historique.\n\nConsultation\n• Touchez une prédication pour ouvrir la fiche détail.\n• Écoutez l\'audio ou regardez la vidéo selon disponibilité.\n• Faites défiler pour charger plus de résultats ; tirez vers le bas pour actualiser.\n\nTéléchargement hors ligne\n• Sur la fiche : bouton Télécharger → audio (recommandé, plus léger) ou vidéo.\n• Vidéo : privilégiez « Économie de données (720p) » pour limiter la consommation mobile.\n• Partagez une prédication via le bouton Partager.'**
  String get userManualPredicationsBody;

  /// No description provided for @userManualCantiquesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cantiques'**
  String get userManualCantiquesTitle;

  /// No description provided for @userManualCantiquesBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'onglet Cantiques réunit les hymnes de l\'assemblée.\n\nRecherche et filtres\n• Barre de recherche — titre, catégorie, interprète ou numéro.\n• Format et Filtrer par — deux menus sur la même ligne (audio, vidéo ou catégorie).\n\nÉcoute\n• Ouvrez un cantique pour lancer la lecture audio ou vidéo.\n• Les vidéos YouTube utilisent une qualité adaptée au mobile (environ 720p).\n\nTéléchargement\n• Sur la fiche détail : enregistrez l\'audio ou la vidéo pour une lecture hors ligne.\n• Les fichiers apparaissent dans l\'onglet Hors ligne → Cantiques.\n\nTirez la liste vers le bas pour actualiser le catalogue.'**
  String get userManualCantiquesBody;

  /// No description provided for @userManualOfflineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get userManualOfflineTitle;

  /// No description provided for @userManualOfflineBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'onglet Hors ligne centralise tout ce que vous avez téléchargé.\n\nOrganisation\n• Deux sections : Prédications et Cantiques.\n• Chaque section affiche le nombre de fichiers et l\'espace utilisé.\n\nDans une section\n• Barre de recherche pour retrouver un titre.\n• Filtres par type de média (audio, vidéo, PDF…).\n• Touchez un fichier pour le lire dans le lecteur intégré.\n\nGestion\n• Supprimez un fichier via le menu ou une action longue.\n• Les téléchargements en cours apparaissent dans une bannière en haut de l\'app.\n• Partager l\'app envoie une invitation ; Partager le fichier envoie le média téléchargé.\n• Ouvrir dans l\'explorateur (Android) localise le fichier sur l\'appareil.'**
  String get userManualOfflineBody;

  /// No description provided for @userManualLibraryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get userManualLibraryTitle;

  /// No description provided for @userManualLibraryBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'onglet Bibliothèque donne accès aux ressources écrites Shekinah Publications.\n\nTrois rubriques\n• Bibliothèque — messages et ouvrages généraux.\n• Pépites d\'or — sélections courtes.\n• Publications — catalogue Shekinah Publications.\n\nLecture PDF\n• Touchez un ouvrage pour l\'ouvrir dans le navigateur intégré.\n• Téléchargez le PDF pour une lecture hors connexion.\n• Le lecteur intégré permet zoom, défilement, recherche dans le document et signets.\n• Les PDF téléchargés sont accessibles depuis Hors ligne.'**
  String get userManualLibraryBody;

  /// No description provided for @userManualSearchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get userManualSearchTitle;

  /// No description provided for @userManualSearchBody.
  ///
  /// In fr, this message translates to:
  /// **'La recherche globale est accessible depuis la barre en haut de l\'accueil.\n\nFonctionnement\n• Saisissez au moins un mot : la recherche démarre automatiquement après une courte pause.\n• Les résultats prédications et cantiques s\'affichent dans des sections distinctes.\n• Touchez un résultat pour ouvrir directement la fiche correspondante.\n\nConseils\n• Utilisez le nom du prédicateur, un mot du titre ou une ville pour les prédications.\n• Pour les cantiques, le numéro ou la catégorie fonctionnent aussi.\n• Sans connexion Internet, la recherche n\'est pas disponible.'**
  String get userManualSearchBody;

  /// No description provided for @userManualNotificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications, profil et réglages'**
  String get userManualNotificationsTitle;

  /// No description provided for @userManualNotificationsBody.
  ///
  /// In fr, this message translates to:
  /// **'Notifications\n• Cloche sur l\'accueil → liste des annonces (direct, communiqués, rappels).\n• Touchez une notification pour ouvrir le contenu concerné.\n• Marquez tout comme lu via le bouton en haut.\n\nProfil\n• Accessible depuis l\'accueil ou le menu Plus.\n• Connexion optionnelle pour personnaliser votre compte.\n• Raccourcis vers la bibliothèque et les requêtes de mariage.\n\nParamètres (menu Plus)\n• Thème : clair, sombre ou automatique (système).\n• Langue : français, anglais, espagnol, portugais, chinois.\n• Contact WhatsApp, politique de confidentialité, version de l\'app.'**
  String get userManualNotificationsBody;

  /// No description provided for @userManualPlusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Menu Plus'**
  String get userManualPlusTitle;

  /// No description provided for @userManualPlusBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'onglet Plus regroupe les contenus et services complémentaires :\n\n• Cultes — horaires réguliers et cultes spéciaux.\n• Notre Église — présentation, pasteur, églises sœurs.\n• Shekinah Publications — catalogue et liens éditoriaux.\n• Fondation Shekinah — œuvre missionnaire.\n• ECAMO — école et formation.\n• William Branham — ressources sur le prophète.\n• Documentaire / Scénette — vidéos thématiques.\n• Recueils de cantiques — partitions et recueils.\n• Dons — soutien financier en ligne.\n• Partager l\'app — invitation à télécharger Shekinah Tabernacle.\n• Notifications, Contact, Profil, Manuel, À propos, Confidentialité, Paramètres.'**
  String get userManualPlusBody;

  /// No description provided for @userManualTipsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Astuces'**
  String get userManualTipsTitle;

  /// No description provided for @userManualTipsBody.
  ///
  /// In fr, this message translates to:
  /// **'Économie de données\n• Préférez l\'audio des prédications : beaucoup plus léger que la vidéo.\n• En vidéo, choisissez « Économie de données (720p) ».\n• Téléchargez en Wi-Fi pour écouter ou lire plus tard sans consommer de forfait.\n\nDirect\n• Le mode audio consomme moins de données que la vidéo.\n• La fenêtre flottante permet de suivre le culte tout en consultant les archives.\n\nConfort\n• Mode sombre recommandé le soir ; mode clair en journée.\n• Changez la langue de l\'interface sans redémarrer l\'application.\n• En cas d\'erreur réseau, vérifiez d\'abord votre connexion avant de réessayer.'**
  String get userManualTipsBody;

  /// No description provided for @homeUpdateAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour disponible'**
  String get homeUpdateAvailable;

  /// No description provided for @homeUpdateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour requise'**
  String get homeUpdateRequired;

  /// No description provided for @homeUpdateAvailableHint.
  ///
  /// In fr, this message translates to:
  /// **'La version {version} est disponible sur le store.'**
  String homeUpdateAvailableHint(String version);

  /// No description provided for @homeUpdateNow.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get homeUpdateNow;

  /// No description provided for @homeUpdateLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get homeUpdateLater;

  /// No description provided for @audioStreamOutsideCultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Direct audio disponible'**
  String get audioStreamOutsideCultTitle;

  /// No description provided for @audioStreamOutsideCultHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez suivre le direct audio en dehors des heures de culte.'**
  String get audioStreamOutsideCultHint;

  /// No description provided for @audioStreamOutsideCultAction.
  ///
  /// In fr, this message translates to:
  /// **'Direct'**
  String get audioStreamOutsideCultAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
