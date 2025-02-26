import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../database/models.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  void _log(String message, {String level = 'INFO'}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('[$level] $timestamp: HomePage: $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    _log('Building HomePage UI');

    // Watch our providers
    final usersAsync = ref.watch(userNotifierProvider);
    final currentUser = ref.watch(currentUserProvider);
    final workoutsAsync = ref.watch(workoutNotifierProvider);

    return usersAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (users) {
        if (users.isEmpty) {
          return _buildEmptyStateMessage();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Workout Tracker'),
            centerTitle: true,
            actions: [_buildUserDropdown(users)],
          ),
          body: workoutsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (workouts) {
              // Filter workouts for current user
              final userWorkouts = workouts
                  .where((w) => w.userId == currentUser?.userId)
                  .toList();
              return _buildDashboardContent(userWorkouts);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateMessage() {
    return Scaffold(
      body: Center(
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
                Navigator.pushNamed(context, '/register');
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
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDropdown(List<User> users) {
    final currentUser = ref.watch(currentUserProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: DropdownButton<User>(
        value: currentUser ?? users.first,
        items: users.map((User user) {
          return DropdownMenuItem<User>(
            value: user,
            child: Text(user.name),
          );
        }).toList(),
        onChanged: (User? newValue) {
          if (newValue != null) {
            _log('User selection changed to: ${newValue.name}');
            ref.read(currentUserProvider.notifier).setCurrentUser(newValue);
          }
        },
      ),
    );
  }

  Widget _buildDashboardContent(List<Workout> workouts) {
    // Sort workouts by date
    workouts.sort((a, b) => b.date.compareTo(a.date));
    final recentWorkouts = workouts.take(5).toList();

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuickStats(workouts),
              const SizedBox(height: 24),
              if (recentWorkouts.isNotEmpty) ...[
                _buildRecentWorkouts(recentWorkouts),
                const SizedBox(height: 24),
              ],
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<Workout> workouts) {
    final lastWorkout = workouts.isEmpty ? null : workouts.first;

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
              value: workouts.length.toString(),
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              icon: Icons.calendar_today,
              label: 'Last Workout',
              value: _getLastWorkoutText(lastWorkout?.date),
            ),
          ],
        ),
      ),
    );
  }

  String _getLastWorkoutText(DateTime? lastWorkoutDate) {
    if (lastWorkoutDate == null) {
      return 'No workouts yet';
    }

    final now = DateTime.now();
    final difference = now.difference(lastWorkoutDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Widget _buildRecentWorkouts(List<Workout> recentWorkouts) {
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
          itemCount: recentWorkouts.length,
          itemBuilder: (context, index) {
            final workout = recentWorkouts[index];
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

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
        _buildNavigationButton(
          context,
          icon: Icons.fitness_center,
          label: 'Exercise Library',
          color: Colors.purple,
          route: '/exercise-library',
        ),
        const SizedBox(height: 12),
      ],
    );
  }

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
          );
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
