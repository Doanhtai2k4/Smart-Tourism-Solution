import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_app/features/addtrip/screens/trip_creation_data.dart';
import 'package:travel_app/features/addtrip/screens/widgets/date_budget_step.dart';
import 'package:travel_app/features/addtrip/screens/widgets/destination_step.dart';
import 'package:travel_app/features/addtrip/screens/widgets/navigation_button.dart';
import 'package:travel_app/features/addtrip/screens/widgets/personal_preference_step.dart';
import 'package:travel_app/features/addtrip/screens/widgets/stepper_header.dart';
import 'package:travel_app/features/addtrip/screens/widgets/travel_preference_step.dart';
import 'package:travel_app/features/addtrip/screens/widgets/summary_step.dart';
import 'package:travel_app/core/enums/currency.dart';
import 'package:travel_app/core/enums/budget_type.dart';
import 'package:travel_app/core/enums/trip_step.dart';

import '../../../core/common/app_snackbar.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/utilities/trip_step_titiles.dart';
import '../../../core/utilities/trip_step_validator.dart';
import '../../trip/screen/widgets/flight_loading_view.dart';
import '../models/trip_plan_request.dart';
import '../providers/travel_provider.dart';
import '../../auth/provider/auth_providers.dart';
import '../../trip/provider/user_trips_provider.dart';
import '../../trip/repository/user_trips_repository.dart';
import '../../../core/extensions/context_snackbar.dart';
import '../../../shared/models/travel_db_model.dart';

class AddTripPage extends ConsumerStatefulWidget {
  final String? initialDestination;
  final TravelDbModel? existingTrip;
  const AddTripPage({super.key, this.initialDestination, this.existingTrip});

  @override
  ConsumerState<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends ConsumerState<AddTripPage> {
  final _pageController = PageController();
  final _data = TripCreationData();

  @override
  void initState() {
    super.initState();
    if (widget.existingTrip != null) {
      final trip = widget.existingTrip!;
      _data.currentLocation.text = trip.currentLocation ?? '';
      _data.destination.text = trip.destination;
      _data.startDate = trip.startDate;
      _data.endDate = trip.endDate;
      _data.startDateText.text = DateFormat('dd/MM/yyyy').format(trip.startDate);
      _data.endDateText.text = DateFormat('dd/MM/yyyy').format(trip.endDate);
      final savedBudget = trip.budget ?? '';
      final budgetMatch = RegExp(r'\d[\d.,]*').firstMatch(savedBudget);
      _data.budget.text = budgetMatch?.group(0) ?? savedBudget;
      _data.tripType = trip.tripType;
      _data.interests = List.from(trip.interests);
      _data.companion = trip.companions ?? '';
      _data.accommodation = trip.accommodationType ?? '';
      _data.transport = trip.transportPreferences ?? '';
      _data.pace = trip.pace ?? '';
      _data.food = trip.foodPreference ?? '';
      _data.specialRequirements.text = trip.overview ?? '';
      
      if (trip.budgetType != null && trip.budgetType!.isNotEmpty) {
        try {
          _data.budgetType = BudgetType.values.firstWhere((e) => e.payload == trip.budgetType);
        } catch (_) {}
      }
    } else if (widget.initialDestination != null) {
      _data.destination.text = widget.initialDestination!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tự động thiết lập tiền tệ dựa trên ngôn ngữ nếu người dùng chưa thay đổi
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    if (isVi && _data.currency == Currency.usd) {
      _data.currency = Currency.vnd;
    } else if (!isVi && _data.currency == Currency.vnd) {
      _data.currency = Currency.usd;
    }
  }

  TripStep _currentStep = TripStep.destination;

  static final int _totalSteps = TripStep.values.length;

  @override
  void dispose() {
    _pageController.dispose();
    _data.dispose();
    super.dispose();
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    final isValid = TripStepValidator.isValid(step: _currentStep, data: _data);

    if (!isValid) {
      AppSnackBar.show(
        context,
        message: context.l10n.failedCreateTrip,
        type: SnackType.error,
      );
      return;
    }

    if (_currentStep.index < _totalSteps - 1) {
      setState(() {
        _currentStep = TripStep.values[_currentStep.index + 1];
      });

      _pageController.animateToPage(
        _currentStep.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitTrip();
    }
  }

  void _previousStep() {
    if (_currentStep.index == 0) return;

    setState(() {
      _currentStep = TripStep.values[_currentStep.index - 1];
    });

    _pageController.animateToPage(
      _currentStep.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitTrip() async {
    final loading = ref.read(submitLoadingProvider.notifier);
    loading.setLoading(true);

    try {
      final budget =
          double.tryParse(_data.budget.text.replaceAll(',', '')) ?? 0.0;

      final request = TripPlanRequest(
        userId: widget.existingTrip?.userId ?? ref.read(userInfoProvider)?.uid,
        currentLocation: _data.currentLocation.text.trim(),
        destination: _data.destination.text.trim(),
        startDate: _data.startDate!,
        endDate: _data.endDate!,
        tripType: _data.tripType?.name ?? '',
        budget: budget,
        budgetType: _data.budgetType.payload,
        currency: Localizations.localeOf(context).languageCode == 'vi' ? 'VND' : 'USD',
        interests: _data.interests,
        companions: _data.companion,
        accommodationType: _data.accommodation,
        transportPreferences: _data.transport,
        pace: _data.pace,
        food: _data.food,
        mustVisitPlaceIds: _data.mustVisitPlaceIds,
        specialRequirements: _data.specialRequirements.text.trim(),
        ownerName: widget.existingTrip?.ownerName ?? ref.read(userInfoProvider)?.name,
        ownerPhoto: widget.existingTrip?.ownerPhoto ?? ref.read(userInfoProvider)?.profilePic,
        saveToDatabase: widget.existingTrip == null,
      );

      if (widget.existingTrip != null) {
        // Edit mode: Replace AI content
        final repo = ref.read(userTripsRepositoryProvider);
        final locale = Localizations.localeOf(context);
        await repo.replaceAiTripContent(
          travelId: widget.existingTrip!.travelId,
          request: request,
          language: locale.languageCode,
        );
        
        if (mounted) {
          context.showSuccessSnack("Kế hoạch đã được tái thiết lập thành công!");
          context.pop(); // Quay lại trang chi tiết
          ref.invalidate(tripByIdProvider(widget.existingTrip!.travelId));
        }
      } else {
        // Creation mode
        final travelId = await ref.read(
          generateAndStoreTripProvider(request).future,
        );

        if (mounted) {
          context.pushReplacementNamed(
            'trip',
            pathParameters: {'travelId': travelId},
            extra: {'fromCreation': true},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
          type: SnackType.error,
        );
      }
    } finally {
      loading.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái loading từ provider
    final isLoading = ref.watch(submitLoadingProvider);

    final progress = (_currentStep.index + 1) / _totalSteps;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // Vô hiệu hóa nút quay lại khi đang trong quá trình cất cánh (tạo trip)
            onPressed: isLoading ? null : () => context.pop(),
          ),
          title: Text(context.l10n.planYourTrip),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colors.surface,
                      context.colors.surface,
                    ],
                  ),
                ),
              ),
            ),
  
  
            // LỚP 1: Luôn luôn hiển thị giao diện Form nhập liệu
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  StepperHeader(
                    progress: progress,
                    stepText: context.l10n.stepOf(
                      _currentStep.index + 1,
                      _totalSteps,
                    ),
                    stepTitle: TripStepTitles.title(context, _currentStep),
                  ),
                  Expanded(child: _buildPageView()),
  
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: keyboardOpen
                        ? const SizedBox.shrink()
                        : _buildNavigationButtons(),
                  ),
                ],
              ),
            ),
  
            // LỚP 2: Lớp phủ máy bay cất cánh (Chỉ hiện khi isLoading = true)
            if (isLoading) const FlightLoadingView(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DestinationStep(
          currentLocationController: _data.currentLocation,
          destinationController: _data.destination,
          selectedTripType: _data.tripType,
          onTripTypeChanged: (v) => setState(() => _data.tripType = v),
        ),
        DateBudgetStep(
          startDateController: _data.startDateText,
          endDateController: _data.endDateText,
          budgetController: _data.budget,
          startDate: _data.startDate,
          endDate: _data.endDate,
          selectedBudgetType: _data.budgetType,
          onBudgetTypeChanged: (v) => setState(() => _data.budgetType = v),
          onStartDateChanged: (d) {
            setState(() {
              _data.startDate = d;
              _data.startDateText.text = DateFormat('dd/MM/yyyy').format(d);
            });
          },
          onEndDateChanged: (d) {
            setState(() {
              _data.endDate = d;
              _data.endDateText.text = DateFormat('dd/MM/yyyy').format(d);
            });
          },
        ),
        PersonalPreferencesStep(
          selectedInterests: _data.interests,
          selectedCompanion: _data.companion,
          onInterestsChanged: (v) => setState(() => _data.interests = v),
          onCompanionChanged: (v) => setState(() => _data.companion = v),
          specialRequirementsController: _data.specialRequirements,
          mustVisitPlaceIds: _data.mustVisitPlaceIds,
          onMustVisitPlaceIdsChanged: (v) =>
              setState(() => _data.mustVisitPlaceIds = v),
          selectedDestination: _data.destination.text.trim(),
        ),
        TravelPreferencesStep(
          accommodation: _data.accommodation,
          transport: _data.transport,
          pace: _data.pace,
          food: _data.food,
          onAccommodationChanged:
              (v) => setState(() => _data.accommodation = v),
          onTransportChanged: (v) => setState(() => _data.transport = v),
          onPaceChanged: (v) => setState(() => _data.pace = v),
          onFoodChanged: (v) => setState(() => _data.food = v),
        ),
        SummaryStep(data: _data),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final cs = context.colors;
    final isLoading = ref.watch(submitLoadingProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
            if (_currentStep.index > 0) ...[
              Expanded(
                child: NavigationButton(
                  label: context.l10n.back,
                  onPressed: _previousStep,
                  isSecondary: true,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: NavigationButton(
                label:
                    _currentStep.index == _totalSteps - 1
                        ? context.l10n.createTrip
                        : context.l10n.next,
                icon:
                    _currentStep.index == _totalSteps - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                onPressed: _nextStep,
                isLoading: _currentStep.index == _totalSteps - 1 && isLoading,
              ),
            ),
        ],
      ),
    );
  }
}
