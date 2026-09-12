// Core data model for the Life Mandala app.
// Kept deliberately simple and dependency-free (plain JSON) so it is easy
// to extend later with numeric tracking, workouts, checklists, etc.

enum DailyStatus { notStarted, done, partial, notDone }

class DailyRecord {
  final String goalId;
  final String date; // format: yyyy-MM-dd
  DailyStatus status;
  String? note;

  DailyRecord({
    required this.goalId,
    required this.date,
    this.status = DailyStatus.notStarted,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'goalId': goalId,
        'date': date,
        'status': status.index,
        'note': note,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        goalId: json['goalId'] as String,
        date: json['date'] as String,
        status: DailyStatus.values[(json['status'] as int?) ?? 0],
        note: json['note'] as String?,
      );
}

class Goal {
  final String id;
  final String pillarId;
  final int position; // 0-7, position within the pillar's 3x3 ring
  String name;
  String description;

  Goal({
    required this.id,
    required this.pillarId,
    required this.position,
    this.name = '',
    this.description = '',
  });

  bool get isEmpty => name.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'pillarId': pillarId,
        'position': position,
        'name': name,
        'description': description,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        pillarId: json['pillarId'] as String,
        position: json['position'] as int,
        name: (json['name'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
      );
}

class Pillar {
  final String id;
  final int index; // 0-7
  String name;
  String description;
  int color; // ARGB int (Color.value)

  Pillar({
    required this.id,
    required this.index,
    this.name = '',
    this.description = '',
    required this.color,
  });

  bool get isEmpty => name.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'name': name,
        'description': description,
        'color': color,
      };

  factory Pillar.fromJson(Map<String, dynamic> json) => Pillar(
        id: json['id'] as String,
        index: json['index'] as int,
        name: (json['name'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        color: json['color'] as int,
      );
}

class MandalaData {
  String mainGoalTitle;
  String mainGoalDescription;
  List<Pillar> pillars;
  List<Goal> goals;
  List<DailyRecord> records;

  MandalaData({
    this.mainGoalTitle = '',
    this.mainGoalDescription = '',
    required this.pillars,
    required this.goals,
    required this.records,
  });

  Map<String, dynamic> toJson() => {
        'mainGoalTitle': mainGoalTitle,
        'mainGoalDescription': mainGoalDescription,
        'pillars': pillars.map((p) => p.toJson()).toList(),
        'goals': goals.map((g) => g.toJson()).toList(),
        'records': records.map((r) => r.toJson()).toList(),
      };

  factory MandalaData.fromJson(Map<String, dynamic> json) => MandalaData(
        mainGoalTitle: (json['mainGoalTitle'] as String?) ?? '',
        mainGoalDescription: (json['mainGoalDescription'] as String?) ?? '',
        pillars: ((json['pillars'] as List?) ?? [])
            .map((p) => Pillar.fromJson(p as Map<String, dynamic>))
            .toList(),
        goals: ((json['goals'] as List?) ?? [])
            .map((g) => Goal.fromJson(g as Map<String, dynamic>))
            .toList(),
        records: ((json['records'] as List?) ?? [])
            .map((r) => DailyRecord.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}
