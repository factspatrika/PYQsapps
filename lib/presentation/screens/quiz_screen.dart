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
          'Railway Prep',
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: theme.dividerColor),
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
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64.0 : 20.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          const SizedBox(height: 32),
                          sidebarContent,
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
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(theme, isDark, 'Accuracy', '84%')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(theme, isDark, 'Timer', '12:45')),
          ],
        ),
        const SizedBox(height: 16),
        
        // Main Question Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
              Row(
                children: [
                  Icon(Icons.history_edu, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'RRB ALP 2018, Group D 2022',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Dynamic Question Body
              _buildQuestionBody(theme, isDark, question),
              
              const SizedBox(height: 24),
              
              // Options
              _buildOptionsGrid(theme, isDark, question),
              
              // Explanation card (displays after option is selected)
              if (selectedOptionIndex != null && question.explanation.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildExplanationCard(theme, isDark, question),
              ],
              
              const SizedBox(height: 48),
              
              // Action Buttons
              _buildActionButtons(theme, isDark),
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
        return RichText(
          text: TextSpan(
            style: TextStyle(color: titleColor, fontSize: 16, fontFamily: 'Be Vietnam Pro'),
            children: [
              TextSpan(
                text: 'Q.${(currentIndex + 1).toString().padLeft(2, '0')}: ',
                style: TextStyle(color: subtitleColor, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: question.question,
                style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
        
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'कथनों पर विचार करें:',
              style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F3FF),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: theme.colorScheme.primary, width: 4),
                ),
              ),
              child: Column(
                children: List.generate(question.statements?.length ?? 0, (idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${idx + 1}.',
                          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.statements![idx],
                            style: TextStyle(color: titleColor, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        );
    }
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: width,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: letterBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.transparent : theme.dividerColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ['A','B','C','D'][index],
                          style: TextStyle(color: letterColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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
        color: isDark 
            ? const Color(0xFF1E293B) 
            : const Color(0xFFFFFBEB), // Amber 50
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? const Color(0xFF334155) 
              : const Color(0xFFFDE68A), // Amber 200
        ),
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
          Text(
            question.explanation,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(ThemeData theme, bool isDark) {
    bool isLast = currentIndex == widget.mock.questions.length - 1;
    final textStyle = TextStyle(color: theme.colorScheme.onSurfaceVariant);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.report, color: theme.colorScheme.onSurfaceVariant, size: 20),
          label: Text('गलत है?', style: textStyle),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(width: 12),
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
        ),
      ],
    );
  }
  
  Widget _buildStatCard(ThemeData theme, bool isDark, String label, String value) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : const Color(0xFFF0F3FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
