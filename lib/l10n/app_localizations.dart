import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'MedAI',
      'app_subtitle': 'Your Intelligent Medical Assistant',
      'get_started': 'Get Started',
      'home': 'Home',
      'medicine_programs': 'Medicine Programs',
      'ocr_scan': 'OCR Scan',
      'ask_ai': 'Ask AI',
      'api_key_management': 'API Key Management',
      'create_program': 'Create Program',
      'program_name': 'Program Name',
      'program_description': 'Description (Optional)',
      'schedule': 'Schedule',
      'schedule_days': 'Schedule Days',
      'reminders': 'Reminders',
      'reminder_times': 'Reminder Times',
      'add_time': 'Add',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'active': 'Active',
      'inactive': 'Inactive',
      'active_programs': 'Active Programs',
      'inactive_programs': 'Inactive Programs',
      'no_programs': 'No medicine programs yet',
      'create_first_program':
          'Create your first program by tapping the + button',
      'enter_program_name': 'Please enter a program name',
      'select_one_day': 'Please select at least one day',
      'add_one_reminder': 'Please add at least one reminder time',
      'time_already_added': 'This time is already added',
      'program_created': 'Program created successfully',
      'program_updated': 'Program updated successfully',
      'program_deleted': 'Program deleted',
      'delete_program_confirmation': 'Delete Program',
      'delete_program_message': 'Are you sure you want to delete this program?',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'your_question': 'Your Question',
      'ask_anything': 'Ask anything...',
      'ask': 'Ask AI',
      'processing': 'Processing...',
      'select_ai_service': 'Select AI Service',
      'no_responses': 'No responses yet. Ask a question to get started!',
      'enter_question': 'Please enter your question',
      'just_now': 'Just now',
      'ago': 'ago',
      'set_api_key_first': 'Please set your API key first',
      'set_api_key': 'Set API Key',
      'general_api_key': 'General API Key',
      'chatgpt_api_key': 'ChatGPT API Key',
      'mistral_api_key': 'Mistral API Key',
      'gemini_api_key': 'Gemini API Key',
      'new_api_key': 'New API Key',
      'enter_api_key': 'Enter your API key',
      'clear_api_key': 'Clear API Key',
      'clear_all_api_keys': 'Clear All API Keys',
      'api_key_saved': 'API key saved successfully',
      'api_key_cleared': 'API key cleared',
      'all_api_keys_cleared': 'All API keys cleared',
      'enter_valid_api_key': 'Please enter an API key',
      'scan_text': 'Scan Text',
      'select_image': 'Select Image',
      'take_photo': 'Take Photo',
      'no_text_recognized': 'No text recognized',
      'scan_first': 'Please scan an image first',
      'language': 'Language',
    },
    'tr': {
      'app_title': 'MedAI',
      'app_subtitle': 'Akıllı Tıbbi Asistanınız',
      'get_started': 'Başlayın',
      'home': 'Ana Sayfa',
      'medicine_programs': 'İlaç Programları',
      'ocr_scan': 'OCR Tarama',
      'ask_ai': 'Yapay Zekaya Sor',
      'api_key_management': 'API Anahtarı Yönetimi',
      'create_program': 'Program Oluştur',
      'program_name': 'Program Adı',
      'program_description': 'Açıklama (İsteğe Bağlı)',
      'schedule': 'Takvim',
      'schedule_days': 'Takvim Günleri',
      'reminders': 'Hatırlatıcılar',
      'reminder_times': 'Hatırlatıcı Saatleri',
      'add_time': 'Ekle',
      'cancel': 'İptal',
      'save': 'Kaydet',
      'delete': 'Sil',
      'edit': 'Düzenle',
      'active': 'Aktif',
      'inactive': 'Pasif',
      'active_programs': 'Aktif Programlar',
      'inactive_programs': 'Pasif Programlar',
      'no_programs': 'Henüz ilaç programı yok',
      'create_first_program': '+ butonuna basarak ilk programınızı oluşturun',
      'enter_program_name': 'Lütfen bir program adı girin',
      'select_one_day': 'Lütfen en az bir gün seçin',
      'add_one_reminder': 'Lütfen en az bir hatırlatıcı saati ekleyin',
      'time_already_added': 'Bu saat zaten eklenmiş',
      'program_created': 'Program başarıyla oluşturuldu',
      'program_updated': 'Program başarıyla güncellendi',
      'program_deleted': 'Program silindi',
      'delete_program_confirmation': 'Programı Sil',
      'delete_program_message':
          'Bu programı silmek istediğinizden emin misiniz?',
      'monday': 'Pazartesi',
      'tuesday': 'Salı',
      'wednesday': 'Çarşamba',
      'thursday': 'Perşembe',
      'friday': 'Cuma',
      'saturday': 'Cumartesi',
      'sunday': 'Pazar',
      'mon': 'Pzt',
      'tue': 'Sal',
      'wed': 'Çar',
      'thu': 'Per',
      'fri': 'Cum',
      'sat': 'Cmt',
      'sun': 'Paz',
      'your_question': 'Sorunuz',
      'ask_anything': 'Bir şeyler sorun...',
      'ask': 'Yapay Zekaya Sor',
      'processing': 'İşleniyor...',
      'select_ai_service': 'Yapay Zeka Servisi Seçin',
      'no_responses': 'Henüz yanıt yok. Başlamak için bir soru sorun!',
      'enter_question': 'Lütfen sorunuzu girin',
      'just_now': 'Az önce',
      'ago': 'önce',
      'set_api_key_first': 'Lütfen önce API anahtarınızı ayarlayın',
      'set_api_key': 'API Anahtarı Ayarla',
      'general_api_key': 'Genel API Anahtarı',
      'chatgpt_api_key': 'ChatGPT API Anahtarı',
      'mistral_api_key': 'Mistral API Anahtarı',
      'gemini_api_key': 'Gemini API Anahtarı',
      'new_api_key': 'Yeni API Anahtarı',
      'enter_api_key': 'API anahtarınızı girin',
      'clear_api_key': 'API Anahtarını Temizle',
      'clear_all_api_keys': 'Tüm API Anahtarlarını Temizle',
      'api_key_saved': 'API anahtarı başarıyla kaydedildi',
      'api_key_cleared': 'API anahtarı temizlendi',
      'all_api_keys_cleared': 'Tüm API anahtarları temizlendi',
      'enter_valid_api_key': 'Lütfen bir API anahtarı girin',
      'scan_text': 'Metin Tara',
      'select_image': 'Resim Seç',
      'take_photo': 'Fotoğraf Çek',
      'no_text_recognized': 'Metin tanınmadı',
      'scan_first': 'Lütfen önce bir resim tarayın',
      'language': 'Dil',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenient getters
  String get appTitle => translate('app_title');
  String get appSubtitle => translate('app_subtitle');
  String get getStarted => translate('get_started');
  String get home => translate('home');
  String get medicinePrograms => translate('medicine_programs');
  String get ocrScan => translate('ocr_scan');
  String get askAI => translate('ask_ai');
  String get apiKeyManagement => translate('api_key_management');
  String get createProgram => translate('create_program');
  String get programName => translate('program_name');
  String get programDescription => translate('program_description');
  String get schedule => translate('schedule');
  String get scheduleDays => translate('schedule_days');
  String get reminders => translate('reminders');
  String get reminderTimes => translate('reminder_times');
  String get addTime => translate('add_time');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get activePrograms => translate('active_programs');
  String get inactivePrograms => translate('inactive_programs');
  String get noPrograms => translate('no_programs');
  String get createFirstProgram => translate('create_first_program');
  String get language => translate('language');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
