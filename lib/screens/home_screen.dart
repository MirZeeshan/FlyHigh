import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../database/models.dart';
import 'package:intl/intl.dart';
import './progress_screen.dart';

/// HomePage is the main dashboard of the workout tracking application.
///
/// Displays:
/// - User workout statistics
/// - Recent workout history
/// - Quick action buttons for logging workouts and viewing progress
///
/// Supports multiple users with a user selection dropdown in the app bar.
/// Serves as the primary navigation hub for the application.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Custom logging function for debugging and monitoring.
  ///
  /// Prints timestamped logs with specified level when in debug mode.
  ///
  /// Parameters:
  /// - [message] The message to log
  /// - [level] The log level (INFO, WARNING, ERROR). Defaults to INFO
  void _log(String message, {String level = 'INFO'}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$level] $timestamp: HomePage: $message');
    }
  }

  // Database helper instance for data operations
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // State variables for managing the UI
  bool _isLoading = true; // Controls loading indicator visibility
  int _totalWorkouts = 0; // Total count of user's workouts
  DateTime? _lastWorkoutDate; // Date of most recent workout
  List<Workout> _recentWorkouts = []; // List of 5 most recent workouts
  User? _selectedUser; // Currently selected user
  List<User> _users = []; // All available users

  @override
  void initState() {
    super.initState();
    _log('Initializing HomePage');
    _loadInitialData();
  }

/// Verifies and logs current user data in the database
  /// Used for debugging and testing the registration flow
  Future<void> _verifyUserData() async {
    try {
      _log('Starting user data verification');
      final users = await _dbHelper.fetchAllUsers();
      _log('=== User Database Verification ===');
      _log('Total users in database: ${users.length}');

      for (var user in users) {
        _log('''
----- User Details -----
ID: ${user['user_id']}
Name: ${user['name']}
Email: ${user['email']}
Created: ${user['created_at']}
---------------------''');
      }
      _log('=== Verification Complete ===');
    } catch (e, stackTrace) {
      _log('Error verifying user data: $e\n$stackTrace', level: 'ERROR');
    }
  }
  /// Loads the initial application data including users and their workout information.
  ///
  /// First fetches all users from the database, then loads workout data for the first
  /// user if any exists. Updates the UI loading state and handles any errors that occur
  /// during data loading.
  Future<void> _loadInitialData() async {
    try {
      _log('Loading initial application data');
      await _verifyUserData();

      // Load users first
      final usersData = await _dbHelper.fetchAllUsers();
      final users = usersData.map((map) => User.fromMap(map)).toList();

      if (users.isNotEmpty) {
        _log('Found ${users.length} users, loading first user\'s data');
        await _loadUserData(users.first);
        setState(() {
          _users = users;
          _selectedUser = users.first;
        });
      } else {
        _log('No users found', level: 'WARNING');
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

  /// Loads workout data for a specific user.
  ///
  /// Fetches all workouts for the given user from the database,
  /// sorts them by date, and updates the UI state with relevant statistics.
  ///
  /// Parameters:
  /// - [user] The user whose workout data should be loaded
  ///
  /// Updates state with:
  /// - Total number of workouts
  /// - Date of most recent workout
  /// - List of 5 most recent workouts
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

      // Sort workouts by date in descending order
      workouts.sort((a, b) => b.date.compareTo(a.date));

      _log('Found ${workouts.length} workouts for user ${user.name}');

      setState(() {
        _totalWorkouts = workouts.length;
        _lastWorkoutDate = workouts.isNotEmpty ? workouts.first.date : null;
        _recentWorkouts = workouts.take(5).toList();
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

  /// Returns a human-readable string describing when the last workout occurred.
  ///
  /// Returns:
  /// - "No workouts yet" if no workouts exist
  /// - "Today" if the last workout was today
  /// - "Yesterday" if the last workout was yesterday
  /// - "X days ago" for older workouts
  String _getLastWorkoutText() {
    if (_lastWorkoutDate == null) {
      return 'No workouts yet';
    }

    final now = DateTime.now();
    final difference = now.difference(_lastWorkoutDate!);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    _log('Building HomePage UI');

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        centerTitle: true,
        actions: [
          if (_users.isNotEmpty)
            Padding(
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
            ),
        ],
      ),
      body:
          _users.isEmpty ? _buildEmptyStateMessage() : _buildDashboardContent(),
    );
  }

  /// Builds the empty state message when no users exist
  Widget _buildEmptyStateMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Workout Tracker!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Please create an account to get started.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _log('Register button pressed');
              Navigator.pushNamed(context, '/register').then((_) {
                // Reload data when returning from registration
                _loadInitialData();
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: const Text(
              'Register',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _log('Login button pressed');
              Navigator.pushNamed(context, '/login').then((_) {
                // Reload data when returning from login
                _loadInitialData();
              });
            },
            child: const Text('Already have an account? Login'),
          ),
        ],
      ),
    );
  }

  /// Builds the main dashboard content with all user statistics and actions
  Widget _buildDashboardContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuickStats(),
              const SizedBox(height: 24),
              if (_recentWorkouts.isNotEmpty) ...[
                _buildRecentWorkouts(),
                const SizedBox(height: 24),
              ],
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Quick Stats card showing workout statistics
  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              icon: Icons.fitness_center,
              label: 'Total Workouts',
              value: _totalWorkouts.toString(),
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              icon: Icons.calendar_today,
              label: 'Last Workout',
              value: _getLastWorkoutText(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Recent Workouts section showing the latest activities
  Widget _buildRecentWorkouts() {
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
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentWorkouts.length,
          itemBuilder: (context, index) {
            final workout = _recentWorkouts[index];
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

  /// Builds the Quick Actions section with navigation buttons
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context,
          icon: Icons.add_circle_outline,
          label: 'Log Workout',
          color: Theme.of(context).primaryColor,
          route: '/workout',
        ),
        const SizedBox(height: 12),
        _buildNavigationButton(
          context,
          icon: Icons.bar_chart,
          label: 'View Progress',
          color: Colors.green,
          route: '/progress',
        ),
      ],
    );
  }

  /// Builds a stat row with an icon and value.
  ///
  /// Creates a consistent layout for displaying statistics in the Quick Stats card.
  ///
  /// Parameters:
  /// - [icon] The icon to display
  /// - [label] The label describing the statistic
  /// - [value] The value to display
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    _log('Building stat row for: $label = $value');
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Builds a navigation button for quick actions.
  ///
  /// Creates a styled button with an icon and label that navigates to the specified route.
  /// Includes logging for navigation events and data reloading.
  ///
  /// Parameters:
  /// - [icon] The icon to display on the button
  /// - [label] The text label for the button
  /// - [color] The color theme for the button
  /// - [route] The route to navigate to when pressed
  /// - [arguments] Optional arguments to pass to the route
  Widget _buildNavigationButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
    Object? arguments,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _log('Navigating to $route');
          Navigator.pushNamed(
            context,
            route,
            arguments: arguments,
          ).then((_) {
            _log('Returned from $route, reloading user data');
            if (_selectedUser != null) {
              _loadUserData(_selectedUser!);
            } else {
              _log('No user selected after navigation', level: 'WARNING');
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
