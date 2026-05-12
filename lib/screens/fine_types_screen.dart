import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fine_type.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../theme.dart';

class FineTypesScreen extends ConsumerWidget {
  const FineTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(fineTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrer Bøter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high_rounded),
            tooltip: 'Gjenopprett test-data',
            onPressed: () => _seedTestData(ref),
          ),
        ],
      ),
      body: typesAsync.when(
        data: (types) => ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: types.length,
          itemBuilder: (context, index) => _buildTypeTile(context, ref, types[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Feil: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTypeDialog(context, ref),
        backgroundColor: AppTheme.primaryBlue,
        label: const Text('NY BOT-KATEGORI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTypeTile(BuildContext context, WidgetRef ref, FineType type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentLime.withOpacity(0.2),
          child: Text(type.icon),
        ),
        title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${type.price.toInt()},- kr'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => ref.read(firestoreServiceProvider).deleteFineType(type.id),
        ),
      ),
    );
  }

  void _showAddTypeDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedIcon = '💰';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ny Bot-kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Navn på bot (f.eks. Sen til trening)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Pris (kr)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text('Velg ikon:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: ['💰', '⏰', '👕', '📱', '⚽', '🍺'].map((icon) {
                return InkWell(
                  onTap: () => selectedIcon = icon,
                  child: Text(icon, style: const TextStyle(fontSize: 24)),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('AVBRYT')),
          ElevatedButton(
            onPressed: () async {
              final type = FineType(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                icon: selectedIcon,
              );
              await ref.read(firestoreServiceProvider).addFineType(type);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('LAGRE'),
          ),
        ],
      ),
    );
  }

  void _seedTestData(WidgetRef ref) async {
    final firestore = ref.read(firestoreServiceProvider);
    
    // Add mock players to the permanent database
    final players = [
      AppUser(id: 'web-test-user', name: 'Botsjef (Web)', role: UserRole.admin, balance: 0, teamId: 'test-team-123'),
      AppUser(id: '1', name: 'Erik', role: UserRole.player, balance: 150, teamId: 'test-team-123'),
      AppUser(id: '2', name: 'Mats', role: UserRole.player, balance: 50, teamId: 'test-team-123'),
      AppUser(id: '3', name: 'Sara', role: UserRole.player, balance: 0, teamId: 'test-team-123'),
    ];

    for (var p in players) {
      await firestore.updateUser(p);
    }

    // Add some default fine types
    final types = [
      FineType(id: 't1', name: 'For sent til trening', price: 50, icon: '⏰'),
      FineType(id: 't2', name: 'Glemt utstyr', price: 30, icon: '👕'),
      FineType(id: 't3', name: 'Tunnel', price: 10, icon: '⚽'),
    ];

    for (var t in types) {
      await firestore.addFineType(t);
    }
  }
}

final fineTypesProvider = StreamProvider<List<FineType>>((ref) {
  return ref.watch(firestoreServiceProvider).streamFineTypes();
});
