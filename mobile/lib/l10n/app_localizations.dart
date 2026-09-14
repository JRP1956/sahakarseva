import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

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
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SahakarSeva'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Cooperative services, fair for everyone'**
  String get tagline;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @iAmCustomer.
  ///
  /// In en, this message translates to:
  /// **'I need a service'**
  String get iAmCustomer;

  /// No description provided for @iAmWorker.
  ///
  /// In en, this message translates to:
  /// **'I am a cooperative worker'**
  String get iAmWorker;

  /// No description provided for @society.
  ///
  /// In en, this message translates to:
  /// **'Cooperative society'**
  String get society;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @emergencyHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-assigns the best available worker · 1.5× price'**
  String get emergencyHint;

  /// No description provided for @myBookings.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get myBookings;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookings;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book {service}'**
  String bookService(String service);

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @pinLocation.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to set your location'**
  String get pinLocation;

  /// No description provided for @when.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get when;

  /// No description provided for @isEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency (on-demand, 1.5× price)'**
  String get isEmergency;

  /// No description provided for @youPay.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get youPay;

  /// No description provided for @workerGets.
  ///
  /// In en, this message translates to:
  /// **'Worker gets'**
  String get workerGets;

  /// No description provided for @cooperativeGets.
  ///
  /// In en, this message translates to:
  /// **'Cooperative fund'**
  String get cooperativeGets;

  /// No description provided for @findWorkers.
  ///
  /// In en, this message translates to:
  /// **'Find workers'**
  String get findWorkers;

  /// No description provided for @matchedWorkers.
  ///
  /// In en, this message translates to:
  /// **'Matched workers'**
  String get matchedWorkers;

  /// No description provided for @noWorkers.
  ///
  /// In en, this message translates to:
  /// **'No available workers within 10 km'**
  String get noWorkers;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String kmAway(String km);

  /// No description provided for @jobsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{n} jobs this week'**
  String jobsThisWeek(int n);

  /// No description provided for @matchScore.
  ///
  /// In en, this message translates to:
  /// **'Match score'**
  String get matchScore;

  /// No description provided for @insured.
  ///
  /// In en, this message translates to:
  /// **'Insured'**
  String get insured;

  /// No description provided for @accidentCover.
  ///
  /// In en, this message translates to:
  /// **'Accident cover'**
  String get accidentCover;

  /// No description provided for @coopMember.
  ///
  /// In en, this message translates to:
  /// **'Co-op member'**
  String get coopMember;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'Booking #{id}'**
  String booking(int id);

  /// No description provided for @status_requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get status_requested;

  /// No description provided for @status_assigned.
  ///
  /// In en, this message translates to:
  /// **'Worker assigned'**
  String get status_assigned;

  /// No description provided for @status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get status_accepted;

  /// No description provided for @status_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get status_in_progress;

  /// No description provided for @status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get status_completed;

  /// No description provided for @status_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get status_paid;

  /// No description provided for @status_rated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get status_rated;

  /// No description provided for @status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get status_cancelled;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String pay(String amount);

  /// No description provided for @paymentDemo.
  ///
  /// In en, this message translates to:
  /// **'Demo payment (Razorpay test mode)'**
  String get paymentDemo;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate this service'**
  String get rate;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @viewInvoice.
  ///
  /// In en, this message translates to:
  /// **'View invoice'**
  String get viewInvoice;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @newRequests.
  ///
  /// In en, this message translates to:
  /// **'New job requests'**
  String get newRequests;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No new requests. Stay available!'**
  String get noRequests;

  /// No description provided for @estimatedEarnings.
  ///
  /// In en, this message translates to:
  /// **'Estimated earnings'**
  String get estimatedEarnings;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start job'**
  String get start;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get complete;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @jobsDone.
  ///
  /// In en, this message translates to:
  /// **'{n} jobs'**
  String jobsDone(int n);

  /// No description provided for @welfare.
  ///
  /// In en, this message translates to:
  /// **'Welfare & membership'**
  String get welfare;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @certifications.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certifications;

  /// No description provided for @addCertification.
  ///
  /// In en, this message translates to:
  /// **'Add certification'**
  String get addCertification;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending verification'**
  String get pendingVerification;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'{n} years experience'**
  String experience(int n);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;
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
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
