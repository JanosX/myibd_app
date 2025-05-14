import 'package:flutter/material.dart';
import 'package:myibd_app/screens/bowel/bowel_form_screen.dart';
import 'package:myibd_app/screens/bowel/bowel_history_screen.dart';
import 'package:myibd_app/screens/fluid/fluid_form_screen.dart';
import 'package:myibd_app/screens/fluid/fluid_history_screen.dart';
import 'package:myibd_app/screens/food/food_form_screen.dart';
import 'package:myibd_app/screens/food/food_history_screen.dart';
import 'package:myibd_app/screens/medication/medication_form_screen.dart';
import 'package:myibd_app/screens/medication/medication_history_screen.dart';
import 'package:myibd_app/screens/sleep/sleep_form_screen.dart';
import 'package:myibd_app/screens/sleep/sleep_history_screen.dart';
import 'package:myibd_app/screens/symptom/symptom_form_screen.dart';
import 'package:myibd_app/screens/symptom/symptom_history_screen.dart';
import 'package:myibd_app/screens/insights/insights_screen.dart';
import 'package:myibd_app/screens/medication/medicine_box_screen.dart';
// Repository imports
import 'package:myibd_app/repositories/bowel_repository.dart';
import 'package:myibd_app/repositories/fluid_repository.dart';
import 'package:myibd_app/repositories/food_repository.dart';
import 'package:myibd_app/repositories/medication_repository.dart';
import 'package:myibd_app/repositories/sleep_repository.dart';
import 'package:myibd_app/repositories/symptom_repository.dart';
import 'package:myibd_app/repositories/flare_repository.dart';

void main() {
  runApp(const MyIBDApp());
}

class MyIBDApp extends StatelessWidget {
  const MyIBDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyIBD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Repositories
  final _bowelRepository = BowelRepository();
  final _fluidRepository = FluidRepository();
  final _foodRepository = FoodRepository();
  final _medicationRepository = MedicationRepository();
  final _sleepRepository = SleepRepository();
  final _symptomRepository = SymptomRepository();
  final _flareRepository = FlareRepository();
  
  // Dashboard values
  String _bowelCount = '0';
  String _fluidTotal = '0ml';
  String _foodCount = '0';
  String _medicationCount = '0';
  String _sleepDuration = '0h';
  String _symptomCount = '0';
  
  bool _isInFlare = false;
  int _flareDays = 0;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadFlareStatus();
  }
  
  Future<void> _loadDashboardData() async {
    try {
      // Load bowel movement count
      final bowelCount = await _bowelRepository.getTodayCount();
      
      // Load fluid total
      final fluidTotal = await _fluidRepository.getTodayTotalFormatted();
      
      // Load food count
      final foodCount = await _foodRepository.getTodayMealCount();
      
      // Load medication count
      final medicationCount = await _medicationRepository.getTodayCount();
      
      // Load last sleep duration
      final sleepDuration = await _sleepRepository.getLastSleepFormatted();
      
      // Load symptom count
      final symptomCount = await _symptomRepository.getTodayCount();
      
      if (mounted) {
        setState(() {
          _bowelCount = bowelCount.toString();
          _fluidTotal = fluidTotal;
          _foodCount = foodCount.toString();
          _medicationCount = medicationCount.toString();
          _sleepDuration = sleepDuration;
          _symptomCount = symptomCount.toString();
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }
  
  Future<void> _loadFlareStatus() async {
    try {
      final activeFlare = await _flareRepository.getActiveFlare();
      final flareDays = await _flareRepository.getFlareDays();
      
      if (mounted) {
        setState(() {
          _isInFlare = activeFlare != null;
          _flareDays = flareDays;
        });
      }
    } catch (e) {
      print('Error loading flare status: $e');
    }
  }
  
  void _toggleFlare() async {
    setState(() {
      _isInFlare = !_isInFlare;
    });
    
    try {
      if (_isInFlare) {
        await _flareRepository.startFlare();
      } else {
        await _flareRepository.endFlare();
      }
      
      await _loadFlareStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isInFlare ? 'Flare started' : 'Flare ended'),
            backgroundColor: _isInFlare ? Colors.red : Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error toggling flare: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating flare status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyIBD Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          // Flare toggle in app bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                if (_isInFlare)
                  Text(
                    'Day $_flareDays',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  'Flare',
                  style: TextStyle(
                    color: _isInFlare ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _isInFlare,
                    onChanged: (value) => _toggleFlare(),
                    activeColor: Colors.red,
                    activeTrackColor: Colors.red.shade200,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MyIBD',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'IBD Tracking & Management',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Insights'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InsightsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Generate Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'MyIBD',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.medical_services, size: 48),
                  children: [
                    const Text('MyIBD is a comprehensive tracking app for managing Inflammatory Bowel Disease.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Grid for tracking tiles
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildDashboardTile(
                      context,
                      title: 'Bowel Movements',
                      icon: Icons.water_drop,
                      value: _bowelCount,
                      subtitle: 'today',
                      color: Colors.blue.shade700,
                      onTileTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BowelHistoryScreen()),
                        );
                        _loadDashboardData();
                      },
                      onAddTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BowelFormScreen()),
                        );
                        if (result == true) {
                          _loadDashboardData();
                        }
                      },
                    ),
                    _buildDashboardTile(
                      context,
                      title: 'Fluid Intake',
                      icon: Icons.local_drink,
                      value: _fluidTotal,
                      subtitle: 'today',
                      color: Colors.cyan.shade700,
                      onTileTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FluidHistoryScreen()),
                        );
                        _loadDashboardData();
                      },
                      onAddTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FluidFormScreen()),
                        );
                        if (result == true) {
                          _loadDashboardData();
                        }
                      },
                    ),
                    _buildDashboardTile(
                      context,
                      title: 'Food',
                      icon: Icons.restaurant,
                      value: _foodCount,
                      subtitle: 'meals',
                      color: Colors.orange.shade700,
                      onTileTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FoodHistoryScreen()),
                        );
                        _loadDashboardData();
                      },
                      onAddTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FoodFormScreen()),
                        );
                        if (result == true) {
                          _loadDashboardData();
                        }
                      },
                    ),
                    _buildDashboardTile(
                      context,
                      title: 'Medications',
                      icon: Icons.medication,
                      value: _medicationCount,
                      subtitle: 'today',
                      color: Colors.red.shade700,
                      onTileTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MedicationHistoryScreen()),
                        );
                        _loadDashboardData();
                      },
                      onAddTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MedicationFormScreen()),
                        );
                        if (result == true) {
                          _loadDashboardData();
                        }
                      },
                    ),
                    _buildDashboardTile(
                      context,
                      title: 'Sleep',
                      icon: Icons.bedtime,
                      value: _sleepDuration,
                      subtitle: 'last night',
                      color: Colors.indigo.shade700,
                      onTileTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SleepHistoryScreen()),
                        );
                        _loadDashboardData();
                      },
                      onAddTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SleepFormScreen()),
                        );
                        if (result == true) {
                          _loadDashboardData();
                        }
                      },
                    ),
                    _buildDashboardTile(
                      context,
                      title: 'Symptoms',
                      icon: Icons.warning_amber,
                      value: _symptomCount,
                      subtitle: 'today',
                      color: Colors.amber.shade700,
                      onTileTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SymptomHistoryScreen()),
                        );
                        _loadDashboardData();
                      },
                      onAddTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SymptomFormScreen()),
                        );
                        if (result == true) {
                          _loadDashboardData();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Full width Insights tile
              _buildInsightsTile(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
    required String subtitle,
    required Color color,
    required VoidCallback onTileTap,
    required VoidCallback onAddTap,
  }) {
    return Column(
      children: [
        // Main tile
        Expanded(
          child: Container(
            width: double.infinity,
            child: Card(
              elevation: 4,
              child: InkWell(
                onTap: onTileTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 36,
                        color: color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (value.isNotEmpty) ...[
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ] else
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Add button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsTile(BuildContext context) {
    final color = Colors.purple.shade700;
    
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Card(
        elevation: 4,
        child: InkWell(
        onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InsightsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insights,
                  size: 40,
                  color: color,
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'View analytics',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}