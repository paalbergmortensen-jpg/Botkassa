import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

import 'fine_types_screen.dart';

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

    if (_image != null && !kIsWeb) {
      imageUrl = await storage.uploadFineEvidence(_image!.path, fineId);
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

    await firestore.addFine(fine);

    setState(() => _isUploading = false);
    
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gi Bot'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hvem skal få bot?', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            _buildPlayerSelector(),
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

  Widget _buildPlayerSelector() {
    final playersAsync = ref.watch(teamLeaderboardProvider);

    return playersAsync.when(
      data: (players) => Wrap(
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
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Feil: $e')),
    );
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
