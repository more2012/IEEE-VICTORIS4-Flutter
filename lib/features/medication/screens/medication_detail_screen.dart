import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/medication_model.dart';

class MedicationDetailScreen extends StatefulWidget {
  final Medication medication;

  const MedicationDetailScreen({
    super.key,
    required this.medication,
  });

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  bool _isLoadingInfo = false;
  String _drugInfo = '';
  String _sideEffects = '';
  String _dosageInfo = '';
  String _interactions = '';

  //Gemini API key
  static const String _apiKey = 'AIzaSyDmd8_Z9KEODppuEDk6Xfeh-YO7F25CfhU';
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  @override
  void initState() {
    super.initState();
    _loadDrugInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMedicationHeader(),
                const SizedBox(height: 8),
                _buildQuickStats(),
                const SizedBox(height: 10),
                if (_isLoadingInfo) _buildLoadingCard(),
                if (_drugInfo.isNotEmpty) _buildInfoSection('About This Medication', _drugInfo, Icons.info_outline),
                if (_dosageInfo.isNotEmpty) _buildInfoSection('Dosage Information', _dosageInfo, Icons.medication),
                if (_sideEffects.isNotEmpty) _buildInfoSection('Side Effects', _sideEffects, Icons.warning_amber),
                if (_interactions.isNotEmpty) _buildInfoSection('Drug Interactions', _interactions, Icons.healing),
                _buildActionButtons(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: _getMedicationColor(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.medication.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getMedicationColor(),
                _getMedicationColor().withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getMedicationColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getMedicationIcon(),
              size: 40,
              color: _getMedicationColor(),
            ),
          ),
          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.medication.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMedicationColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.medication.type,
                    style: TextStyle(
                      color: _getMedicationColor(),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Dosage',
              widget.medication.dosage,
              Icons.medication,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Times/Day',
              '${widget.medication.timesPerDay}x',
              Icons.schedule,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Next Dose',
              widget.medication.time,
              Icons.access_time,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(_getMedicationColor()),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Getting drug information from AI...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _getMedicationColor(), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Take Medication Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.medication.name} marked as taken'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Taken'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _refreshInformation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Info'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _getMedicationColor(),
                    side: BorderSide(color: _getMedicationColor()),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Edit medication functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit medication coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMedicationColor() {
    switch (widget.medication.type.toLowerCase()) {
      case 'tablet':
        return Colors.blue;
      case 'capsule':
        return Colors.green;
      case 'drop':
        return Colors.cyan;
      case 'injection':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getMedicationIcon() {
    switch (widget.medication.type.toLowerCase()) {
      case 'tablet':
        return Icons.medication;
      case 'capsule':
        return Icons.medical_services;
      case 'drop':
        return Icons.water_drop;
      case 'injection':
        return Icons.vaccines;
      default:
        return Icons.medication;
    }
  }

  Future<void> _loadDrugInformation() async {
    setState(() {
      _isLoadingInfo = true;
    });

    try {
      final info = await _getDrugInfoFromAI(widget.medication.name);

      setState(() {
        _drugInfo = info['general'] ?? '';
        _sideEffects = info['sideEffects'] ?? '';
        _dosageInfo = info['dosage'] ?? '';
        _interactions = info['interactions'] ?? '';
        _isLoadingInfo = false;
      });
    } catch (e) {
      setState(() {
        _drugInfo = 'Unable to load drug information. Please check your internet connection.';
        _isLoadingInfo = false;
      });
    }
  }

  Future<Map<String, String>> _getDrugInfoFromAI(String medicationName) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Please provide comprehensive information about the medication "$medicationName". 

Structure your response as follows:
1. GENERAL: General information about this medication, what it's used for, and how it works
2. DOSAGE: Typical dosage information and administration guidelines  
3. SIDE_EFFECTS: Common and serious side effects to watch for
4. INTERACTIONS: Important drug interactions and precautions

Please keep each section informative but concise. Include important safety information.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return _parseAIResponse(text);
        }
      }

      throw Exception('Failed to get AI response');
    } catch (e) {
      throw Exception('AI request failed: $e');
    }
  }

  Map<String, String> _parseAIResponse(String text) {
    final Map<String, String> sections = {};

    // Try to extract sections from AI response
    final generalMatch = RegExp(r'1\.\s*GENERAL:?\s*(.*?)(?=2\.|$)', dotAll: true).firstMatch(text);
    final dosageMatch = RegExp(r'2\.\s*DOSAGE:?\s*(.*?)(?=3\.|$)', dotAll: true).firstMatch(text);
    final sideEffectsMatch = RegExp(r'3\.\s*SIDE_EFFECTS:?\s*(.*?)(?=4\.|$)', dotAll: true).firstMatch(text);
    final interactionsMatch = RegExp(r'4\.\s*INTERACTIONS:?\s*(.*?)$', dotAll: true).firstMatch(text);

    sections['general'] = generalMatch?.group(1)?.trim() ?? text;
    sections['dosage'] = dosageMatch?.group(1)?.trim() ?? '';
    sections['sideEffects'] = sideEffectsMatch?.group(1)?.trim() ?? '';
    sections['interactions'] = interactionsMatch?.group(1)?.trim() ?? '';

    return sections;
  }

  void _refreshInformation() {
    _loadDrugInformation();
  }
}
