import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../database/models.dart';

/// A screen that visualizes workout progress and statistics.
///
/// Displays:
/// - Total workout count
/// - Total weight lifted
/// - Progress chart showing weight lifted over time
/// - Recent workout history
///
/// Supports multiple users and can be initialized with a specific user ID.
class ProgressScreen extends StatefulWidget {
  /// Optional user ID to show specific user's progress.
  /// If null, defaults to the first available user.
  final int? userId;

  const ProgressScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Workout> _workouts = [];
  List<WorkoutExercise> _exercises = [];
  User? _selectedUser;
  List<User> _users = [];
  bool _isLoading = true;

  /// Logs message with timestamp in debug mode
  void _log(String message, {String level = 'INFO'}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$level] $timestamp: ProgressScreen: $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _log('Initializing ProgressScreen');
    _loadInitialData();
  }

  /// Loads initial data including users and their workout information.
  ///
  /// If a specific user ID was provided to the widget, attempts to load that
  /// user's data first. Falls back to the first available user if the specified
  /// user is not found.
  Future<void> _loadInitialData() async {
    try {
      _log('Loading initial progress data');

      // Load users first
      final usersData = await _dbHelper.fetchAllUsers();
      final users = usersData.map((map) => User.fromMap(map)).toList();

      if (users.isNotEmpty) {
        // If userId is provided, find that user, otherwise use first user
        User initialUser;
        if (widget.userId != null) {
          _log('Attempting to load user with ID: ${widget.userId}');
          initialUser = users.firstWhere(
            (user) => user.userId == widget.userId,
            orElse: () => users.first,
          );
        } else {
          initialUser = users.first;
        }

        await _loadUserData(initialUser);
        setState(() {
          _users = users;
          _selectedUser = initialUser;
        });
        _log('Successfully loaded initial user: ${initialUser.name}');
      } else {
        _log('No users found in the database', level: 'WARNING');
        setState(() {
          _users = [];
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      _log('Error loading initial data: $e\n$stackTrace', level: 'ERROR');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Loads workout and exercise data for a specific user.
  ///
  /// Fetches:
  /// - All workouts for the user
  /// - Exercises associated with each workout
  /// Updates the UI state with the retrieved data.
  ///
  /// [user] The user whose data should be loaded.
  Future<void> _loadUserData(User user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _log('Loading workout data for user: ${user.name}');

      // Fetch all workouts for the user
      final workoutsData = await _dbHelper.fetchAllWorkouts();
      final workouts = workoutsData
          .where((w) => w['user_id'] == user.userId)
          .map((w) => Workout.fromMap(w))
          .toList();

      _log('Found ${workouts.length} workouts');

      // Fetch exercises for each workout
      List<WorkoutExercise> allExercises = [];
      for (var workout in workouts) {
        final exercisesData =
            await _dbHelper.fetchExercisesForWorkout(workout.workoutId!);
        allExercises.addAll(
            exercisesData.map((e) => WorkoutExercise.fromMap(e)).toList());
      }

      _log('Found ${allExercises.length} exercises across all workouts');

      setState(() {
        _workouts = workouts;
        _exercises = allExercises;
        _selectedUser = user;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      _log('Error loading user data: $e\n$stackTrace', level: 'ERROR');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Calculates the total number of workouts completed
  int get totalWorkouts => _workouts.length;

  /// Calculates the total weight lifted across all exercises
  ///
  /// Multiplies weight by sets and reps for each exercise
  /// and sums the total.
  int get totalWeightLifted {
    return _exercises.fold(
        0,
        (sum, exercise) =>
            sum +
            (exercise.weight ?? 0) *
                (exercise.sets ?? 1) *
                (exercise.reps ?? 1));
  }

  /// Generates data points for the progress chart
  ///
  /// Groups exercises by date and calculates total weight lifted
  /// for each day. Returns list of FlSpots for the chart.
  List<FlSpot> _getProgressSpots() {
    if (_workouts.isEmpty) return [];

    _log('Generating progress chart data points');

    // Group exercises by date and calculate total weight
    final Map<DateTime, int> dailyTotals = {};

    for (var exercise in _exercises) {
      final workout = _workouts.firstWhere(
        (w) => w.workoutId == exercise.workoutId,
        orElse: () => _workouts.first, // Fallback if workout not found
      );

      final date = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );

      final dailyWeight =
          (exercise.weight ?? 0) * (exercise.sets ?? 1) * (exercise.reps ?? 1);

      dailyTotals[date] = (dailyTotals[date] ?? 0) + dailyWeight;
    }

    // Convert to spots
    final spots = dailyTotals.entries
        .map((entry) => FlSpot(
              entry.key.millisecondsSinceEpoch.toDouble(),
              entry.value.toDouble(),
            ))
        .toList();

    spots.sort((a, b) => a.x.compareTo(b.x));
    _log('Generated ${spots.length} data points for progress chart');
    return spots;
  }

  /// Builds a statistics card widget
  ///
  /// [title] The title of the statistic
  /// [value] The value to display
  /// [icon] The icon to show
  /// [color] The color theme for the card
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the progress chart with weight lifted over time
  ///
  /// Configures a LineChart with proper date formatting on X-axis
  /// and weight values on Y-axis. Handles empty states and data display.
  Widget _buildProgressChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight Lifted Over Time',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: _workouts.isEmpty
              ? const Center(
                  child: Text('No workout data available'),
                )
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                DateFormat('MM/dd').format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}kg',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getProgressSpots(),
                        isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  /// Builds the recent workouts list section
  Widget _buildRecentWorkoutsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Workouts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _workouts.isEmpty
            ? const Center(
                child: Text('No recent workouts'),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workouts.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final workout = _workouts[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(
                        DateFormat('MMM dd, yyyy').format(workout.date),
                      ),
                      subtitle: Text(workout.notes ?? 'No notes'),
                      trailing: Text(
                        '${workout.duration ?? 0} min',
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  /// Builds the stats cards section showing workout statistics
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Workouts',
            totalWorkouts.toString(),
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Total Weight Lifted',
            '${totalWeightLifted.toString()} kg',
            Icons.monitor_weight,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// Builds the user selection dropdown in the app bar
  Widget _buildUserDropdown() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: DropdownButton<User>(
        value: _selectedUser,
        items: _users.map((User user) {
          return DropdownMenuItem<User>(
            value: user,
            child: Text(user.name),
          );
        }).toList(),
        onChanged: (User? newValue) {
          if (newValue != null) {
            _log('User selection changed to: ${newValue.name}');
            _loadUserData(newValue);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _log('Building ProgressScreen UI');

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _log('Navigating back from ProgressScreen');
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_users.isNotEmpty) _buildUserDropdown(),
        ],
      ),
      body: _users.isEmpty
          ? const Center(
              child: Text('No users found. Please add a user first.'),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCards(),
                      const SizedBox(height: 24),
                      _buildProgressChart(),
                      const SizedBox(height: 24),
                      _buildRecentWorkoutsList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
