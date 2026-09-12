import 'package:flutter/material.dart';
import '../models/models.dart';

class GoalDetailSheet extends StatefulWidget {
  final Goal goal;
  final Pillar pillar;
  final List<DailyRecord> records;
  final void Function(String name, String description) onEdit;
  final void Function(DailyStatus status) onStatusChange;

  const GoalDetailSheet({
    super.key,
    required this.goal,
    required this.pillar,
    required this.records,
    required this.onEdit,
    required this.onStatusChange,
  });

  @override
  State<GoalDetailSheet> createState() => _GoalDetailSheetState();
}

class _GoalDetailSheetState extends State<GoalDetailSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late bool _editing;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _descController = TextEditingController(text: widget.goal.description);
    _editing = widget.goal.isEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DailyStatus _statusFor(String dateKey) {
    final matches = widget.records.where((r) => r.date == dateKey);
    if (matches.isEmpty) return DailyStatus.notStarted;
    return matches.first.status;
  }

  Color _statusColor(DailyStatus s) {
    switch (s) {
      case DailyStatus.done:
        return const Color(0xFF4CAF50);
      case DailyStatus.partial:
        return const Color(0xFFFFB300);
      case DailyStatus.notDone:
        return const Color(0xFFE57373);
      case DailyStatus.notStarted:
        return const Color(0xFFE0E0E0);
    }
  }

  IconData _statusIcon(DailyStatus s) {
    switch (s) {
      case DailyStatus.done:
        return Icons.check;
      case DailyStatus.partial:
        return Icons.remove;
      case DailyStatus.notDone:
        return Icons.close;
      case DailyStatus.notStarted:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.pillar.color);
    final todayKey = _dateKey(DateTime.now());
    final todayStatus = _statusFor(todayKey);

    final last7 = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return MapEntry(d, _statusFor(_dateKey(d)));
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.pillar.name,
                      style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              if (_editing) ..._buildEditForm() else ..._buildViewMode(todayStatus, color, last7),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildEditForm() {
    return [
      TextField(
        controller: _nameController,
        autofocus: widget.goal.isEmpty,
        decoration: const InputDecoration(labelText: 'Goal name', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _descController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Description (optional)',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!widget.goal.isEmpty)
            TextButton(onPressed: () => setState(() => _editing = false), child: const Text('Cancel')),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty) return;
              widget.onEdit(_nameController.text.trim(), _descController.text.trim());
              setState(() => _editing = false);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildViewMode(
      DailyStatus todayStatus, Color color, List<MapEntry<DateTime, DailyStatus>> last7) {
    return [
      Row(
        children: [
          Expanded(
            child: Text(widget.goal.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => setState(() => _editing = true),
          ),
        ],
      ),
      if (widget.goal.description.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(widget.goal.description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
      const SizedBox(height: 24),
      const Text('Today', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 10),
      Row(
        children: [
          _statusButton('Done', DailyStatus.done, todayStatus, color),
          const SizedBox(width: 8),
          _statusButton('Partial', DailyStatus.partial, todayStatus, color),
          const SizedBox(width: 8),
          _statusButton('Not done', DailyStatus.notDone, todayStatus, color),
        ],
      ),
      const SizedBox(height: 28),
      const Text('Last 7 days', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: last7.map((entry) {
          final s = entry.value;
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: _statusColor(s), shape: BoxShape.circle),
                child: Icon(_statusIcon(s), size: 16, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(_weekdayLabel(entry.key),
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          );
        }).toList(),
      ),
    ];
  }

  Widget _statusButton(String label, DailyStatus status, DailyStatus current, Color color) {
    final selected = status == current;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => widget.onStatusChange(status),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? color.withOpacity(0.15) : null,
          side: BorderSide(color: selected ? color : Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _weekdayLabel(DateTime d) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[d.weekday - 1];
  }
}
