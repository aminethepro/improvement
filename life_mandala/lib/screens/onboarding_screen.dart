import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final MandalaData? existing;
  final void Function(MandalaData) onComplete;
  const OnboardingScreen({super.key, this.existing, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _step = 0;

  final _mainGoalController = TextEditingController();
  final _mainDescController = TextEditingController();

  late List<TextEditingController> _pillarNameControllers;
  late List<TextEditingController> _pillarDescControllers;
  late List<Color> _pillarColors;

  static const int _totalSteps = 9; // 1 main goal page + 8 pillar pages

  @override
  void initState() {
    super.initState();
    _pillarNameControllers = List.generate(8, (_) => TextEditingController());
    _pillarDescControllers = List.generate(8, (_) => TextEditingController());
    _pillarColors = List.from(defaultPillarColors);
  }

  @override
  void dispose() {
    _mainGoalController.dispose();
    _mainDescController.dispose();
    for (final c in _pillarNameControllers) {
      c.dispose();
    }
    for (final c in _pillarDescControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _next() {
    if (_step == 0 && _mainGoalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your main goal to continue.')),
      );
      return;
    }
    if (_step < _totalSteps - 1) {
      _goTo(_step + 1);
    } else {
      _finish();
    }
  }

  void _skipPillar() {
    final idx = _step - 1;
    if (_pillarNameControllers[idx].text.trim().isEmpty) {
      _pillarNameControllers[idx].text = 'Pillar ${idx + 1}';
    }
    _next();
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  Future<void> _finish() async {
    final pillars = <Pillar>[];
    final goals = <Goal>[];
    for (int i = 0; i < 8; i++) {
      final pillarId = 'pillar_$i';
      final name = _pillarNameControllers[i].text.trim();
      pillars.add(Pillar(
        id: pillarId,
        index: i,
        name: name.isEmpty ? 'Pillar ${i + 1}' : name,
        description: _pillarDescControllers[i].text.trim(),
        color: _pillarColors[i].value,
      ));
      for (int j = 0; j < 8; j++) {
        goals.add(Goal(id: '${pillarId}_goal_$j', pillarId: pillarId, position: j));
      }
    }
    final data = MandalaData(
      mainGoalTitle: _mainGoalController.text.trim(),
      mainGoalDescription: _mainDescController.text.trim(),
      pillars: pillars,
      goals: goals,
      records: [],
    );
    await StorageService.save(data);
    widget.onComplete(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _totalSteps,
                  minHeight: 6,
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMainGoalPage(),
                  for (int i = 0; i < 8; i++) _buildPillarPage(i),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(onPressed: _back, child: const Text('Back')),
                  const Spacer(),
                  if (_step >= 1)
                    TextButton(onPressed: _skipPillar, child: const Text('Skip for now')),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_step == _totalSteps - 1 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Who do you want to become?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'This becomes the center of your Mandala — your one guiding life goal.',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _mainGoalController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Main goal',
              hintText: 'e.g. Become the best version of myself',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mainDescController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarPage(int i) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Pillar ${i + 1} of 8', style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Name a major area of your life',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _pillarNameControllers[i],
            decoration: const InputDecoration(
              labelText: 'Pillar name',
              hintText: 'e.g. Health, Career, Faith, Family',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pillarDescControllers[i],
            decoration: const InputDecoration(
              labelText: 'Short description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: defaultPillarColors.map((c) {
              final selected = _pillarColors[i].value == c.value;
              return GestureDetector(
                onTap: () => setState(() => _pillarColors[i] = c),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected ? Border.all(color: Colors.black87, width: 3) : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
