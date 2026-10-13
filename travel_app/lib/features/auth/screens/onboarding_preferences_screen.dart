import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/ai_backend_service.dart';
import '../../../core/services/realtime_recommender_service.dart';
import '../../auth/provider/auth_providers.dart';
import '../../../core/routing/app_routes.dart';

class OnboardingPreferencesScreen extends ConsumerStatefulWidget {
  const OnboardingPreferencesScreen({super.key});

  @override
  ConsumerState<OnboardingPreferencesScreen> createState() => _OnboardingPreferencesScreenState();
}

class _CompanionOption {
  final String label;
  final String firestoreValue;
  final IconData icon;
  final String description;

  const _CompanionOption({
    required this.label,
    required this.firestoreValue,
    required this.icon,
    required this.description,
  });
}

class _BudgetOption {
  final String label;
  final String firestoreValue;
  final String symbol;
  final String description;

  const _BudgetOption({
    required this.label,
    required this.firestoreValue,
    required this.symbol,
    required this.description,
  });
}

class _OnboardingPreferencesScreenState extends ConsumerState<OnboardingPreferencesScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<String> _allInterests = [
    'Biển đảo', 'Leo núi', 'Ẩm thực', 'Văn hóa', 
    'Cắm trại', 'Nghỉ dưỡng', 'Mạo hiểm', 'Chụp ảnh',
    'Lịch sử', 'Mua sắm', 'Tâm linh', 'Sinh thái',
    'Lễ hội', 'Thể thao', 'Sông nước', 'Vườn quốc gia'
  ];

  final List<_CompanionOption> _companionOptions = const [
    _CompanionOption(
      label: 'Đi một mình',
      firestoreValue: 'Một mình',
      icon: Icons.person_outline_rounded,
      description: 'Tự do khám phá bản thân và hành trình riêng',
    ),
    _CompanionOption(
      label: 'Cặp đôi',
      firestoreValue: 'Cặp đôi',
      icon: Icons.favorite_border_rounded,
      description: 'Chuyến đi lãng mạn cùng người thương',
    ),
    _CompanionOption(
      label: 'Gia đình',
      firestoreValue: 'Gia đình',
      icon: Icons.family_restroom_rounded,
      description: 'Ấm áp, an toàn cho mọi lứa tuổi thành viên',
    ),
    _CompanionOption(
      label: 'Nhóm bạn',
      firestoreValue: 'Nhóm bạn',
      icon: Icons.groups_outlined,
      description: 'Cháy hết mình cùng những người bạn thân',
    ),
  ];

  final List<_BudgetOption> _budgetOptions = const [
    _BudgetOption(
      label: 'Tiết kiệm',
      firestoreValue: '\$',
      symbol: '₫',
      description: 'Tập trung trải nghiệm thực tế, chi phí tối giản',
    ),
    _BudgetOption(
      label: 'Hợp lý',
      firestoreValue: '\$\$',
      symbol: '₫₫',
      description: 'Cân bằng giữa tiện nghi dịch vụ và ngân sách',
    ),
    _BudgetOption(
      label: 'Sang chảnh',
      firestoreValue: '\$\$\$',
      symbol: '₫₫₫',
      description: 'Tận hưởng nghỉ dưỡng sang trọng, dịch vụ cao cấp',
    ),
  ];

  final Set<String> _selectedInterests = {};
  final Set<String> _selectedCompanions = {};
  String _selectedBudget = '\$\$';
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _toggleCompanion(String companion) {
    setState(() {
      if (_selectedCompanions.contains(companion)) {
        _selectedCompanions.remove(companion);
      } else {
        _selectedCompanions.add(companion);
      }
    });
  }

  void _selectBudget(String budget) {
    setState(() {
      _selectedBudget = budget;
    });
  }

  bool _isStepValid() {
    if (_currentStep == 0) return _selectedInterests.length >= 3;
    if (_currentStep == 1) return _selectedCompanions.isNotEmpty;
    return _selectedBudget.isNotEmpty;
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(userInfoProvider);
      final userId = user?.uid ?? const Uuid().v4();
      
      // 1. Save preferences locally and sync to Firestore user_profiles (instant cold-start)
      await ref.read(realtimeRecommenderProvider.notifier).setInitialPreferences(
        userId,
        interests: _selectedInterests.toList(),
        suitableFor: _selectedCompanions.toList(),
        budgetLevel: _selectedBudget,
      );

      // 2. Call backend AI recommendation service for synchronization
      final combinedInterests = [
        ..._selectedInterests,
        ..._selectedCompanions,
        _selectedBudget,
      ];
      await ref.read(aiBackendServiceProvider).saveUserPreferences(
        userId, 
        combinedInterests,
      );

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Lỗi khi lưu sở thích: ${e.toString()}',
              style: GoogleFonts.beVietnamPro(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _isStepValid();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                onPressed: _prevStep,
              )
            : null,
        title: Column(
          children: [
            Text(
              'Bước ${_currentStep + 1} / 3',
              style: GoogleFonts.beVietnamPro(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 120,
                height: 6,
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentStep = page;
                  });
                },
                children: [
                  _buildInterestsStep(theme),
                  _buildCompanionStep(theme),
                  _buildBudgetStep(theme),
                ],
              ),
            ),
            
            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isValid && !_isLoading ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: isValid ? 2 : 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _currentStep == 2 ? 'Hoàn tất & Bắt đầu' : 'Tiếp theo',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Core Interests
  Widget _buildInterestsStep(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Sở thích du lịch của bạn ✈️',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy chọn ít nhất 3 gu du lịch bạn yêu thích nhất để chúng tôi gợi ý điểm đến hoàn hảo.',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 130,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final interest = _allInterests[index];
                final isSelected = _selectedInterests.contains(interest);
                return _InterestChip(
                  label: interest,
                  isSelected: isSelected,
                  onTap: () => _toggleInterest(interest),
                );
              },
              childCount: _allInterests.length,
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: Companions
  Widget _buildCompanionStep(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      children: [
        Text(
          'Bạn thường đi du lịch cùng ai? 👥',
          style: GoogleFonts.beVietnamPro(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chọn những đối tượng bạn thường đồng hành (bạn có thể chọn nhiều hơn một mục).',
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ..._companionOptions.map((option) {
          final isSelected = _selectedCompanions.contains(option.firestoreValue);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => _toggleCompanion(option.firestoreValue),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey[100],
                      child: Icon(
                        option.icon,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? theme.colorScheme.primary : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.description,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // STEP 3: Budget Level
  Widget _buildBudgetStep(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      children: [
        Text(
          'Mức chi tiêu mong muốn? 💰',
          style: GoogleFonts.beVietnamPro(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hãy chọn mức ngân sách phù hợp để chúng tôi sắp xếp chi phí và giá vé tham khảo hợp lý.',
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ..._budgetOptions.map((option) {
          final isSelected = _selectedBudget == option.firestoreValue;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => _selectBudget(option.firestoreValue),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option.symbol,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? theme.colorScheme.primary : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.description,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.radio_button_checked_rounded, color: theme.colorScheme.primary)
                    else
                      Icon(Icons.radio_button_off_rounded, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: 13,
            color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
