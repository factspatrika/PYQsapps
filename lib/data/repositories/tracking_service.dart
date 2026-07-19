import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive_models.dart';
import 'caching_service.dart';

class TrackingService {
  static List<QuestionModel> getQuestionsByIds(List<String> ids) {
    if (ids.isEmpty) return [];
    
    final List<QuestionModel> list = [];
    final idSet = ids.toSet();
    
    // 1. Scan contentBox subjects (which contains baseline dummy questions)
    final contentBox = Hive.box<SubjectModel>(CachingService.contentBoxName);
    for (var subject in contentBox.values) {
      for (var topic in subject.topics) {
        for (var mock in topic.mocks) {
          for (var q in mock.questions) {
            if (idSet.contains(q.id) && !list.any((existing) => existing.id == q.id)) {
              list.add(q);
            }
          }
        }
      }
    }
    
    // 2. Scan questionsCacheBox (which contains dynamically downloaded questions)
    final cacheBox = Hive.box<List<dynamic>>(CachingService.questionsCacheBoxName);
    for (var qList in cacheBox.values) {
      for (var qObj in qList) {
        if (qObj is QuestionModel && idSet.contains(qObj.id) && !list.any((existing) => existing.id == qObj.id)) {
          list.add(qObj);
        }
      }
    }
    
    return list;
  }
  // --- Mistakes (Galatiyan) ---
  static List<String> getMistakes() {
    final box = Hive.box<List<String>>(CachingService.mistakeBoxName);
    return box.get('mistakes', defaultValue: []) ?? [];
  }

  static Future<void> addMistake(String questionId) async {
    final box = Hive.box<List<String>>(CachingService.mistakeBoxName);
    final mistakes = getMistakes();
    if (!mistakes.contains(questionId)) {
      mistakes.add(questionId);
      await box.put('mistakes', mistakes);
    }
  }

  static Future<void> removeMistake(String questionId) async {
    final box = Hive.box<List<String>>(CachingService.mistakeBoxName);
    final mistakes = getMistakes();
    mistakes.remove(questionId);
    await box.put('mistakes', mistakes);
  }

  // --- Bookmarks (Star/Saved) ---
  static List<String> getBookmarks() {
    final box = Hive.box<List<String>>(CachingService.bookmarkBoxName);
    return box.get('bookmarks', defaultValue: []) ?? [];
  }

  static Future<void> toggleBookmark(String questionId) async {
    final box = Hive.box<List<String>>(CachingService.bookmarkBoxName);
    final bookmarks = getBookmarks();
    if (bookmarks.contains(questionId)) {
      bookmarks.remove(questionId);
    } else {
      bookmarks.add(questionId);
    }
    await box.put('bookmarks', bookmarks);
  }

  static bool isBookmarked(String questionId) {
    return getBookmarks().contains(questionId);
  }

  // --- Daily Streak (Lagatar Practice) ---
  static int getStreak() {
    final box = Hive.box(CachingService.settingsBoxName);
    return box.get('streak', defaultValue: 0) as int;
  }

  static List<String> getPracticeDates() {
    final box = Hive.box(CachingService.settingsBoxName);
    final List<dynamic> list = box.get('practice_dates', defaultValue: []) ?? [];
    return list.cast<String>().toList();
  }

  static Future<void> updateStreak() async {
    final box = Hive.box(CachingService.settingsBoxName);
    final lastPracticeStr = box.get('last_practice_date', defaultValue: '') as String;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final List<dynamic> dates = box.get('practice_dates', defaultValue: []) ?? [];
    final List<String> datesList = dates.cast<String>().toList();
    if (!datesList.contains(todayStr)) {
      datesList.add(todayStr);
      await box.put('practice_dates', datesList);
    }

    if (lastPracticeStr != todayStr) {
      if (lastPracticeStr.isNotEmpty) {
        final lastPracticeDate = DateTime.parse(lastPracticeStr);
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        
        if (lastPracticeDate.year == yesterday.year && 
            lastPracticeDate.month == yesterday.month && 
            lastPracticeDate.day == yesterday.day) {
          // Continued streak
          int streak = getStreak();
          await box.put('streak', streak + 1);
        } else {
          // Streak broken
          await box.put('streak', 1);
        }
      } else {
        // First time
        await box.put('streak', 1);
      }
      await box.put('last_practice_date', todayStr);
    }
  }

  // --- Progress Tracking (Kitna syllabus hua) ---
  static Future<void> updateProgress(String chapterId, int correct, int totalAttempted) async {
    final box = Hive.box(CachingService.progressBoxName);
    // Storing as a map: { 'correct': X, 'attempted': Y }
    final currentProgress = box.get(chapterId, defaultValue: {'correct': 0, 'attempted': 0});
    
    currentProgress['correct'] = (currentProgress['correct'] ?? 0) + correct;
    currentProgress['attempted'] = (currentProgress['attempted'] ?? 0) + totalAttempted;
    
    await box.put(chapterId, currentProgress);
  }

  static Map<dynamic, dynamic> getProgress(String chapterId) {
    final box = Hive.box(CachingService.progressBoxName);
    return box.get(chapterId, defaultValue: {'correct': 0, 'attempted': 0});
  }

  static Map<String, int> getTopicProgress(TopicModel topic) {
    int totalAttempted = 0;
    int totalQuestions = 0;
    
    for (var mock in topic.mocks) {
      final progress = getProgress(mock.mockId);
      final attempted = progress['attempted'] as int? ?? 0;
      totalAttempted += attempted;
      
      int mockTotal = 0;
      if (mock.questions.isNotEmpty) {
        mockTotal = mock.questions.length;
      } else {
        if (mock.mockId.startsWith('mock_animal_kingdom_')) {
          if (mock.mockId == 'mock_animal_kingdom_6') {
            mockTotal = 21;
          } else {
            mockTotal = 30;
          }
        } else {
          mockTotal = 15;
        }
      }
      totalQuestions += mockTotal;
    }
    
    if (totalQuestions == 0) totalQuestions = 30;
    
    // Cap attempted count to total questions
    if (totalAttempted > totalQuestions) {
      totalAttempted = totalQuestions;
    }
    
    return {
      'attempted': totalAttempted,
      'total': totalQuestions,
    };
  }

  static double getSubjectProgress(SubjectModel subject) {
    int totalAttempted = 0;
    int totalQuestions = 0;
    for (var topic in subject.topics) {
      final topicProgress = getTopicProgress(topic);
      totalAttempted += topicProgress['attempted'] ?? 0;
      totalQuestions += topicProgress['total'] ?? 0;
    }
    return totalQuestions > 0 ? totalAttempted / totalQuestions : 0.0;
  }
}
