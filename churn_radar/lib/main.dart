import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

void main() {
  runApp(const ChurnRadarApp());
}

class ChurnRadarApp extends StatelessWidget {
  const ChurnRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RavenStack Churn Radar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF121212),
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
  List<List<dynamic>> _allCustomers = [];
  List<List<dynamic>> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  
  // NEW: Track the currently selected filter!
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadCSVData();
  }

  Future<void> _loadCSVData() async {
    try {
      final rawData = await rootBundle.loadString("assets/master_dataset.csv");
      List<List<dynamic>> listData = const CsvToListConverter(eol: '\n').convert(rawData);
      
      List<List<dynamic>> uniqueCustomers = [];
      Set<String> seenAccountIds = {}; 
      
      for (var i = 1; i < listData.length; i++) {
        String currentAccountId = listData[i][0].toString();
        if (!seenAccountIds.contains(currentAccountId)) {
          seenAccountIds.add(currentAccountId);
          uniqueCustomers.add(listData[i]);
        }
      }
      
      setState(() {
        _allCustomers = uniqueCustomers;
        _filteredCustomers = uniqueCustomers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      debugPrint("Error loading CSV: $e");
    }
  }

  // NEW: This super-function handles BOTH the search bar and the filter buttons
  void _applyFilters() {
    String searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredCustomers = _allCustomers.where((row) {
        // 1. Text Search Check
        final accountId = row[0].toString().toLowerCase();
        final matchesSearch = accountId.contains(searchQuery);

        // 2. Risk Status Check (Using your ML logic!)
        final double satisfaction = double.tryParse(row[22].toString()) ?? 5.0;
        final int tickets = int.tryParse(row[21].toString()) ?? 0;
        final bool isHighRisk = tickets >= 4 || satisfaction <= 2.5;

        bool matchesFilter = true;
        if (_selectedFilter == 'High Risk') {
          matchesFilter = isHighRisk;
        } else if (_selectedFilter == 'Stable') {
          matchesFilter = !isHighRisk;
        }

        // Only show the customer if they match BOTH the search and the button filter
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚠️ RavenStack Churn Radar'),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _applyFilters(),
                    decoration: InputDecoration(
                      labelText: 'Search Account ID...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                
                // NEW: The Filter Buttons UI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text('Filter: ', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('High Risk'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Stable'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Main List of Customers
                Expanded(
                  child: _filteredCustomers.isEmpty
                      ? const Center(child: Text('No accounts match your criteria.'))
                      : ListView.builder(
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            final String accountId = customer[0].toString();
                            final int seats = int.tryParse(customer[7].toString()) ?? 1;
                            final double satisfaction = double.tryParse(customer[22].toString()) ?? 5.0;
                            final int tickets = int.tryParse(customer[21].toString()) ?? 0;
                            final bool isHighRisk = tickets >= 4 || satisfaction <= 2.5;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: const Color(0xFF1E1E1E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: isHighRisk ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                  child: Icon(
                                    isHighRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                    color: isHighRisk ? Colors.redAccent : Colors.greenAccent,
                                  ),
                                ),
                                title: Text(
                                  'Account: $accountId',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Seats: $seats  |  Rating: ${satisfaction.toStringAsFixed(1)}★  |  Tickets: $tickets',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isHighRisk ? Colors.redAccent.withOpacity(0.15) : Colors.greenAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isHighRisk ? Colors.redAccent : Colors.greenAccent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    isHighRisk ? 'HIGH RISK' : 'STABLE',
                                    style: TextStyle(
                                      color: isHighRisk ? Colors.redAccent : Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // A tiny helper widget to draw the buttons
  Widget _buildFilterChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == label,
      selectedColor: label == 'High Risk' ? Colors.redAccent.withOpacity(0.3) : Colors.blueGrey,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = label;
        });
        _applyFilters();
      },
    );
  }
}