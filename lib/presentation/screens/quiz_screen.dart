import 'package:flutter/material.dart';
import '../../data/models/hive_models.dart';
import '../../data/repositories/tracking_service.dart';
import '../widgets/ad_banner_widget.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final MockModel mock;

  const QuizScreen({super.key, required this.mock});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int? selectedOptionIndex;
  List<int?> userAnswers = [];

  // Drag coordinates for custom smooth swiping
  double _dragStartX = 0.0;
  double _dragOffset = 0.0;
  
  @override
  void initState() {
    super.initState();
    userAnswers = List.filled(widget.mock.questions.length, null);
  }

  void _onOptionSelected(int index) {
    setState(() {
      selectedOptionIndex = index;
      userAnswers[currentIndex] = index;
    });
  }

  void _submitTest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(mock: widget.mock, userAnswers: userAnswers),
      ),
    );
  }

  void _nextQuestion() {
    if (currentIndex < widget.mock.questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOptionIndex = userAnswers[currentIndex];
      });
    } else {
      _submitTest();
    }
  }
  
  void _prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        selectedOptionIndex = userAnswers[currentIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.mock.mockName,
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: 16),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final progress = (currentIndex + 1) / widget.mock.questions.length;
              return Stack(
                children: [
                  Container(
                    height: 4,
                    width: constraints.maxWidth,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    height: 4,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFFF59E0B), const Color(0xFFEAB308)]
                            : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                      ),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragStartX = details.globalPosition.dx;
          _dragOffset = 0.0;
        },
        onHorizontalDragUpdate: (details) {
          _dragOffset = details.globalPosition.dx - _dragStartX;
        },
        onHorizontalDragEnd: (details) {
          // Swipe threshold of 60 pixels to trigger next/prev question
          if (_dragOffset.abs() > 60) {
            if (_dragOffset < 0) {
              _nextQuestion();
            } else {
              _prevQuestion();
            }
          }
          _dragOffset = 0.0;
        },
        behavior: HitTestBehavior.translucent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 800;
            
            Widget mainContent = _buildMainContent(theme, isDark);
            Widget sidebarContent = _buildSidebar(theme, isDark);
            
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 16.0, vertical: isDesktop ? 32.0 : 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop) ...[
                      // Breadcrumb & Title
                      Row(
                        children: [
                          Text(
                            'SCIENCE',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          Text(
                            'MOCK TEST',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.mock.mockName,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 8, 
                            child: mainContent,
                          ),
                          const SizedBox(width: 24),
                          Expanded(flex: 4, child: sidebarContent),
                        ],
                      )
                    else
                      Column(
                        children: [
                          mainContent,
                        ],
                      ),
                    const SizedBox(height: 32),
                    const Center(child: AdBannerWidget()),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, bool isDark) {
    final question = widget.mock.questions[currentIndex];

    return Column(
      key: ValueKey(question.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                isDark,
                'Question',
                '${(currentIndex + 1).toString().padLeft(2, '0')}/${widget.mock.questions.length.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(theme, isDark, 'Accuracy', '84%')),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(theme, isDark, 'Timer', '12:45')),
          ],
        ),
        const SizedBox(height: 16),
        
        // Main Question Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [theme.cardColor, const Color(0xFF161B22)] 
                  : [theme.cardColor, const Color(0xFFF8F9FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : theme.colorScheme.primary.withValues(alpha: 0.04),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Medium Difficulty',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      TrackingService.isBookmarked(question.id)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: TrackingService.isBookmarked(question.id)
                          ? const Color(0xFFFED65B)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () async {
                      await TrackingService.toggleBookmark(question.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 14,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${question.examName ?? ""} ${question.examYear ?? ""}'.trim().isEmpty
                            ? 'RRB Exam'
                            : '${question.examName ?? ""} ${question.examYear ?? ""}'.trim(),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Dynamic Question Body
              _buildQuestionBody(theme, isDark, question),
              
              const SizedBox(height: 24),
              
              // Options
              _buildOptionsGrid(theme, isDark, question),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              _buildActionButtons(theme, isDark),
              
              // Explanation card (displays after option is selected - placed below action buttons)
              if (selectedOptionIndex != null && question.explanation.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildExplanationCard(theme, isDark, question),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuestionBody(ThemeData theme, bool isDark, QuestionModel question) {
    final titleColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.colorScheme.onSurfaceVariant;

    switch (question.type) {
      case QuestionType.standard:
      case QuestionType.fillInBlanks:
        return _buildFormattedQuestionText(theme, isDark, question);
        
      case QuestionType.matchFollowing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q.${(currentIndex + 1).toString().padLeft(2, '0')}: ${question.question}',
              style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'List-I',
                        style: TextStyle(color: subtitleColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...?question.matchList1?.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item,
                            style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'List-II',
                        style: TextStyle(color: subtitleColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...?question.matchList2?.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item,
                            style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
        
      case QuestionType.multiStatement:
        return _buildFormattedQuestionText(theme, isDark, question);
    }
  }

  Widget _buildFormattedQuestionText(ThemeData theme, bool isDark, QuestionModel question) {
    final titleColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.colorScheme.onSurfaceVariant;
    final text = question.question;

    List<String> statements = question.statements ?? [];
    String promptText = text;

    if (statements.isEmpty) {
      // Unified statement detection regex for all Hindi & English MCQ formats
      final statementMarkerRegex = RegExp(
        r'(?:(?:कथन|Statement|Assertion|Reason|अभिकथन|कारण)\s*[-–:]*\s*)?(?:\(|\b)(?:I|II|III|IV|V|VI|VII|VIII|IX|X|i|ii|iii|iv|v|vi|vii|viii|[1-9]|[A-E]|[a-e])(?:\)|\s*[:：.]|\s*[\)])',
        caseSensitive: false,
      );
      final matches = statementMarkerRegex.allMatches(text).toList();

      if (matches.length >= 2) {
        int firstMatchIndex = matches.first.start;
        promptText = text.substring(0, firstMatchIndex).trim();

        // Clean trailing "कथन:", "कथन", ":", ",", "•" from promptText
        promptText = promptText
            .replaceAll(RegExp(r'(?:कथन|Statement|Assertion|Reason|अभिकथन|कारण)\s*[:：]*\s*$', caseSensitive: false), '')
            .trim();
        if (promptText.endsWith('।')) {
          // Keep as is
        } else if (promptText.endsWith(',') || promptText.endsWith(':') || promptText.endsWith('：') || promptText.endsWith('•')) {
          promptText = promptText.substring(0, promptText.length - 1).trim();
        }

        for (int i = 0; i < matches.length; i++) {
          int start = matches[i].start;
          int end = (i + 1 < matches.length) ? matches[i + 1].start : text.length;
          String stmt = text.substring(start, end).trim();

          // Clean leading bullet points or extraneous "कथन:" prefixes inside statement item
          stmt = stmt.replaceAll(RegExp(r'^[•\-\*\s]+'), '').trim();
          stmt = stmt.replaceAll(RegExp(r'^(?:कथन|Statement|Assertion|Reason|अभिकथन|कारण)\s*[:：]\s*', caseSensitive: false), '').trim();

          // Remove trailing punctuation like । if it's the last character before next statement
          if (stmt.endsWith('।')) {
            stmt = stmt.substring(0, stmt.length - 1).trim();
          }
          if (stmt.isNotEmpty) {
            statements.add(stmt);
          }
        }
      }
    }

    if (statements.isEmpty) {
      return RichText(
        key: ValueKey('rich_${question.id}'),
        text: TextSpan(
          style: TextStyle(color: titleColor, fontSize: 16, fontFamily: theme.textTheme.bodyLarge?.fontFamily),
          children: [
            TextSpan(
              text: 'Q.${(currentIndex + 1).toString().padLeft(2, '0')}: ',
              style: TextStyle(color: subtitleColor, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: text,
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          key: ValueKey('rich_${question.id}'),
          text: TextSpan(
            style: TextStyle(color: titleColor, fontSize: 16, fontFamily: theme.textTheme.bodyLarge?.fontFamily),
            children: [
              TextSpan(
                text: 'Q.${(currentIndex + 1).toString().padLeft(2, '0')}: ',
                style: TextStyle(color: subtitleColor, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: promptText,
                style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: statements.map((stmt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        stmt,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildOptionsGrid(ThemeData theme, bool isDark, QuestionModel question) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(question.options.length, (index) {
            final isSelected = selectedOptionIndex == index;
            
            Color borderColor = theme.dividerColor;
            Color bgColor = theme.cardColor;
            Color letterBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFDEE8FF);
            Color letterColor = theme.colorScheme.onSurfaceVariant;
            
            if (isSelected) {
              borderColor = theme.colorScheme.primary;
              bgColor = isDark 
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : const Color(0xFFF0F3FF);
              letterBg = theme.colorScheme.primary;
              letterColor = isDark ? theme.scaffoldBackgroundColor : Colors.white;
            }
            
            double width = constraints.maxWidth > 600 
                ? (constraints.maxWidth - 16) / 2 
                : constraints.maxWidth;

            return InkWell(
              onTap: () => _onOptionSelected(index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: width,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: letterBg,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : [],
                        border: Border.all(
                          color: isSelected ? Colors.transparent : theme.dividerColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ['A','B','C','D'][index],
                          style: TextStyle(
                            color: letterColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      }
    );
  }

  Widget _buildExplanationCard(ThemeData theme, bool isDark, QuestionModel question) {
    final correctLetter = ['A', 'B', 'C', 'D'][question.correctIndex];
    final isCorrect = selectedOptionIndex == question.correctIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCorrect
              ? (isDark
                  ? [const Color(0xFF064E3B).withValues(alpha: 0.4), const Color(0xFF022C22).withValues(alpha: 0.4)]
                  : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)])
              : (isDark
                  ? [const Color(0xFF451A03).withValues(alpha: 0.35), const Color(0xFF291002).withValues(alpha: 0.35)]
                  : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]),
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? (isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC))
              : (isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? Colors.green : Colors.amber).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isCorrect ? 'Correct Answer!' : 'Incorrect. Correct option is $correctLetter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isCorrect 
                        ? const Color(0xFF10B981) 
                        : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Explanation / व्याख्या:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          _buildMarkdownText(
            question.explanation,
            TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: theme.textTheme.bodyLarge?.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMarkdownText(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in boldRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
    );
  }
  
  void _showPaletteBottomSheet(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question Palette',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: _buildSidebar(theme, isDark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDark) {
    bool isLast = currentIndex == widget.mock.questions.length - 1;
    final textStyle = TextStyle(color: theme.colorScheme.onSurfaceVariant);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.report, color: theme.colorScheme.onSurfaceVariant, size: 20),
          label: Text('गलत है?', style: textStyle),
        ),
        if (MediaQuery.of(context).size.width <= 800)
          OutlinedButton.icon(
            onPressed: () {
              _showPaletteBottomSheet(context, theme, isDark);
            },
            icon: Icon(Icons.grid_view_rounded, size: 16, color: theme.colorScheme.primary),
            label: Text('प्रश्नावली सूची', style: TextStyle(color: theme.colorScheme.primary)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        OutlinedButton(
          onPressed: _prevQuestion,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(color: theme.colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('पिछला'),
        ),
        ElevatedButton(
          onPressed: _nextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLast ? const Color(0xFF48BB78) : theme.colorScheme.primary,
            foregroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 4,
          ),
          child: Text(isLast ? 'सबमिट करें' : 'अगला'),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(ThemeData theme, bool isDark, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // Palette
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question Palette',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(widget.mock.questions.length, (index) {
                  bool isAnswered = userAnswers[index] != null;
                  bool isCurrent = index == currentIndex;
                  
                  Color bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE7EEFF);
                  Color textColor = theme.colorScheme.onSurfaceVariant;
                  Color borderColor = theme.dividerColor;
                  
                  if (isCurrent) {
                    bgColor = theme.colorScheme.primary;
                    textColor = isDark ? theme.scaffoldBackgroundColor : Colors.white;
                    borderColor = theme.colorScheme.primary;
                  } else if (isAnswered) {
                    bgColor = const Color(0xFF48BB78);
                    textColor = Colors.white;
                    borderColor = const Color(0xFF48BB78);
                  }
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                        selectedOptionIndex = userAnswers[index];
                      });
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegendDot(theme, const Color(0xFF48BB78), 'Answered'),
                  _buildLegendDot(
                    theme,
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFE7EEFF),
                    'Not Visited',
                    hasBorder: true,
                  ),
                  _buildLegendDot(theme, theme.colorScheme.error, 'Flagged'),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot(ThemeData theme, Color color, String label, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder ? Border.all(color: theme.dividerColor) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}
