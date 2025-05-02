import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/device_service.dart';
import '../providers/user_provider.dart';
import 'device_manager_screen.dart';
import 'login_screen.dart';
import 'actuator_control_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // Use the UserProvider's signOut method
      await context.read<UserProvider>().signOut();
      
      if (!mounted) return;
      
      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToDeviceManager(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Provider<DeviceService>(
          create: (_) => DeviceService(),
          child: const DeviceManagerScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final isLoading = userProvider.isLoading;
        final error = userProvider.error;

        return Scaffold(
          appBar: AppBar(
            title: const Text('AutoFarmer'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _signOut(context),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            error,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<UserProvider>().loadUser();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        child: const Icon(Icons.person, color: Colors.white),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Welcome,',
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                            Text(
                                              user?.name ?? 'User',
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user?.email ?? '',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              _buildActionCard(
                                context,
                                'Device Control',
                                Icons.toggle_on,
                                Colors.green,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ActuatorControlScreen(
                                      deviceId: 'DEVICE_1', // Using default device ID
                                    ),
                                  ),
                                ),
                              ),
                              _buildActionCard(
                                context,
                                'Manage Devices',
                                Icons.devices,
                                Colors.blue,
                                () => _navigateToDeviceManager(context),
                              ),
                              _buildActionCard(
                                context,
                                'View Reports',
                                Icons.bar_chart,
                                Colors.orange,
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reports feature coming soon!'),
                                    ),
                                  );
                                },
                              ),
                              _buildActionCard(
                                context,
                                'Settings',
                                Icons.settings,
                                Colors.purple,
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Settings feature coming soon!'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
