// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'सहकार सेवा';

  @override
  String get tagline => 'सहकारी सेवाएँ, सबके लिए न्यायसंगत';

  @override
  String get phone => 'फ़ोन';

  @override
  String get password => 'पासवर्ड';

  @override
  String get name => 'नाम';

  @override
  String get signIn => 'साइन इन';

  @override
  String get createAccount => 'खाता बनाएँ';

  @override
  String get iAmCustomer => 'मुझे सेवा चाहिए';

  @override
  String get iAmWorker => 'मैं सहकारी कामगार हूँ';

  @override
  String get society => 'सहकारी समिति';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get services => 'सेवाएँ';

  @override
  String get emergency => 'आपातकाल';

  @override
  String get emergencyHint =>
      'सर्वश्रेष्ठ उपलब्ध कामगार स्वतः नियुक्त. 1.5x मूल्य';

  @override
  String get myBookings => 'मेरी बुकिंग';

  @override
  String get noBookings => 'अभी कोई बुकिंग नहीं';

  @override
  String bookService(String service) {
    return '$service बुक करें';
  }

  @override
  String get address => 'पता';

  @override
  String get pinLocation => 'स्थान सेट करने के लिए नक्शे पर टैप करें';

  @override
  String get when => 'कब';

  @override
  String get isEmergency => 'आपातकाल (तुरंत, 1.5× मूल्य)';

  @override
  String get youPay => 'आप देंगे';

  @override
  String get workerGets => 'कामगार को';

  @override
  String get cooperativeGets => 'सहकारी कोष';

  @override
  String get findWorkers => 'कामगार खोजें';

  @override
  String get matchedWorkers => 'मिले हुए कामगार';

  @override
  String get noWorkers => '10 किमी में कोई कामगार उपलब्ध नहीं';

  @override
  String get choose => 'चुनें';

  @override
  String kmAway(String km) {
    return '$km किमी दूर';
  }

  @override
  String jobsThisWeek(int n) {
    return 'इस हफ़्ते $n काम';
  }

  @override
  String get matchScore => 'मैच स्कोर';

  @override
  String get insured => 'बीमित';

  @override
  String get accidentCover => 'दुर्घटना कवर';

  @override
  String get coopMember => 'सहकारी सदस्य';

  @override
  String booking(int id) {
    return 'बुकिंग #$id';
  }

  @override
  String get status_requested => 'अनुरोधित';

  @override
  String get status_assigned => 'कामगार नियुक्त';

  @override
  String get status_accepted => 'स्वीकृत';

  @override
  String get status_in_progress => 'चल रहा है';

  @override
  String get status_completed => 'पूर्ण';

  @override
  String get status_paid => 'भुगतान हुआ';

  @override
  String get status_rated => 'रेटिंग दी';

  @override
  String get status_cancelled => 'रद्द';

  @override
  String pay(String amount) {
    return '$amount भुगतान करें';
  }

  @override
  String get paymentDemo => 'डेमो भुगतान (Razorpay टेस्ट मोड)';

  @override
  String get rate => 'सेवा को रेट करें';

  @override
  String get submit => 'जमा करें';

  @override
  String get cancelBooking => 'बुकिंग रद्द करें';

  @override
  String get viewInvoice => 'बिल देखें';

  @override
  String get jobs => 'काम';

  @override
  String get bookings => 'बुकिंग';

  @override
  String get earnings => 'कमाई';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get available => 'उपलब्ध';

  @override
  String get newRequests => 'नए काम के अनुरोध';

  @override
  String get noRequests => 'कोई नया अनुरोध नहीं। उपलब्ध रहें!';

  @override
  String get estimatedEarnings => 'अनुमानित कमाई';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get start => 'काम शुरू करें';

  @override
  String get complete => 'पूर्ण करें';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String jobsDone(int n) {
    return '$n काम';
  }

  @override
  String get welfare => 'कल्याण और सदस्यता';

  @override
  String get skills => 'कौशल';

  @override
  String get certifications => 'प्रमाणपत्र';

  @override
  String get addCertification => 'प्रमाणपत्र जोड़ें';

  @override
  String get verified => 'सत्यापित';

  @override
  String get pendingVerification => 'सत्यापन लंबित';

  @override
  String experience(int n) {
    return '$n वर्ष का अनुभव';
  }

  @override
  String get language => 'भाषा';

  @override
  String get save => 'सहेजें';

  @override
  String get error => 'कुछ गलत हो गया';
}
