import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/fine.dart';
import '../models/user.dart';
import '../models/fine_type.dart';
import '../theme.dart';
import 'fine_types_screen.dart';

class AddFineScreen extends ConsumerStatefulWidget {
  const AddFineScreen({super.key});

  @override
  ConsumerState<AddFineScreen> createState() => _AddFineScreenState();
}

class _AddFineScreenState extends ConsumerState<AddFineScreen> {
  AppUser? _selectedPlayer;
  FineType? _selectedType;
  XFile? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<void> _submitFine() async {
    if (_selectedPlayer == null || _selectedType == null) return;

    final profile = ref.read(userProfileProvider).value;
    if (profile == null || profile.teamId == null) return;

    setState(() => _isUploading = true);

    final firestore = ref.read(firestoreServiceProvider);
    final storage = ref.read(storageServiceProvider);
    
    String? imageUrl;
    final fineId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (_image != null && !kIsWeb) {
        imageUrl = await storage.uploadFineEvidence(_image!.path, fineId)
            .timeout(const Duration(seconds: 10));
      }

      final fine = Fine(
        id: fineId,
        teamId: profile.teamId!,
        userId: _selectedPlayer!.id,
        userName: _selectedPlayer!.name,
        typeId: _selectedType!.id,
        typeName: _selectedType!.name,
        amount: _selectedType!.price,
        date: DateTime.now(),
        isPaid: false,
        evidenceUrl: imageUrl,
      );

      await firestore.addFine(fine).timeout(const Duration(seconds: 5));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bot gitt til ${_selectedPlayer!.name}!'),
            backgroundColor: AppTheme.accentLime,
          ),
        );
        setState(() {
          _selectedPlayer = null;
          _selectedType = null;
          _image = null;
          _isUploading = false;
        });
      }
    } catch (e) {
      debugPrint('Error giving fine: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feil ved sending av bot: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botsjef Panel'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FineTypesScreen()),
                ),
                icon: const Icon(Icons.settings_suggest_rounded),
                label: const Text('ADMINISTRER DINE BØTER', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  foregroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Hvem skal få bot?', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            _buildPlayerSelector(ref),
            const SizedBox(height: 32),
            Text('Kategori', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildFineTypeSelector(),
            const SizedBox(height: 32),
            Text('Legg til Bevis', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (_selectedPlayer != null && _selectedType != null && !_isUploading)
                    ? _submitFine
                    : null,
                child: _isUploading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('FULLFØR OG GI BOT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSelector(WidgetRef ref) {
    final playersAsync = ref.watch(teamLeaderboardProvider);

    return playersAsync.when(
      data: (players) {
        if (players.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Text('Ingen spillere funnet i laget ditt.'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _seedTestData(ref),
                  icon: const Icon(Icons.auto_fix_high_rounded),
                  label: const Text('HENT TEST-SPILLERE NÅ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentLime,
                    foregroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: players.map((player) {
            final isSelected = _selectedPlayer?.id == player.id;
            return InkWell(
              onTap: () => setState(() => _selectedPlayer = player),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 33,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${player.id}'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    player.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryBlue : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Feil: $e')),
    );
  }

  void _seedTestData(WidgetRef ref) async {
    final firestore = FirebaseFirestore.instance;
    const teamId = 'test-team-123';
    
    try {
      // Add mock players using raw maps to bypass model issues on web
      final players = {
        'web-test-user': {'name': 'Botsjef (Web)', 'role': 1, 'balance': 0, 'teamId': teamId},
        '1': {'name': 'Erik', 'role': 0, 'balance': 150, 'teamId': teamId},
        '2': {'name': 'Mats', 'role': 0, 'balance': 50, 'teamId': teamId},
        '3': {'name': 'Sara', 'role': 0, 'balance': 0, 'teamId': teamId},
      };

      for (var entry in players.entries) {
        await firestore.collection('users').doc(entry.key).set(entry.value, SetOptions(merge: true));
      }

      // Add mock categories
      final types = {
        't1': {'name': 'For sent til trening', 'price': 50, 'icon': '⏰'},
        't2': {'name': 'Glemt utstyr', 'price': 30, 'icon': '👕'},
        't3': {'name': 'Tunnel', 'price': 10, 'icon': '⚽'},
      };

      for (var entry in types.entries) {
        await firestore.collection('fineTypes').doc(entry.key).set(entry.value, SetOptions(merge: true));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test-data er nå lagt inn!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Seed error: $e');
    }
  }

  Widget _buildFineTypeSelector() {
    final typesAsync = ref.watch(fineTypesProvider);

    return typesAsync.when(
      data: (types) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: types.map((type) {
          final isSelected = _selectedType?.id == type.id;
          return InkWell(
            onTap: () => setState(() => _selectedType = type),
            child: Card(
              color: isSelected ? AppTheme.primaryBlue : Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    type.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${type.price.toInt()},-',
                    style: TextStyle(
                      color: isSelected ? AppTheme.accentLime : AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Feil: $e')),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _getImageWidget(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryBlue, size: 30),
                  const SizedBox(width: 12),
                  Text('Ta bildebevis', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
      ),
    );
  }

  Widget _getImageWidget() {
    return Image.network(_image!.path, fit: BoxFit.cover);
  }
}
