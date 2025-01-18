
class User {
  final int? userId;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  User({
    this.userId,
    required this.name,
    required this.email,
    required this.passwordHash,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      name: map['name'],
      email: map['email'],
      passwordHash: map['password_hash'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
  User copyWith({
    int? userId,
    String? name,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Workout {
  final int? workoutId;
  final int userId;
  final DateTime date;
  final int? duration;
  final String? notes;
  final int? caloriesBurned;
  final int typeId;

  Workout({
    this.workoutId,
    required this.userId,
    required this.date,
    this.duration,
    this.notes,
    this.caloriesBurned,
    required this.typeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'workout_id': workoutId,
      'user_id': userId,
      'date': date.toIso8601String(),
      'duration': duration,
      'notes': notes,
      'calories_burned': caloriesBurned,
      'type_id': typeId,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      workoutId: map['workout_id'],
      userId: map['user_id'],
      date: DateTime.parse(map['date']),
      duration: map['duration'],
      notes: map['notes'],
      caloriesBurned: map['calories_burned'],
      typeId: map['type_id'],
    );
  }
}

class Exercise {
  final int? exerciseId;
  final String name;
  final String? category;
  final String? description;
  final String? bodyPart;

  Exercise({
    this.exerciseId,
    required this.name,
    this.category,
    this.description,
    this.bodyPart,
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'name': name,
      'category': category,
      'description': description,
      'body_part': bodyPart,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      exerciseId: map['exercise_id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      bodyPart: map['body_part'],
    );
  }
}

class WorkoutExercise {
  final int? workoutExerciseId;
  final int workoutId;
  final int exerciseId;
  final int? sets;
  final int? reps;
  final int? weight;
  final int? duration;

  WorkoutExercise({
    this.workoutExerciseId,
    required this.workoutId,
    required this.exerciseId,
    this.sets,
    this.reps,
    this.weight,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'workout_exercise_id': workoutExerciseId,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      workoutExerciseId: map['workout_exercise_id'],
      workoutId: map['workout_id'],
      exerciseId: map['exercise_id'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
      duration: map['duration'],
    );
  }
}
