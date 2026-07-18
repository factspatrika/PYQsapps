import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive_models.dart';

class CachingService {
  static const String contentBoxName = 'contentBox';
  static const String progressBoxName = 'progressBox';
  static const String mistakeBoxName = 'mistakeBox';
  static const String bookmarkBoxName = 'bookmarkBox';
  static const String settingsBoxName = 'settingsBox';
  static const String questionsCacheBoxName = 'questionsCacheBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(QuestionTypeAdapter());
    Hive.registerAdapter(QuestionModelAdapter());
    Hive.registerAdapter(MockModelAdapter());
    Hive.registerAdapter(TopicModelAdapter());
    Hive.registerAdapter(SubjectModelAdapter());

    // Open Boxes
    await Hive.openBox<SubjectModel>(contentBoxName);
    await Hive.openBox(progressBoxName);
    await Hive.openBox<List<String>>(mistakeBoxName);
    await Hive.openBox<List<String>>(bookmarkBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<List<dynamic>>(questionsCacheBoxName);
  }

  // --- Content Box (JSON Caching) ---
  static Box<SubjectModel> get contentBox => Hive.box<SubjectModel>(contentBoxName);

  static Future<void> saveSubject(SubjectModel subject) async {
    await contentBox.put(subject.subjectId, subject);
  }

  static SubjectModel? getSubject(String subjectId) {
    return contentBox.get(subjectId);
  }

  static bool hasSubject(String subjectId) {
    return contentBox.containsKey(subjectId);
  }

  // --- Populate Dummy/Mock Data ---
  static void populateDummyData() {
    final List<QuestionModel> dummyQuestions = List.generate(30, (index) {
      String eName = index % 3 == 0 ? 'ALP' : (index % 3 == 1 ? 'RRB NTPC' : 'Group D');
      String eYear = index % 2 == 0 ? '2022' : '2018';
      
      return QuestionModel(
        id: 'q_$index',
        question: 'Sample Question ${index + 1} for testing? [$eName $eYear]',
        type: QuestionType.standard,
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctIndex: 0,
        explanation: 'Explanation for question ${index + 1}',
        examName: eName,
        examYear: eYear,
      );
    });

    final subjects = [
      SubjectModel(
        subjectId: 'sub_physics',
        subjectName: 'Physics (भौतिक विज्ञान)',
        topics: [
          TopicModel(
            topicId: 'top_units',
            topicName: 'मात्रक और मापन (Units and Measurement)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_1', mockName: 'Mock Test 1', questions: dummyQuestions),
              MockModel(mockId: 'mock_2', mockName: 'Mock Test 2', questions: dummyQuestions),
            ],
          ),
          TopicModel(
            topicId: 'top_motion',
            topicName: 'गति (Motion)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_3', mockName: 'Mock Test 1', questions: dummyQuestions),
            ],
          ),
          TopicModel(
            topicId: 'top_work',
            topicName: 'कार्य, ऊर्जा और शक्ति (Work, Energy & Power)',
            isPremium: true, // Premium lock
            mocks: [
              MockModel(mockId: 'mock_4', mockName: 'Mock Test 1', questions: dummyQuestions),
              MockModel(mockId: 'mock_5', mockName: 'Mock Test 2', questions: dummyQuestions),
              MockModel(mockId: 'mock_6', mockName: 'Mock Test 3', questions: dummyQuestions),
            ],
          ),
        ],
      ),
      SubjectModel(
        subjectId: 'sub_chemistry',
        subjectName: 'Chemistry (रसायन विज्ञान)',
        topics: [
          TopicModel(
            topicId: 'top_atoms',
            topicName: 'परमाणु संरचना (Atomic Structure)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_7', mockName: 'Mock Test 1', questions: dummyQuestions),
            ],
          ),
        ],
      ),
      SubjectModel(
        subjectId: 'sub_biology',
        subjectName: 'Biology (जीव विज्ञान)',
        topics: [
          TopicModel(
            topicId: 'top_cells',
            topicName: 'कोशिका (Cell Biology)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_8', mockName: 'Mock Test 1', questions: dummyQuestions),
            ],
          ),
          TopicModel(
            topicId: 'top_animal_kingdom',
            topicName: 'जंतु जगत (Animal Kingdom)',
            isPremium: false,
            mocks: [
              MockModel(mockId: 'mock_animal_kingdom_1', mockName: 'Mock Test 1 (Q. 1-30)', questions: []),
              MockModel(mockId: 'mock_animal_kingdom_2', mockName: 'Mock Test 2 (Q. 31-60)', questions: []),
              MockModel(mockId: 'mock_animal_kingdom_3', mockName: 'Mock Test 3 (Q. 61-90)', questions: []),
              MockModel(mockId: 'mock_animal_kingdom_4', mockName: 'Mock Test 4 (Q. 91-120)', questions: []),
              MockModel(mockId: 'mock_animal_kingdom_5', mockName: 'Mock Test 5 (Q. 121-150)', questions: []),
              MockModel(mockId: 'mock_animal_kingdom_6', mockName: 'Mock Test 6 (Q. 151-171)', questions: []),
            ],
          ),
        ],
      ),
    ];

    for (var subject in subjects) {
      saveSubject(subject);
    }
  }

  static Future<void> syncAppConfig() async {
    const configUrl = 'https://raw.githubusercontent.com/factspatrika/railway-pyq-content/main/app_config.json';
    try {
      final response = await http.get(Uri.parse(configUrl)).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final box = Hive.box(settingsBoxName);
        await box.put('razorpay_key', decoded['razorpayKey'] ?? 'rzp_test_mock_key');
        await box.put('premium_price_rs', decoded['premiumPriceRs'] ?? 29);
        await box.put('google_sheets_url', decoded['googleSheetsUrl'] ?? defaultGoogleSheetsUrl);
        debugPrint('App configuration synced successfully from GitHub CDN!');
      }
    } catch (e) {
      debugPrint('Failed to sync app config: $e');
    }
  }

  static Future<void> syncAppStructure() async {
    // Fetch dynamic configurations in parallel
    syncAppConfig();

    const url = 'https://raw.githubusercontent.com/factspatrika/railway-pyq-content/main/subjects.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        
        // Structure is valid, let's clear the old cached structure and save fresh
        await contentBox.clear();
        for (var item in decoded) {
          final subject = SubjectModel.fromJson(item as Map<String, dynamic>);
          await saveSubject(subject);
        }
        debugPrint('App structure synced successfully from GitHub CDN!');
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to sync structure from remote: $e');
      // If we are offline and have absolutely no data cached yet, wait for connection
      if (contentBox.isEmpty) {
        debugPrint('No cached structure tree available in Hive box.');
      }
    }
  }

  static String getSubjectSlug(String subjectId) {
    return subjectId.replaceAll('sub_', ''); // e.g. 'biology'
  }

  static String getTopicSlug(String topicId) {
    switch (topicId) {
      case 'top_units': return 'units_and_measurement';
      case 'top_motion': return 'motion';
      case 'top_work': return 'work_energy_power';
      case 'top_atoms': return 'atomic_structure';
      case 'top_cells': return 'cell_biology';
      case 'top_animal_kingdom': return 'animal_kingdom';
      default: return topicId.replaceAll('top_', '');
    }
  }

  // --- Questions Cache Box ---
  static Box<List<dynamic>> get questionsCacheBox => Hive.box<List<dynamic>>(questionsCacheBoxName);

  // --- Fetch Questions for Mock ---
  static Future<List<QuestionModel>> fetchQuestionsForMock({
    required String subjectId,
    required String topicId,
    required String mockId,
  }) async {
    // Check local cache first
    if (questionsCacheBox.containsKey(mockId)) {
      final cachedList = questionsCacheBox.get(mockId);
      if (cachedList != null && cachedList.isNotEmpty) {
        return cachedList.cast<QuestionModel>().toList();
      }
    }

    // If not cached, fetch from CDN (Cloudflare Pages)
    final subjectSlug = getSubjectSlug(subjectId);
    final topicSlug = getTopicSlug(topicId);
    final urlString = 'https://raw.githubusercontent.com/factspatrika/railway-pyq-content/main/$subjectSlug/$topicSlug.json';
    
    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final questionsJson = decoded['questions'] as List<dynamic>;
        final allQuestions = questionsJson.map((item) => QuestionModel.fromJson(item as Map<String, dynamic>)).toList();
        
        // Split questions into batches of 30 based on mock index/ID (e.g. mock_animal_kingdom_3 -> 3rd batch of 30)
        int batchIndex = 0;
        final regExp = RegExp(r'_(\d+)$');
        final match = regExp.firstMatch(mockId);
        if (match != null) {
          batchIndex = int.parse(match.group(1)!) - 1; // 0-indexed
        }
        
        final startIndex = batchIndex * 30;
        final endIndex = (batchIndex + 1) * 30;
        
        List<QuestionModel> batchQuestions = [];
        if (startIndex < allQuestions.length) {
          batchQuestions = allQuestions.sublist(
            startIndex,
            endIndex > allQuestions.length ? allQuestions.length : endIndex,
          );
        }
        
        // Save only this batch to local cache under this specific mockId
        await questionsCacheBox.put(mockId, batchQuestions);
        return batchQuestions;
      } else {
        throw Exception('Failed to load questions from server (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  // --- Daily Random 10 Questions ---
  /// Fetches 10 random questions for the daily quiz.
  /// First checks local cache. If empty, downloads all_questions.json
  /// from GitHub and caches it. Uses today's date as seed for
  /// deterministic daily randomization.
  static Future<List<QuestionModel>> getDailyRandomQuestions({int count = 10}) async {
    final List<QuestionModel> allQuestions = [];

    // 1. Gather questions from contentBox (subject → topic → mock → questions)
    for (var subject in contentBox.values) {
      for (var topic in subject.topics) {
        for (var mock in topic.mocks) {
          allQuestions.addAll(mock.questions);
        }
      }
    }

    // 2. Gather from questionsCacheBox (on-demand downloaded questions)
    for (var cachedList in questionsCacheBox.values) {
      if (cachedList.isNotEmpty) {
        for (var q in cachedList) {
          if (q is QuestionModel) {
            allQuestions.add(q);
          }
        }
      }
    }

    // 3. If local cache is empty/insufficient, fetch all_questions.json from GitHub
    if (allQuestions.length < count) {
      try {
        const allQuestionsUrl = 'https://raw.githubusercontent.com/factspatrika/railway-pyq-content/main/all_questions.json';
        final response = await http.get(Uri.parse(allQuestionsUrl));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final questionsJson = decoded['questions'] as List<dynamic>;
          final fetchedQuestions = questionsJson
              .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
              .toList();
          
          // Cache these questions locally for future offline use
          await questionsCacheBox.put('daily_all_questions', fetchedQuestions);
          allQuestions.addAll(fetchedQuestions);
        }
      } catch (_) {
        // Network error — use whatever we have locally
      }
    }

    if (allQuestions.isEmpty) return [];

    // Remove duplicates by question id
    final Map<String, QuestionModel> uniqueMap = {};
    for (var q in allQuestions) {
      uniqueMap[q.id] = q;
    }
    final uniqueQuestions = uniqueMap.values.toList();

    if (uniqueQuestions.length <= count) return uniqueQuestions;

    // Use today's date as seed for deterministic daily randomization
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    // Fisher-Yates shuffle with seeded random, then take first `count`
    final shuffled = List<QuestionModel>.from(uniqueQuestions);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    return shuffled.take(count).toList();
  }

  // --- Google Sheets Integration ---
  static const String defaultGoogleSheetsUrl = 'https://script.google.com/macros/s/AKfycbyn8rA8Rbp9JTyY2NWqAvilbHaOvVykN_e2Ep1Nl-EmJXxEE0rrQwrEoYu0Kqd1YNawgA/exec';

  static String getGoogleSheetsUrl() {
    final box = Hive.box(settingsBoxName);
    return box.get('google_sheets_url', defaultValue: defaultGoogleSheetsUrl) as String;
  }

  static Future<void> saveGoogleSheetsUrl(String url) async {
    final box = Hive.box(settingsBoxName);
    await box.put('google_sheets_url', url);
  }

  static Future<Map<String, dynamic>> checkUserPremiumStatus(String phone, {String name = 'Learner'}) async {
    final baseUrl = getGoogleSheetsUrl();
    final url = Uri.parse('$baseUrl?phone=${Uri.encodeComponent(phone)}&name=${Uri.encodeComponent(name)}');
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 || response.statusCode == 302) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Cache user status locally
        final box = Hive.box(settingsBoxName);
        final isPremium = decoded['isPremium'] == true;
        await box.put('is_premium', isPremium);
        await box.put('profile_name', decoded['name'] ?? name);
        
        return decoded;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error checking user premium status from Google Sheets: $e');
      rethrow;
    }
  }

  static Future<bool> updateUserPremiumStatus(String phone, bool isPremium, {String paymentId = ''}) async {
    final baseUrl = getGoogleSheetsUrl();
    final url = Uri.parse(baseUrl);
    
    try {
      final payload = {
        'phone': phone,
        'isPremium': isPremium,
        'paymentId': paymentId
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200 || response.statusCode == 302) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['status'] == 'success') {
          final box = Hive.box(settingsBoxName);
          await box.put('is_premium', isPremium);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating user premium status: $e');
      return false;
    }
  }
}
