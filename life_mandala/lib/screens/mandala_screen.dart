import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'goal_detail_sheet.dart';
import 'onboarding_screen.dart';

class MandalaScreen extends StatefulWidget {
  final MandalaData initialData;
  const MandalaScreen({super.key, required this.initialData});

  @override
  State<MandalaScreen> createState() => _MandalaScreenState();
}

class _MandalaScreenState extends State<MandalaScreen> {
  late MandalaData _data;
  final TransformationController _transformController = TransformationController();

  static const double cellSize = 46.0;
  static const double innerGap = 2.0;
  static const double blockGap = 8.0;

  double _fitScale = 1.0;
  bool _hasSetInitialScale = false;
  bool _zoomedIn = false;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
  }

  Future<void> _save() async {
    await StorageService.save(_data);
    if (mounted) setState(() {});
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Pillar _pillarAt(int index) => _data.pillars.firstWhere((p) => p.index == index);

  Goal _goalFor(String pillarId, int position) =>
      _data.goals.firstWhere((g) => g.pillarId == pillarId && g.position == position);

  DailyStatus _todayStatus(String goalId) {
    final today = _todayKey();
    final matches = _data.records.where((r) => r.goalId == goalId && r.date == today);
    if (matches.isEmpty) return DailyStatus.notStarted;
    return matches.first.status;
  }

  void _resetView() {
    _transformController.value = Matrix4.identity()..scale(_fitScale);
    _zoomedIn = false;
  }

  void _handleDoubleTap() {
    final target = _zoomedIn ? _fitScale : _fitScale * 2.2;
    _transformController.value = Matrix4.identity()..scale(target);
    setState(() => _zoomedIn = !_zoomedIn);
  }

  void _editMainGoal() {
    final titleController = TextEditingController(text: _data.mainGoalTitle);
    final descController = TextEditingController(text: _data.mainGoalDescription);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Main goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Who do you want to become?'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              _data.mainGoalTitle = titleController.text.trim();
              _data.mainGoalDescription = descController.text.trim();
              Navigator.pop(ctx);
              _save();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editPillar(Pillar pillar) {
    final nameController = TextEditingController(text: pillar.name);
    final descController = TextEditingController(text: pillar.description);
    Color selectedColor = Color(pillar.color);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pillar', style: TextStyle(color: selectedColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Description (optional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: defaultPillarColors.map((c) {
                      final sel = c.value == selectedColor.value;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = c),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: sel ? Border.all(color: Colors.black87, width: 3) : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) return;
                          pillar.name = nameController.text.trim();
                          pillar.description = descController.text.trim();
                          pillar.color = selectedColor.value;
                          Navigator.pop(ctx);
                          _save();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _openGoal(Goal goal, Pillar pillar) {
    final records = _data.records.where((r) => r.goalId == goal.id).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GoalDetailSheet(
          goal: goal,
          pillar: pillar,
          records: records,
          onEdit: (name, desc) {
            goal.name = name;
            goal.description = desc;
            _save();
          },
          onStatusChange: (status) {
            final today = _todayKey();
            final existingIndex =
                _data.records.indexWhere((r) => r.goalId == goal.id && r.date == today);
            if (existingIndex >= 0) {
              _data.records[existingIndex].status = status;
            } else {
              _data.records.add(DailyRecord(goalId: goal.id, date: today, status: status));
            }
            _save();
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _confirmResetAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset application'),
        content: const Text(
            'This permanently deletes your entire Mandala and all history. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await StorageService.clear();
              if (!mounted) return;
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => OnboardingScreen(
                    onComplete: (data) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => MandalaScreen(initialData: data)),
                      );
                    },
                  ),
                ),
                (route) => false,
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = cellSize * 9 + innerGap * 6 + blockGap * 2;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _data.mainGoalTitle.isEmpty ? 'Life Mandala' : _data.mainGoalTitle,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Fit to screen',
            onPressed: _resetView,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reset_all') _confirmResetAll();
              if (v == 'edit_main') _editMainGoal();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit_main', child: Text('Edit main goal')),
              const PopupMenuItem(value: 'reset_all', child: Text('Reset application')),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = ((constraints.maxWidth - 32) / gridWidth).clamp(0.3, 1.2);
          if (!_hasSetInitialScale) {
            _fitScale = scale;
            _hasSetInitialScale = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _transformController.value = Matrix4.identity()..scale(_fitScale);
            });
          }
          return GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.3,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(300),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildGrid(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    final rows = <Widget>[];
    for (int r = 0; r < 9; r++) {
      final rowCells = <Widget>[];
      for (int c = 0; c < 9; c++) {
        rowCells.add(_buildCell(r, c));
        if (c != 8) rowCells.add(SizedBox(width: (c % 3 == 2) ? blockGap : innerGap));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: rowCells));
      if (r != 8) rows.add(SizedBox(height: (r % 3 == 2) ? blockGap : innerGap));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _buildCell(int row, int col) {
    final blockRow = row ~/ 3;
    final blockCol = col ~/ 3;
    final localRow = row % 3;
    final localCol = col % 3;

    // The center 3x3 block: main goal at its very center, mirrored
    // pillar names on the 8 surrounding cells (classic Mandala layout).
    if (blockRow == 1 && blockCol == 1) {
      if (localRow == 1 && localCol == 1) {
        return _cellBox(
          onTap: _editMainGoal,
          bgColor: const Color(0xFF1B1B1B),
          textColor: Colors.white,
          text: _data.mainGoalTitle.isEmpty ? 'Tap to add\nyour main goal' : _data.mainGoalTitle,
          bold: true,
        );
      }
      final pIdx = order8.indexWhere((p) => p[0] == localRow && p[1] == localCol);
      final pillar = _pillarAt(pIdx);
      final color = Color(pillar.color);
      return _cellBox(
        onTap: () => _editPillar(pillar),
        bgColor: lighten(color, 0.32),
        textColor: darken(color, 0.35),
        text: pillar.isEmpty ? 'Pillar ${pIdx + 1}' : pillar.name,
      );
    }

    // One of the 8 pillar blocks.
    final blockIdx = order8.indexWhere((p) => p[0] == blockRow && p[1] == blockCol);
    final pillar = _pillarAt(blockIdx);
    final color = Color(pillar.color);

    if (localRow == 1 && localCol == 1) {
      return _cellBox(
        onTap: () => _editPillar(pillar),
        bgColor: color,
        textColor: Colors.white,
        text: pillar.isEmpty ? 'Pillar ${blockIdx + 1}' : pillar.name,
        bold: true,
      );
    }

    final goalPos = order8.indexWhere((p) => p[0] == localRow && p[1] == localCol);
    final goal = _goalFor(pillar.id, goalPos);
    final status = _todayStatus(goal.id);
    return _cellBox(
      onTap: () => _openGoal(goal, pillar),
      bgColor: lighten(color, 0.42),
      textColor: darken(color, 0.4),
      text: goal.isEmpty ? '+' : goal.name,
      statusColor: goal.isEmpty ? null : _statusIndicatorColor(status),
    );
  }

  Color? _statusIndicatorColor(DailyStatus s) {
    switch (s) {
      case DailyStatus.done:
        return const Color(0xFF4CAF50);
      case DailyStatus.partial:
        return const Color(0xFFFFB300);
      case DailyStatus.notDone:
        return const Color(0xFFE57373);
      case DailyStatus.notStarted:
        return null;
    }
  }

  Widget _cellBox({
    required VoidCallback onTap,
    required Color bgColor,
    required Color textColor,
    required String text,
    bool bold = false,
    Color? statusColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: statusColor != null ? Border.all(color: statusColor, width: 2) : null,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(3),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 8.5,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
