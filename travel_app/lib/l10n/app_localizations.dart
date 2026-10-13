import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Travel AI'**
  String get appName;

  /// No description provided for @onboarding_title.
  ///
  /// In en, this message translates to:
  /// **'Go plan with Travel AI.'**
  String get onboarding_title;

  /// No description provided for @continue_with_email.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continue_with_email;

  /// No description provided for @sign_in_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in.'**
  String get sign_in_title;

  /// No description provided for @sign_in_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter all the information to sign in.'**
  String get sign_in_subtitle;

  /// No description provided for @email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_label;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get email_hint;

  /// No description provided for @email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_required;

  /// No description provided for @email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get email_invalid;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get password_hint;

  /// No description provided for @password_invalid.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_invalid;

  /// No description provided for @sign_in_button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sign_in_button;

  /// No description provided for @no_account_signup.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up!'**
  String get no_account_signup;

  /// No description provided for @sign_up_title.
  ///
  /// In en, this message translates to:
  /// **'Sign up.'**
  String get sign_up_title;

  /// No description provided for @sign_up_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter all the information to sign up.'**
  String get sign_up_subtitle;

  /// No description provided for @sign_up_button.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get sign_up_button;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in!'**
  String get already_have_account;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Google'**
  String get signInWithGoogle;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @travelHistory.
  ///
  /// In en, this message translates to:
  /// **'Travel History'**
  String get travelHistory;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @yourTrips.
  ///
  /// In en, this message translates to:
  /// **'Your Trips'**
  String get yourTrips;

  /// No description provided for @yourTravelHistory.
  ///
  /// In en, this message translates to:
  /// **'Your Travel History'**
  String get yourTravelHistory;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @noTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get noTripsYet;

  /// No description provided for @noTripsMessage.
  ///
  /// In en, this message translates to:
  /// **'Your travel history will appear here'**
  String get noTripsMessage;

  /// Unit for number of days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @budgetType.
  ///
  /// In en, this message translates to:
  /// **'Budget Type'**
  String get budgetType;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @tripType.
  ///
  /// In en, this message translates to:
  /// **'Trip Type'**
  String get tripType;

  /// No description provided for @adventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adventure;

  /// No description provided for @leisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get leisure;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @solo.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get solo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @themeModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark mode'**
  String get themeModeDescription;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageDescription;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterNameError;

  /// No description provided for @enterEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmailError;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmailError;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacySecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get privacySecurityDescription;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure notification preferences'**
  String get notificationsDescription;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @helpSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Get help with the app'**
  String get helpSupportDescription;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get aboutDescription;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logOutDescription;

  /// No description provided for @logOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logOutConfirmation;

  /// No description provided for @logOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logOutSuccess;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get networkError;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPassword;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get tryAgain;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @tripOverview.
  ///
  /// In en, this message translates to:
  /// **'Trip Overview'**
  String get tripOverview;

  /// No description provided for @itinerary.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get itinerary;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// Day number in itinerary
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @searchDestination.
  ///
  /// In en, this message translates to:
  /// **'Search destination...'**
  String get searchDestination;

  /// No description provided for @enterDestination.
  ///
  /// In en, this message translates to:
  /// **'Enter destination'**
  String get enterDestination;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectBudget.
  ///
  /// In en, this message translates to:
  /// **'Select budget'**
  String get selectBudget;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note...'**
  String get addNote;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @word_with.
  ///
  /// In en, this message translates to:
  /// **'with'**
  String get word_with;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @word_in.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get word_in;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @word_for.
  ///
  /// In en, this message translates to:
  /// **'for'**
  String get word_for;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @tripDetail.
  ///
  /// In en, this message translates to:
  /// **'Trip Detail'**
  String get tripDetail;

  /// No description provided for @localTransport.
  ///
  /// In en, this message translates to:
  /// **'Local Transport'**
  String get localTransport;

  /// No description provided for @noInfoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No information available'**
  String get noInfoAvailable;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image Unavailable'**
  String get imageUnavailable;

  /// No description provided for @noItineraryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Itinerary Available'**
  String get noItineraryAvailable;

  /// No description provided for @noTripFound.
  ///
  /// In en, this message translates to:
  /// **'No Trip Found'**
  String get noTripFound;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @dailyItinerary.
  ///
  /// In en, this message translates to:
  /// **'Daily Itinerary'**
  String get dailyItinerary;

  /// No description provided for @accommodationSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Accommodation Suggestions'**
  String get accommodationSuggestions;

  /// No description provided for @transportationDetails.
  ///
  /// In en, this message translates to:
  /// **'Transportation Details'**
  String get transportationDetails;

  /// No description provided for @failedDeleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete trip'**
  String get failedDeleteTrip;

  /// No description provided for @deleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Delete Trip?'**
  String get deleteTrip;

  /// No description provided for @tripDeleted.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted successfully'**
  String get tripDeleted;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your trip to'**
  String get deleteConfirmation;

  /// No description provided for @actionUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionUndone;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete trip'**
  String get deleteError;

  /// No description provided for @tripMayHaveBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'This trip may have been deleted'**
  String get tripMayHaveBeenDeleted;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @noTipsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tips available'**
  String get noTipsAvailable;

  /// No description provided for @weatherForecast.
  ///
  /// In en, this message translates to:
  /// **'Weather Forecast'**
  String get weatherForecast;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @kmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// No description provided for @noWeatherData.
  ///
  /// In en, this message translates to:
  /// **'No weather data available'**
  String get noWeatherData;

  /// No description provided for @routeMap.
  ///
  /// In en, this message translates to:
  /// **'Route Map'**
  String get routeMap;

  /// No description provided for @estimatedBudget.
  ///
  /// In en, this message translates to:
  /// **'Estimated Budget'**
  String get estimatedBudget;

  /// No description provided for @weatherIn.
  ///
  /// In en, this message translates to:
  /// **'Weather in'**
  String get weatherIn;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels Like'**
  String get feelsLike;

  /// No description provided for @windSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get windSpeed;

  /// No description provided for @tempMin.
  ///
  /// In en, this message translates to:
  /// **'Temp Min'**
  String get tempMin;

  /// No description provided for @tempMax.
  ///
  /// In en, this message translates to:
  /// **'Temp Max'**
  String get tempMax;

  /// No description provided for @ms.
  ///
  /// In en, this message translates to:
  /// **'m/s'**
  String get ms;

  /// No description provided for @celsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsius;

  /// No description provided for @planYourTrip.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Trip'**
  String get planYourTrip;

  /// No description provided for @creatingPerfectTrip.
  ///
  /// In en, this message translates to:
  /// **'Creating your perfect trip...'**
  String get creatingPerfectTrip;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @datesAndBudget.
  ///
  /// In en, this message translates to:
  /// **'Dates & Budget'**
  String get datesAndBudget;

  /// No description provided for @travelDetails.
  ///
  /// In en, this message translates to:
  /// **'Travel Details'**
  String get travelDetails;

  /// No description provided for @validationEnterDestination.
  ///
  /// In en, this message translates to:
  /// **'Please enter a destination'**
  String get validationEnterDestination;

  /// No description provided for @validationSelectTripType.
  ///
  /// In en, this message translates to:
  /// **'Please select a trip type'**
  String get validationSelectTripType;

  /// No description provided for @validationSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a start date'**
  String get validationSelectStartDate;

  /// No description provided for @validationSelectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Please select an end date'**
  String get validationSelectEndDate;

  /// No description provided for @validationEnterBudget.
  ///
  /// In en, this message translates to:
  /// **'Please enter your budget'**
  String get validationEnterBudget;

  /// No description provided for @validationSelectInterest.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one interest'**
  String get validationSelectInterest;

  /// No description provided for @validationSelectCompanion.
  ///
  /// In en, this message translates to:
  /// **'Please select your travel companion'**
  String get validationSelectCompanion;

  /// No description provided for @validationSelectAccommodation.
  ///
  /// In en, this message translates to:
  /// **'Please select accommodation type'**
  String get validationSelectAccommodation;

  /// No description provided for @validationSelectTransport.
  ///
  /// In en, this message translates to:
  /// **'Please select transport preference'**
  String get validationSelectTransport;

  /// No description provided for @validationSelectPace.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred pace'**
  String get validationSelectPace;

  /// No description provided for @validationSelectFood.
  ///
  /// In en, this message translates to:
  /// **'Please select food preference'**
  String get validationSelectFood;

  /// No description provided for @validationCompleteAll.
  ///
  /// In en, this message translates to:
  /// **'Please complete all fields'**
  String get validationCompleteAll;

  /// No description provided for @failedCreateTrip.
  ///
  /// In en, this message translates to:
  /// **'Failed to create trip'**
  String get failedCreateTrip;

  /// No description provided for @createTrip.
  ///
  /// In en, this message translates to:
  /// **'Create Trip'**
  String get createTrip;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @whenHowMuch.
  ///
  /// In en, this message translates to:
  /// **'When & How Much?'**
  String get whenHowMuch;

  /// No description provided for @whenHowMuchDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your dates and budget'**
  String get whenHowMuchDescription;

  /// No description provided for @travelDates.
  ///
  /// In en, this message translates to:
  /// **'Travel dates'**
  String get travelDates;

  /// No description provided for @pleaseSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a start date first'**
  String get pleaseSelectStartDate;

  /// No description provided for @pleaseSelectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Please select an end date'**
  String get pleaseSelectEndDate;

  /// No description provided for @destination_step_title.
  ///
  /// In en, this message translates to:
  /// **'Where are you headed?'**
  String get destination_step_title;

  /// No description provided for @destination_step_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your destination'**
  String get destination_step_subtitle;

  /// No description provided for @destination_label.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination_label;

  /// No description provided for @destination_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Paris, France'**
  String get destination_hint;

  /// No description provided for @starting_from_label.
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get starting_from_label;

  /// No description provided for @starting_from_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., New York, USA'**
  String get starting_from_hint;

  /// No description provided for @trip_type_label.
  ///
  /// In en, this message translates to:
  /// **'Type of trip'**
  String get trip_type_label;

  /// No description provided for @personal_preferences_title.
  ///
  /// In en, this message translates to:
  /// **'Your Preferences'**
  String get personal_preferences_title;

  /// No description provided for @personal_preferences_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your trip'**
  String get personal_preferences_subtitle;

  /// No description provided for @traveling_with.
  ///
  /// In en, this message translates to:
  /// **'Traveling with'**
  String get traveling_with;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @select_all_that_apply.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get select_all_that_apply;

  /// No description provided for @interest_nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get interest_nature;

  /// No description provided for @interest_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get interest_history;

  /// No description provided for @interest_adventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get interest_adventure;

  /// No description provided for @interest_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get interest_shopping;

  /// No description provided for @interest_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get interest_food;

  /// No description provided for @interest_art.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get interest_art;

  /// No description provided for @companion_solo.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get companion_solo;

  /// No description provided for @companion_partner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get companion_partner;

  /// No description provided for @companion_family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get companion_family;

  /// No description provided for @companion_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get companion_friends;

  /// No description provided for @travel_preferences_title.
  ///
  /// In en, this message translates to:
  /// **'Travel Style'**
  String get travel_preferences_title;

  /// No description provided for @travel_preferences_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Finalize your preferences'**
  String get travel_preferences_subtitle;

  /// No description provided for @accommodation.
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get accommodation;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @trip_pace.
  ///
  /// In en, this message translates to:
  /// **'Trip Pace'**
  String get trip_pace;

  /// No description provided for @food_preference.
  ///
  /// In en, this message translates to:
  /// **'Food Preference'**
  String get food_preference;

  /// No description provided for @accommodation_hotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get accommodation_hotel;

  /// No description provided for @accommodation_hostel.
  ///
  /// In en, this message translates to:
  /// **'Hostel'**
  String get accommodation_hostel;

  /// No description provided for @accommodation_airbnb.
  ///
  /// In en, this message translates to:
  /// **'Airbnb'**
  String get accommodation_airbnb;

  /// No description provided for @accommodation_resort.
  ///
  /// In en, this message translates to:
  /// **'Resort'**
  String get accommodation_resort;

  /// No description provided for @accommodation_camping.
  ///
  /// In en, this message translates to:
  /// **'Camping'**
  String get accommodation_camping;

  /// No description provided for @transport_public.
  ///
  /// In en, this message translates to:
  /// **'Public Transport'**
  String get transport_public;

  /// No description provided for @transport_rental.
  ///
  /// In en, this message translates to:
  /// **'Rental Car'**
  String get transport_rental;

  /// No description provided for @transport_taxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi / Uber'**
  String get transport_taxi;

  /// No description provided for @transport_walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get transport_walking;

  /// No description provided for @transport_bicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get transport_bicycle;

  /// No description provided for @pace_relaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get pace_relaxed;

  /// No description provided for @pace_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get pace_moderate;

  /// No description provided for @pace_fast.
  ///
  /// In en, this message translates to:
  /// **'Fast-paced'**
  String get pace_fast;

  /// No description provided for @food_local.
  ///
  /// In en, this message translates to:
  /// **'Local Cuisine'**
  String get food_local;

  /// No description provided for @food_vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get food_vegetarian;

  /// No description provided for @food_vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get food_vegan;

  /// No description provided for @food_fast_food.
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get food_fast_food;

  /// No description provided for @food_fine_dining.
  ///
  /// In en, this message translates to:
  /// **'Fine Dining'**
  String get food_fine_dining;

  /// No description provided for @search_trips_hint.
  ///
  /// In en, this message translates to:
  /// **'Search trips'**
  String get search_trips_hint;

  /// No description provided for @search_initial_message.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search your trips'**
  String get search_initial_message;

  /// No description provided for @search_no_results.
  ///
  /// In en, this message translates to:
  /// **'No trips found for \"{query}\"'**
  String search_no_results(String query);

  /// No description provided for @mark_as_visited.
  ///
  /// In en, this message translates to:
  /// **'Mark as visited'**
  String get mark_as_visited;

  /// No description provided for @visited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visited;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @tripDifferentLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip language mismatch'**
  String get tripDifferentLanguageTitle;

  /// No description provided for @tripDifferentLanguageMessage.
  ///
  /// In en, this message translates to:
  /// **'This trip was generated in {oldLang}. Would you like to regenerate it in {newLang}?'**
  String tripDifferentLanguageMessage(Object newLang, Object oldLang);

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @keepOriginal.
  ///
  /// In en, this message translates to:
  /// **'Keep original'**
  String get keepOriginal;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get filterFavorite;

  /// No description provided for @tripsSummary.
  ///
  /// In en, this message translates to:
  /// **'Trips Summary'**
  String get tripsSummary;

  /// No description provided for @tripTypeAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get tripTypeAdventure;

  /// No description provided for @tripTypeRelaxation.
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get tripTypeRelaxation;

  /// No description provided for @tripTypeCultural.
  ///
  /// In en, this message translates to:
  /// **'Cultural'**
  String get tripTypeCultural;

  /// No description provided for @tripTypeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get tripTypeBusiness;

  /// No description provided for @tripTypeRomantic.
  ///
  /// In en, this message translates to:
  /// **'Romantic'**
  String get tripTypeRomantic;

  /// No description provided for @tripTypeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get tripTypeFamily;

  /// No description provided for @trending_destinations_title.
  ///
  /// In en, this message translates to:
  /// **'🔥 Trending Destinations'**
  String get trending_destinations_title;

  /// No description provided for @personalized_destinations_title.
  ///
  /// In en, this message translates to:
  /// **'✨ Just For You'**
  String get personalized_destinations_title;

  /// No description provided for @you_might_like_title.
  ///
  /// In en, this message translates to:
  /// **'🌍 You Might Like'**
  String get you_might_like_title;

  /// No description provided for @greeting_message.
  ///
  /// In en, this message translates to:
  /// **'Hello, where are we going today? 👋'**
  String get greeting_message;

  /// No description provided for @no_recommendations_found.
  ///
  /// In en, this message translates to:
  /// **'No recommendations found'**
  String get no_recommendations_found;

  /// No description provided for @clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clear_filters;

  /// No description provided for @search_destination_hint_discovery.
  ///
  /// In en, this message translates to:
  /// **'Search for your dream destination...'**
  String get search_destination_hint_discovery;

  /// No description provided for @auth_welcome_back_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get auth_welcome_back_title;

  /// No description provided for @auth_welcome_back_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue exploring the world with Trekko.'**
  String get auth_welcome_back_subtitle;

  /// No description provided for @auth_forgot_password_question.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password_question;

  /// No description provided for @auth_or_divider.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get auth_or_divider;

  /// No description provided for @auth_continue_with_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_continue_with_google;

  /// No description provided for @auth_no_account_yet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_no_account_yet;

  /// No description provided for @auth_sign_up_now.
  ///
  /// In en, this message translates to:
  /// **'Sign up now'**
  String get auth_sign_up_now;

  /// No description provided for @add_must_visit_title.
  ///
  /// In en, this message translates to:
  /// **'Add Required Places (Optional)'**
  String get add_must_visit_title;

  /// No description provided for @places_selected.
  ///
  /// In en, this message translates to:
  /// **'{count} places selected'**
  String places_selected(int count);

  /// No description provided for @error_select_destination_first.
  ///
  /// In en, this message translates to:
  /// **'Please select a destination in step 1 before selecting places'**
  String get error_select_destination_first;

  /// No description provided for @select_must_visit_title.
  ///
  /// In en, this message translates to:
  /// **'Select Required Places'**
  String get select_must_visit_title;

  /// No description provided for @at_destination_context.
  ///
  /// In en, this message translates to:
  /// **'At {destination}'**
  String at_destination_context(String destination);

  /// No description provided for @complete_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get complete_profile_title;

  /// No description provided for @complete_profile_greeting.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get complete_profile_greeting;

  /// No description provided for @complete_profile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'This information will help us personalize your travel experience.'**
  String get complete_profile_subtitle;

  /// No description provided for @dob_label.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dob_label;

  /// No description provided for @gender_label.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender_label;

  /// No description provided for @country_label.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country_label;

  /// No description provided for @occupation_label.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation_label;

  /// No description provided for @hobbies_title.
  ///
  /// In en, this message translates to:
  /// **'Hobbies & Passions'**
  String get hobbies_title;

  /// No description provided for @hobbies_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select topics you\'re interested in so we can suggest suitable destinations.'**
  String get hobbies_subtitle;

  /// No description provided for @gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// No description provided for @gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// No description provided for @gender_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get gender_other;

  /// No description provided for @finish_button.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish_button;

  /// No description provided for @select_dob_error.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get select_dob_error;

  /// No description provided for @select_gender_error.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get select_gender_error;

  /// No description provided for @session_not_found_error.
  ///
  /// In en, this message translates to:
  /// **'Session not found. Please log in again.'**
  String get session_not_found_error;

  /// No description provided for @hobby_beach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get hobby_beach;

  /// No description provided for @hobby_mountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get hobby_mountain;

  /// No description provided for @hobby_culture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get hobby_culture;

  /// No description provided for @hobby_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get hobby_food;

  /// No description provided for @hobby_relaxation.
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get hobby_relaxation;

  /// No description provided for @hobby_discovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get hobby_discovery;

  /// No description provided for @hobby_photography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get hobby_photography;

  /// No description provided for @hobby_climbing.
  ///
  /// In en, this message translates to:
  /// **'Climbing'**
  String get hobby_climbing;

  /// No description provided for @hobby_camping.
  ///
  /// In en, this message translates to:
  /// **'Camping'**
  String get hobby_camping;

  /// No description provided for @share_with.
  ///
  /// In en, this message translates to:
  /// **'Share with'**
  String get share_with;

  /// No description provided for @not_interested.
  ///
  /// In en, this message translates to:
  /// **'Not interested'**
  String get not_interested;

  /// No description provided for @link_copied.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get link_copied;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @thanks_feedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thanks_feedback;

  /// No description provided for @sharing_via.
  ///
  /// In en, this message translates to:
  /// **'Sharing \"{destination}\" via {platform}...'**
  String sharing_via(String destination, String platform);

  /// No description provided for @special_requirements_label.
  ///
  /// In en, this message translates to:
  /// **'Special Requirements (Optional)'**
  String get special_requirements_label;

  /// No description provided for @special_requirements_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vegetarian, elderly traveling along...'**
  String get special_requirements_hint;

  /// No description provided for @add_must_visit_label.
  ///
  /// In en, this message translates to:
  /// **'Add must-visit places (Optional)'**
  String get add_must_visit_label;

  /// No description provided for @clear_all_selection.
  ///
  /// In en, this message translates to:
  /// **'Clear all selections'**
  String get clear_all_selection;

  /// No description provided for @confirm_with_count.
  ///
  /// In en, this message translates to:
  /// **'Confirm ({count})'**
  String confirm_with_count(int count);

  /// No description provided for @chat_error.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I\'m having trouble. Please try again later.'**
  String get chat_error;

  /// No description provided for @chat_assistant_greeting.
  ///
  /// In en, this message translates to:
  /// **'Hello there! 👋'**
  String get chat_assistant_greeting;

  /// No description provided for @chat_assistant_subtitle.
  ///
  /// In en, this message translates to:
  /// **'I\'ll help you plan your trip to {destination}. Feel free to ask me anything!'**
  String chat_assistant_subtitle(String destination);

  /// No description provided for @chat_suggestion_itinerary.
  ///
  /// In en, this message translates to:
  /// **'Suggest itinerary'**
  String get chat_suggestion_itinerary;

  /// No description provided for @chat_suggestion_places.
  ///
  /// In en, this message translates to:
  /// **'Famous places'**
  String get chat_suggestion_places;

  /// No description provided for @chat_suggestion_tips.
  ///
  /// In en, this message translates to:
  /// **'Travel tips'**
  String get chat_suggestion_tips;

  /// No description provided for @map_under_development.
  ///
  /// In en, this message translates to:
  /// **'Map is under development'**
  String get map_under_development;

  /// No description provided for @view_map.
  ///
  /// In en, this message translates to:
  /// **'View map'**
  String get view_map;

  /// No description provided for @days_count.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days_count(int count);

  /// No description provided for @day_label.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String day_label(int day);

  /// No description provided for @about_this_place.
  ///
  /// In en, this message translates to:
  /// **'About this place'**
  String get about_this_place;

  /// No description provided for @show_less.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get show_less;

  /// No description provided for @read_more.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get read_more;

  /// No description provided for @top_activities.
  ///
  /// In en, this message translates to:
  /// **'Top activities'**
  String get top_activities;

  /// No description provided for @nearby_places.
  ///
  /// In en, this message translates to:
  /// **'📍 Nearby Places'**
  String get nearby_places;

  /// No description provided for @plan_itinerary_now.
  ///
  /// In en, this message translates to:
  /// **'Plan itinerary now'**
  String get plan_itinerary_now;

  /// No description provided for @login_to_favorite_error.
  ///
  /// In en, this message translates to:
  /// **'Please login to favorite!'**
  String get login_to_favorite_error;

  /// No description provided for @community_reviews.
  ///
  /// In en, this message translates to:
  /// **'Community Reviews'**
  String get community_reviews;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @your_rating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get your_rating;

  /// No description provided for @share_experience_hint.
  ///
  /// In en, this message translates to:
  /// **'Share your real experience about this place.'**
  String get share_experience_hint;

  /// No description provided for @enter_review_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your review...'**
  String get enter_review_hint;

  /// No description provided for @update_review.
  ///
  /// In en, this message translates to:
  /// **'Update review'**
  String get update_review;

  /// No description provided for @send_review.
  ///
  /// In en, this message translates to:
  /// **'Send review'**
  String get send_review;

  /// No description provided for @no_reviews_yet.
  ///
  /// In en, this message translates to:
  /// **'No reviews for this place yet. Be the first to review!'**
  String get no_reviews_yet;

  /// No description provided for @just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get just_now;

  /// No description provided for @anonymous_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get anonymous_user;

  /// No description provided for @flexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexible;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @ideal.
  ///
  /// In en, this message translates to:
  /// **'Ideal'**
  String get ideal;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @advanced_filters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advanced_filters;

  /// No description provided for @place_categories.
  ///
  /// In en, this message translates to:
  /// **'Place Categories'**
  String get place_categories;

  /// No description provided for @budget_level_title.
  ///
  /// In en, this message translates to:
  /// **'Budget Level'**
  String get budget_level_title;

  /// No description provided for @suitable_for_title.
  ///
  /// In en, this message translates to:
  /// **'Suitable For'**
  String get suitable_for_title;

  /// No description provided for @travel_season_title.
  ///
  /// In en, this message translates to:
  /// **'Travel Season'**
  String get travel_season_title;

  /// No description provided for @max_stay.
  ///
  /// In en, this message translates to:
  /// **'Max Stay'**
  String get max_stay;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cat_beach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get cat_beach;

  /// No description provided for @cat_mountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get cat_mountain;

  /// No description provided for @cat_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cat_city;

  /// No description provided for @cat_culture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get cat_culture;

  /// No description provided for @budget_cheap.
  ///
  /// In en, this message translates to:
  /// **'Cheap'**
  String get budget_cheap;

  /// No description provided for @budget_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get budget_medium;

  /// No description provided for @budget_luxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get budget_luxury;

  /// No description provided for @budget_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get budget_total;

  /// No description provided for @budget_per_day.
  ///
  /// In en, this message translates to:
  /// **'Per Day'**
  String get budget_per_day;

  /// No description provided for @couple.
  ///
  /// In en, this message translates to:
  /// **'Couple'**
  String get couple;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @spring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get spring;

  /// No description provided for @summer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get summer;

  /// No description provided for @autumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get autumn;

  /// No description provided for @winter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get winter;

  /// No description provided for @clear_filters_short.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear_filters_short;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'TRENDING'**
  String get trending;

  /// No description provided for @likes_count.
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String likes_count(int count);

  /// No description provided for @cat_resort.
  ///
  /// In en, this message translates to:
  /// **'Resort'**
  String get cat_resort;

  /// No description provided for @search_error.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String search_error(Object error);

  /// No description provided for @added_to_favorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get added_to_favorites;

  /// No description provided for @removed_from_favorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removed_from_favorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorite trips yet'**
  String get noFavoritesYet;

  /// No description provided for @noTripsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No trips found for this month'**
  String get noTripsThisMonth;

  /// No description provided for @noTripsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'No trips found for last month'**
  String get noTripsLastMonth;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @trip_history_title.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get trip_history_title;

  /// No description provided for @tab_visited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get tab_visited;

  /// No description provided for @tab_recent.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get tab_recent;

  /// No description provided for @no_visited_trips_title.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t completed any trips yet'**
  String get no_visited_trips_title;

  /// No description provided for @no_visited_trips_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new journey and mark it as completed to save your memories here!'**
  String get no_visited_trips_subtitle;

  /// No description provided for @no_recent_views_title.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t viewed any places recently'**
  String get no_recent_views_title;

  /// No description provided for @no_recent_views_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover exciting destinations and they will appear here.'**
  String get no_recent_views_subtitle;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String error_occurred(String error);

  /// No description provided for @error_loading_data.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get error_loading_data;

  /// No description provided for @please_try_again.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get please_try_again;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @mark_all_read_success.
  ///
  /// In en, this message translates to:
  /// **'Marked all notifications as read'**
  String get mark_all_read_success;

  /// No description provided for @update_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during update'**
  String get update_error;

  /// No description provided for @please_login.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get please_login;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @mark_all_read_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get mark_all_read_tooltip;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all;

  /// No description provided for @filter_latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get filter_latest;

  /// No description provided for @filter_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filter_unread;

  /// No description provided for @no_notifications_found.
  ///
  /// In en, this message translates to:
  /// **'No matching notifications'**
  String get no_notifications_found;

  /// No description provided for @event_detail_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap to view festival details.'**
  String get event_detail_hint;

  /// No description provided for @trip_ready_hint.
  ///
  /// In en, this message translates to:
  /// **'Get ready for your trip!'**
  String get trip_ready_hint;

  /// No description provided for @group_update_hint.
  ///
  /// In en, this message translates to:
  /// **'View new updates from the group.'**
  String get group_update_hint;

  /// No description provided for @view_detail_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details.'**
  String get view_detail_hint;

  /// No description provided for @tools_title.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools_title;

  /// No description provided for @currency_converter_title.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get currency_converter_title;

  /// No description provided for @currency_converter_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View exchange rates and convert currency in real-time'**
  String get currency_converter_subtitle;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @bio_label.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio_label;

  /// No description provided for @bio_hint.
  ///
  /// In en, this message translates to:
  /// **'Share a little about yourself...'**
  String get bio_hint;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @change_password_success.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get change_password_success;

  /// No description provided for @old_password.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get old_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirm_new_password;

  /// No description provided for @password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_mismatch;

  /// No description provided for @update_password.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get update_password;

  /// No description provided for @password_min_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_min_length;

  /// No description provided for @privacy_security_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacy_security_title;

  /// No description provided for @privacy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy_title;

  /// No description provided for @show_public_profile.
  ///
  /// In en, this message translates to:
  /// **'Show Public Profile'**
  String get show_public_profile;

  /// No description provided for @show_public_profile_sub.
  ///
  /// In en, this message translates to:
  /// **'Allow others to view your completed trips.'**
  String get show_public_profile_sub;

  /// No description provided for @search_by_email_phone.
  ///
  /// In en, this message translates to:
  /// **'Search by Email/Phone'**
  String get search_by_email_phone;

  /// No description provided for @search_by_email_phone_sub.
  ///
  /// In en, this message translates to:
  /// **'Others can find you via email or phone number.'**
  String get search_by_email_phone_sub;

  /// No description provided for @account_security.
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get account_security;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @confirm_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion?'**
  String get confirm_delete_account;

  /// No description provided for @confirm_delete_account_sub.
  ///
  /// In en, this message translates to:
  /// **'All your trip data, photos, and settings will be permanently deleted. This action cannot be undone.'**
  String get confirm_delete_account_sub;

  /// No description provided for @delete_request_sent.
  ///
  /// In en, this message translates to:
  /// **'Request sent. We will process it within 24h.'**
  String get delete_request_sent;

  /// No description provided for @delete_permanently.
  ///
  /// In en, this message translates to:
  /// **'DELETE PERMANENTLY'**
  String get delete_permanently;

  /// No description provided for @notification_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notification_settings_title;

  /// No description provided for @trip_activity.
  ///
  /// In en, this message translates to:
  /// **'Trip Activity'**
  String get trip_activity;

  /// No description provided for @upcoming_trip_reminder.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Trip Reminders'**
  String get upcoming_trip_reminder;

  /// No description provided for @upcoming_trip_reminder_sub.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for your scheduled trips.'**
  String get upcoming_trip_reminder_sub;

  /// No description provided for @group_updates.
  ///
  /// In en, this message translates to:
  /// **'Group Updates'**
  String get group_updates;

  /// No description provided for @group_updates_sub.
  ///
  /// In en, this message translates to:
  /// **'Get notified when there are new members or messages in the group.'**
  String get group_updates_sub;

  /// No description provided for @news_events.
  ///
  /// In en, this message translates to:
  /// **'News & Events'**
  String get news_events;

  /// No description provided for @event_festival_notifications.
  ///
  /// In en, this message translates to:
  /// **'Event & Festival Notifications'**
  String get event_festival_notifications;

  /// No description provided for @event_festival_notifications_sub.
  ///
  /// In en, this message translates to:
  /// **'Stay updated on upcoming travel festivals.'**
  String get event_festival_notifications_sub;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about_title;

  /// No description provided for @ai_travel_assistant.
  ///
  /// In en, this message translates to:
  /// **'AI Travel Assistant'**
  String get ai_travel_assistant;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @developed_with_passion.
  ///
  /// In en, this message translates to:
  /// **'Developed with a passion for travel and the power of artificial intelligence.'**
  String get developed_with_passion;

  /// No description provided for @terms_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms_conditions;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @loading_data.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loading_data;

  /// No description provided for @help_support_title.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support_title;

  /// No description provided for @faq_title.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions (FAQ)'**
  String get faq_title;

  /// No description provided for @faq_1_q.
  ///
  /// In en, this message translates to:
  /// **'How to create a new trip?'**
  String get faq_1_q;

  /// No description provided for @faq_1_a.
  ///
  /// In en, this message translates to:
  /// **'On the home screen, tap the \'+\' button in the navigation bar or the \'Plan\' button to start creating an itinerary.'**
  String get faq_1_a;

  /// No description provided for @faq_2_q.
  ///
  /// In en, this message translates to:
  /// **'How to mark a trip as completed?'**
  String get faq_2_q;

  /// No description provided for @faq_2_a.
  ///
  /// In en, this message translates to:
  /// **'Go to the trip details, tap the Menu icon (three dots) and select \'Complete trip\'.'**
  String get faq_2_a;

  /// No description provided for @faq_3_q.
  ///
  /// In en, this message translates to:
  /// **'How can I invite friends to join a trip?'**
  String get faq_3_q;

  /// No description provided for @faq_3_a.
  ///
  /// In en, this message translates to:
  /// **'In the trip details screen, tap the \'Add member\' icon and enter your friend\'s email.'**
  String get faq_3_a;

  /// No description provided for @still_need_help.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get still_need_help;

  /// No description provided for @contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact_support;

  /// No description provided for @send_email.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get send_email;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get joinGroup;

  /// No description provided for @joinGroupDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter an invite code to join a trip with your friends'**
  String get joinGroupDescription;

  /// No description provided for @notifUpcomingTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Trip!'**
  String get notifUpcomingTripTitle;

  /// No description provided for @notifNewMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'New Member Joined'**
  String get notifNewMemberTitle;

  /// No description provided for @notifWeatherAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather Alert at {destination}'**
  String notifWeatherAlertTitle(String destination);

  /// No description provided for @notifUpcomingTripBody.
  ///
  /// In en, this message translates to:
  /// **'You have a trip to {destination} starting soon. Don\'t forget to pack!'**
  String notifUpcomingTripBody(String destination);

  /// No description provided for @notifNewMemberBody.
  ///
  /// In en, this message translates to:
  /// **'<b>{memberName}</b> has joined the trip to <b>{destination}</b>.'**
  String notifNewMemberBody(String memberName, String destination);

  /// No description provided for @notifFestivalDanangTitle.
  ///
  /// In en, this message translates to:
  /// **'Da Nang International Fireworks Festival'**
  String get notifFestivalDanangTitle;

  /// No description provided for @notifFestivalHoiAnTitle.
  ///
  /// In en, this message translates to:
  /// **'Hoi An Lantern Festival'**
  String get notifFestivalHoiAnTitle;

  /// No description provided for @notifFestivalDaLatTitle.
  ///
  /// In en, this message translates to:
  /// **'Da Lat Flower Festival'**
  String get notifFestivalDaLatTitle;

  /// No description provided for @notifFestivalNhaTrangTitle.
  ///
  /// In en, this message translates to:
  /// **'Nha Trang Sea Festival'**
  String get notifFestivalNhaTrangTitle;

  /// No description provided for @notifFestivalDanangBody.
  ///
  /// In en, this message translates to:
  /// **'The international fireworks display is about to light up the Da Nang sky. Are you ready?'**
  String get notifFestivalDanangBody;

  /// No description provided for @notifFestivalHoiAnBody.
  ///
  /// In en, this message translates to:
  /// **'Hoi An ancient town is about to sparkle with lanterns. A great check-in opportunity!'**
  String get notifFestivalHoiAnBody;

  /// No description provided for @notifFestivalDaLatBody.
  ///
  /// In en, this message translates to:
  /// **'The city of thousands of flowers is about to enter its biggest festival of the year. Plan now!'**
  String get notifFestivalDaLatBody;

  /// No description provided for @notifFestivalNhaTrangBody.
  ///
  /// In en, this message translates to:
  /// **'Nha Trang is calling with a series of exciting sea events. Don\'t miss it!'**
  String get notifFestivalNhaTrangBody;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
