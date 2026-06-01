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
      'today_schedule': 'Today\'s Schedule',
      'no_programs_today': 'No active programs today',
      'active_today': 'active today',
      'next_reminder': 'Next',
      'tools': 'Quick Tools',
      'scan_medical_question': 'Scan a Medical Question',
      'tap_to_scan': 'Tap camera or gallery to scan',
      'recognized_text': 'Recognized Text',
      'ai_analysis': 'AI Analysis',
      'analyzing_with_ai': 'Analyzing...',
      'no_ai_configured': 'No AI service configured. Please set up an API key first.',
      'configure_api_keys': 'Configure Keys',
      'no_text_in_image': 'No text found. Try a clearer photo.',
      'retry': 'Retry',
      'copied': 'Copied!',
      'copy_response': 'Copy',
      'ai_responses': 'AI Responses',
      'quick_presets': 'Quick Presets',
      'preset_daily': 'Daily',
      'preset_weekdays': 'Weekdays',
      'preset_weekends': 'Weekends',
      'preset_mwf': 'M / W / F',
      'quick_times': 'Quick Times',
      'time_morning': 'Morning 8:00',
      'time_noon': 'Noon 13:00',
      'time_evening': 'Evening 20:00',
      'add_description': 'Add description',
      'your_clinical_co_pilot': 'Your Clinical AI Co-Pilot. Evidence-Based Diagnostic Insights.',
      'continue_with_google': 'Continue with Google',
      'sign_in_failed': 'Sign-in failed',
      'signing_in': 'Signing in...',
      'clinical_level': 'Clinical Level / Academic Track',
      'clinical_level_desc': 'Tailor AI outputs to your medical training stage',
      'advanced_legacy_tools': 'Advanced Legacy Tools',
      'ocr_scanner_desc': 'Decode patient cases, prescription notes, and exam diagrams with ML recognition.',
      'theme_mode': 'Dark Mode',
      'welcome_doctor': 'Welcome back, Doctor',
      'select_track_in_settings': 'Select your curriculum track in settings',
      'current_track': 'Current Track: ',
      'start_clinical_query': 'Start Clinical Query',

      // NEW LOCALIZATION KEYS EN
      'welcome_counselor': 'Welcome back, Counselor.',
      'clinical_focus_today': 'What is your clinical focus today?',
      'launch_new_query': 'Launch New Clinical Query',
      'launch_new_query_desc': 'Start a brand-new diagnostic session with AI clinical reasoning.',
      'student_profile_preferences': 'Student Profile & Preferences',
      'student_profile_preferences_desc': 'Academic level, localization, and theme options',
      'recent_case_investigations': 'Recent Case Investigations',
      'no_recent_cases': 'No recent case investigations.',
      'active_sessions_desc': 'Your active clinical study sessions will appear here.',
      'delete_case_title': 'Delete Case?',
      'delete_case_confirm': 'Are you sure you want to permanently delete this case investigation from your device?',
      'messages_count_label': 'messages',
      'new_clinical_case': 'New Clinical Case...',
      'config_error': 'Configuration Error',
      'no_ai_service_available': 'No AI service available',
      'rename_session': 'Rename Session',
      'enter_session_title': 'Enter session title...',
      'delete_session_title': 'Delete Session?',
      'delete_session_confirm': 'This action cannot be undone. Are you sure you want to delete this case investigation?',
      'quick_clinical_templates': 'Quick Clinical Templates',
      'medai_chat': 'MedAI Chat',
      'pro_tier_cases_remaining': '✨ PRO Tier: {remaining}/50 Daily Expert Cases',
      'free_tier_cases_remaining': '🩺 {remaining}/5 Daily Clinical Cases Available',
      
      // Chips
      'chip_ddx_label': '🔬 Differential Diagnosis',
      'chip_ddx_prefix': 'Analyze the differential diagnosis (including primary, secondary, and rule-out conditions) for the following clinical presentation: ',
      'chip_pharm_label': '💊 Pharmacology & Interactions',
      'chip_pharm_prefix': 'Break down the mechanism of action, high-yield clinical indications, major contraindications, and critical drug interactions for: ',
      'chip_lab_label': '📊 Lab & Imaging Interpreter',
      'chip_lab_prefix': 'Interpret the following laboratory values or imaging findings, correlate them clinically, and suggest the next best diagnostic steps: ',
      'chip_board_label': '📚 TUS & Board Exam Logic',
      'chip_board_prefix': 'Extract and analyze the core, high-yield medical board principles and pathophysiological rationales behind this clinical vignette: ',

      // Paywall
      'paywall_feat1_title': 'Up to 50 Deep Clinical Knowledge Graph Queries / Day',
      'paywall_feat1_desc': 'Visual connections between symptoms, diagnoses, and treatments.',
      'paywall_feat2_title': 'Instant Medical Slide & Prescription OCR Decoding',
      'paywall_feat2_desc': 'Extract text from medical slides, notes, and prescriptions.',
      'paywall_feat3_title': 'High-Yield TUS & Board Exam Breakdown Modes',
      'paywall_feat3_desc': 'Interactive analysis of complex board exam scenarios.',
      'paywall_feat4_title': 'Zero Latency, Priority AI Reasoning Pipeline',
      'paywall_feat4_desc': 'Bypass rate limits with priority resources.',
      'monthly_plan_title': 'Monthly Plan',
      'monthly_plan_desc': 'Cancel anytime. Standard access.',
      'annual_plan_title': 'Annual Plan',
      'annual_plan_desc': 'Best value: Save 50% (\$4.99/mo)',
      'paywall_per_month': '/ month',
      'paywall_per_year': '/ year',
      'paywall_choose_plan': 'Choose your plan',
      'paywall_save_50': 'SAVE 50%',
      'paywall_already_subscribed': 'Already Subscribed',
      'paywall_subscribe_button': 'Subscribe to Premium',
      'paywall_keep_free': 'Keep using free version',
      'paywall_upgrade_title': 'Upgrade to Premium',
      'paywall_premium_header': 'MedAI Premium',
      'paywall_premium_sub': 'Elevate your daily clinical learning capabilities',
      'paywall_up_to_50': 'UP TO 50 CLINICAL QUERIES / DAY',
      'paywall_success_title': 'Welcome to Premium!',
      'paywall_success_desc': 'Your account has been upgraded. You now have up to 50 daily clinical queries and advanced medical insights!',
      'paywall_success_button': 'Start Querying',
      'paywall_failed_message': 'Subscription failed: {error}',
      'paywall_loading_plans': 'Loading plans...',

      // Profile
      'app_preferences': 'App Preferences',
      'profile_settings_title': 'Profile & Settings',
      'sign_out_account': 'Sign Out of Account',
      'medical_professional': 'Medical Professional',

      // Question Bank
      'question_bank': 'Question Bank',
      'question_bank_desc': 'Review scanned textbook questions and track your performance.',
      'success_rate': 'Success Rate',
      'avg_time': 'Avg Time',
      'total_questions': 'Total Questions',
      'mark_correct': 'Mark Correct',
      'mark_incorrect': 'Mark Incorrect',
      'attempts': 'attempts',
      'no_questions_saved': 'No questions saved yet',
      'no_questions_saved_desc': 'Use the OCR Scanner to scan and save medical questions.',
      'question_details': 'Question Details',
      'performance': 'Performance',
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
      'today_schedule': 'Bugünkü Program',
      'no_programs_today': 'Bugün aktif program yok',
      'active_today': 'bugün aktif',
      'next_reminder': 'Sonraki',
      'tools': 'Hızlı Araçlar',
      'scan_medical_question': 'Tıbbi Soru Tara',
      'tap_to_scan': 'Taramak için kamera veya galeriye dokunun',
      'recognized_text': 'Tanınan Metin',
      'ai_analysis': 'Yapay Zeka Analizi',
      'analyzing_with_ai': 'Analiz ediliyor...',
      'no_ai_configured': 'Yapay zeka hizmeti yapılandırılmadı. Lütfen önce bir API anahtarı ekleyin.',
      'configure_api_keys': 'Anahtarları Yapılandır',
      'no_text_in_image': 'Metinde metin bulunamadı. Daha net bir fotoğraf deneyin.',
      'retry': 'Tekrar Dene',
      'copied': 'Kopyalandı!',
      'copy_response': 'Kopyala',
      'ai_responses': 'Yapay Zeka Yanıtları',
      'quick_presets': 'Hızlı Şablonlar',
      'preset_daily': 'Her Gün',
      'preset_weekdays': 'Hafta İçi',
      'preset_weekends': 'Hafta Sonu',
      'preset_mwf': 'P / Ç / C',
      'quick_times': 'Hızlı Saatler',
      'time_morning': 'Sabah 8:00',
      'time_noon': 'Öğle 13:00',
      'time_evening': 'Akşam 20:00',
      'add_description': 'Açıklama ekle',
      'your_clinical_co_pilot': 'Klinik Yapay Zeka Asistanınız. Kanıta Dayalı Teşhis Analizleri.',
      'continue_with_google': 'Google ile Devam Et',
      'sign_in_failed': 'Giriş başarısız oldu',
      'signing_in': 'Giriş yapılıyor...',
      'clinical_level': 'Klinik Seviye / Akademik Dönem',
      'clinical_level_desc': 'Yapay zeka yanıtlarını eğitim seviyenize göre optimize edin',
      'advanced_legacy_tools': 'Gelişmiş Eski Araçlar',
      'ocr_scanner_desc': 'Hasta vakalarını, reçete notlarını ve sınav şemalarını makine öğrenimi tanıma özelliğiyle anında çözün.',
      'theme_mode': 'Karanlık Tema',
      'welcome_doctor': 'Hoş Geldiniz, Doktor',
      'select_track_in_settings': 'Ayarlardan müfredat dönemini seçin',
      'current_track': 'Aktif Dönem: ',
      'start_clinical_query': 'Klinik Vaka Sorgusu Başlat',

      // NEW LOCALIZATION KEYS TR
      'welcome_counselor': 'Hoş geldiniz, Danışman.',
      'clinical_focus_today': 'Bugünkü klinik odağınız nedir?',
      'launch_new_query': 'Klinik Vaka Sorgusu Başlat',
      'launch_new_query_desc': 'Yapay zeka klinik muhakemesiyle yepyeni bir teşhis seansı başlatın.',
      'student_profile_preferences': 'Öğrenci Profili & Tercihleri',
      'student_profile_preferences_desc': 'Akademik seviye, dil seçeneği ve tema ayarları',
      'recent_case_investigations': 'Son Vaka İncelemeleri',
      'no_recent_cases': 'Son vaka incelemesi bulunmuyor.',
      'active_sessions_desc': 'Aktif klinik çalışma seanslarınız burada görünecektir.',
      'delete_case_title': 'Vakayı Sil?',
      'delete_case_confirm': 'Bu vaka incelemesini cihazınızdan kalıcı olarak silmek istediğinizden emin misiniz?',
      'messages_count_label': 'mesaj',
      'new_clinical_case': 'Yeni Klinik Vaka...',
      'config_error': 'Yapılandırma Hatası',
      'no_ai_service_available': 'Kullanılabilir yapay zeka servisi yok',
      'rename_session': 'Seansı Yeniden Adlandır',
      'enter_session_title': 'Seans başlığı girin...',
      'delete_session_title': 'Seansı Sil?',
      'delete_session_confirm': 'Bu işlem geri alınamaz. Bu vaka incelemesini silmek istediğinizden emin misiniz?',
      'quick_clinical_templates': 'Hızlı Klinik Şablonlar',
      'medai_chat': 'MedAI Sohbet',
      'pro_tier_cases_remaining': '✨ PRO Üyelik: Günlük {remaining}/50 Uzman Vaka Hakkı',
      'free_tier_cases_remaining': '🩺 Günlük {remaining}/5 Klinik Vaka Hakkı',
      
      // Chips
      'chip_ddx_label': '🔬 Ayırıcı Tanı',
      'chip_ddx_prefix': 'Aşağıdaki klinik tablo için (birincil, ikincil ve elenmesi gereken durumları içerecek şekilde) ayırıcı tanı analizi yap: ',
      'chip_pharm_label': '💊 Farmakoloji ve Etkileşim',
      'chip_pharm_prefix': 'Şu ilaç/etken madde için etki mekanizmasını, klinik endikasyonlarını, önemli kontrendikasyonlarını ve kritik ilaç etkileşimlerini açıkla: ',
      'chip_lab_label': '📊 Laboratuvar ve Görüntüleme',
      'chip_lab_prefix': 'Aşağıdaki laboratuvar değerlerini veya görüntüleme bulgularını yorumla, klinik korelasyon kur ve atılması gereken bir sonraki en iyi tanısal adımı öner: ',
      'chip_board_label': '📚 TUS ve Komite Soru Mantığı',
      'chip_board_prefix': 'Bu klinik vakanın arkasındaki temel TUS/Komite mekanizmalarını ve patofizyolojik mantığı yüksek verimli (high-yield) bir şekilde analiz et: ',

      // Paywall
      'paywall_feat1_title': 'Günlük En Fazla 50 Derin Klinik Bilgi Grafiği Sorgusu',
      'paywall_feat1_desc': 'Semptomlar, tanılar ve tedaviler arasında görsel bağlantılar.',
      'paywall_feat2_title': 'Anında Tıbbi Slayt ve Reçete OCR Çözümleme',
      'paywall_feat2_desc': 'Tıbbi slaytlar, notlar ve reçetelerden metin çıkarın.',
      'paywall_feat3_title': 'Yüksek Verimli TUS ve Sınav Analiz Modları',
      'paywall_feat3_desc': 'Karmaşık kurul sınavı senaryolarının etkileşimli analizi.',
      'paywall_feat4_title': 'Sıfır Gecikmeli, Öncelikli Yapay Zeka Mantık Akışı',
      'paywall_feat4_desc': 'Öncelikli kaynaklarla hız sınırlarını atlayın.',
      'monthly_plan_title': 'Aylık Plan',
      'monthly_plan_desc': 'İstediğiniz zaman iptal edin. Standart erişim.',
      'annual_plan_title': 'Yıllık Plan',
      'annual_plan_desc': 'En iyi fiyat: %50 Tasarruf et (Aylık \$4.99)',
      'paywall_per_month': ' / ay',
      'paywall_per_year': ' / yıl',
      'paywall_choose_plan': 'Planınızı seçin',
      'paywall_save_50': '%50 TASARRUF',
      'paywall_already_subscribed': 'Zaten Abone Olundu',
      'paywall_subscribe_button': 'Premium\'a Abone Ol',
      'paywall_keep_free': 'Ücretsiz sürümü kullanmaya devam et',
      'paywall_upgrade_title': 'Premium\'a Yükselt',
      'paywall_premium_header': 'MedAI Premium',
      'paywall_premium_sub': 'Günlük klinik öğrenme yeteneklerinizi yükseltin',
      'paywall_up_to_50': 'GÜNLÜK 50 KLİNİK VAKA HAKKI',
      'paywall_success_title': 'Premium\'a Hoş Geldiniz!',
      'paywall_success_desc': 'Hesabınız yükseltildi. Artık günlük 50 klinik vaka hakkına ve gelişmiş tıbbi analizlere sahipsiniz!',
      'paywall_success_button': 'Sorgulamaya Başla',
      'paywall_failed_message': 'Abonelik başarısız: {error}',
      'paywall_loading_plans': 'Planlar yükleniyor...',

      // Profile
      'app_preferences': 'Uygulama Tercihleri',
      'profile_settings_title': 'Profil & Ayarlar',
      'sign_out_account': 'Hesaptan Çıkış Yap',
      'medical_professional': 'Tıp Uzmanı',

      // Question Bank
      'question_bank': 'Soru Bankası',
      'question_bank_desc': 'Taranan kitap sorularını inceleyin ve performansınızı takip edin.',
      'success_rate': 'Başarı Oranı',
      'avg_time': 'Ort. Süre',
      'total_questions': 'Toplam Soru',
      'mark_correct': 'Doğru İşaretle',
      'mark_incorrect': 'Yanlış İşaretle',
      'attempts': 'deneme',
      'no_questions_saved': 'Henüz kaydedilmiş soru yok',
      'no_questions_saved_desc': 'Tıbbi soruları taramak ve kaydetmek için OCR Tarayıcıyı kullanın.',
      'question_details': 'Soru Detayları',
      'performance': 'Performans',
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
  String get todaySchedule => translate('today_schedule');
  String get noProgramsToday => translate('no_programs_today');
  String get activeToday => translate('active_today');
  String get nextReminder => translate('next_reminder');
  String get tools => translate('tools');
  String get scanMedicalQuestion => translate('scan_medical_question');
  String get tapToScan => translate('tap_to_scan');
  String get recognizedText => translate('recognized_text');
  String get aiAnalysis => translate('ai_analysis');
  String get analyzingWithAi => translate('analyzing_with_ai');
  String get noAiConfigured => translate('no_ai_configured');
  String get configureApiKeys => translate('configure_api_keys');
  String get noTextInImage => translate('no_text_in_image');
  String get retry => translate('retry');
  String get copied => translate('copied');
  String get copyResponse => translate('copy_response');
  String get aiResponses => translate('ai_responses');
  String get quickPresets => translate('quick_presets');
  String get presetDaily => translate('preset_daily');
  String get presetWeekdays => translate('preset_weekdays');
  String get presetWeekends => translate('preset_weekends');
  String get presetMwf => translate('preset_mwf');
  String get quickTimes => translate('quick_times');
  String get timeMorning => translate('time_morning');
  String get timeNoon => translate('time_noon');
  String get timeEvening => translate('time_evening');
  String get addDescription => translate('add_description');
  String get takePhoto => translate('take_photo');
  String get selectImage => translate('select_image');

  String get yourQuestion => translate('your_question');
  String get askAnything => translate('ask_anything');
  String get enterQuestion => translate('enter_question');
  
  String get yourClinicalCoPilot => translate('your_clinical_co_pilot');
  String get continueWithGoogle => translate('continue_with_google');
  String get signInFailed => translate('sign_in_failed');
  String get signingIn => translate('signing_in');
  String get clinicalLevel => translate('clinical_level');
  String get clinicalLevelDesc => translate('clinical_level_desc');
  String get advancedLegacyTools => translate('advanced_legacy_tools');
  String get ocrScannerDesc => translate('ocr_scanner_desc');
  String get themeModeLabel => translate('theme_mode');
  String get welcomeDoctor => translate('welcome_doctor');
  String get selectTrackInSettings => translate('select_track_in_settings');
  String get currentTrackLabel => translate('current_track');
  String get startClinicalQuery => translate('start_clinical_query');

  // Dynamic getters for new localization keys
  String get noResponses => translate('no_responses');
  String get welcomeCounselor => translate('welcome_counselor');
  String get clinicalFocusToday => translate('clinical_focus_today');
  String get launchNewQuery => translate('launch_new_query');
  String get launchNewQueryDesc => translate('launch_new_query_desc');
  String get studentProfilePreferences => translate('student_profile_preferences');
  String get studentProfilePreferencesDesc => translate('student_profile_preferences_desc');
  String get recentCaseInvestigations => translate('recent_case_investigations');
  String get noRecentCases => translate('no_recent_cases');
  String get activeSessionsDesc => translate('active_sessions_desc');
  String get deleteCaseTitle => translate('delete_case_title');
  String get deleteCaseConfirm => translate('delete_case_confirm');
  String get messagesCountLabel => translate('messages_count_label');
  String get newClinicalCase => translate('new_clinical_case');
  String get configError => translate('config_error');
  String get noAiServiceAvailable => translate('no_ai_service_available');
  String get renameSession => translate('rename_session');
  String get enterSessionTitle => translate('enter_session_title');
  String get deleteSessionTitle => translate('delete_session_title');
  String get deleteSessionConfirm => translate('delete_session_confirm');
  String get quickClinicalTemplates => translate('quick_clinical_templates');
  String get medaiChat => translate('medai_chat');
  String get proTierCasesRemaining => translate('pro_tier_cases_remaining');
  String get freeTierCasesRemaining => translate('free_tier_cases_remaining');
  
  // Chips
  String get chipDdxLabel => translate('chip_ddx_label');
  String get chipDdxPrefix => translate('chip_ddx_prefix');
  String get chipPharmLabel => translate('chip_pharm_label');
  String get chipPharmPrefix => translate('chip_pharm_prefix');
  String get chipLabLabel => translate('chip_lab_label');
  String get chipLabPrefix => translate('chip_lab_prefix');
  String get chipBoardLabel => translate('chip_board_label');
  String get chipBoardPrefix => translate('chip_board_prefix');

  // Paywall
  String get paywallFeat1Title => translate('paywall_feat1_title');
  String get paywallFeat1Desc => translate('paywall_feat1_desc');
  String get paywallFeat2Title => translate('paywall_feat2_title');
  String get paywallFeat2Desc => translate('paywall_feat2_desc');
  String get paywallFeat3Title => translate('paywall_feat3_title');
  String get paywallFeat3Desc => translate('paywall_feat3_desc');
  String get paywallFeat4Title => translate('paywall_feat4_title');
  String get paywallFeat4Desc => translate('paywall_feat4_desc');
  String get monthlyPlanTitle => translate('monthly_plan_title');
  String get monthlyPlanDesc => translate('monthly_plan_desc');
  String get annualPlanTitle => translate('annual_plan_title');
  String get annualPlanDesc => translate('annual_plan_desc');
  String get paywallPerMonth => translate('paywall_per_month');
  String get paywallPerYear => translate('paywall_per_year');
  String get paywallChoosePlan => translate('paywall_choose_plan');
  String get paywallSave50 => translate('paywall_save_50');
  String get paywallAlreadySubscribed => translate('paywall_already_subscribed');
  String get paywallSubscribeButton => translate('paywall_subscribe_button');
  String get paywallKeepFree => translate('paywall_keep_free');
  String get paywallUpgradeTitle => translate('paywall_upgrade_title');
  String get paywallPremiumHeader => translate('paywall_premium_header');
  String get paywallPremiumSub => translate('paywall_premium_sub');
  String get paywallUpTo50 => translate('paywall_up_to_50');
  String get paywallSuccessTitle => translate('paywall_success_title');
  String get paywallSuccessDesc => translate('paywall_success_desc');
  String get paywallSuccessButton => translate('paywall_success_button');
  String get paywallFailedMessage => translate('paywall_failed_message');
  String get paywallLoadingPlans => translate('paywall_loading_plans');

  // Profile
  String get appPreferences => translate('app_preferences');
  String get profileSettingsTitle => translate('profile_settings_title');
  String get signOutAccount => translate('sign_out_account');
  String get medicalProfessional => translate('medical_professional');

  // Question Bank
  String get questionBank => translate('question_bank');
  String get questionBankDesc => translate('question_bank_desc');
  String get successRate => translate('success_rate');
  String get avgTime => translate('avg_time');
  String get totalQuestions => translate('total_questions');
  String get markCorrect => translate('mark_correct');
  String get markIncorrect => translate('mark_incorrect');
  String get attempts => translate('attempts');
  String get noQuestionsSaved => translate('no_questions_saved');
  String get noQuestionsSavedDesc => translate('no_questions_saved_desc');
  String get questionDetails => translate('question_details');
  String get performance => translate('performance');
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
