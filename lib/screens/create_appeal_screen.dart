import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/payment_service.dart';
import '../models/appeal.dart';
import '../models/fine.dart';
import '../theme.dart';
import '../widgets/var_animation.dart';

class CreateAppealScreen extends ConsumerStatefulWidget {
  final Fine fine;
  const CreateAppealScreen({super.key, required this.fine});

  @override
  ConsumerState<CreateAppealScreen> createState() => _CreateAppealScreenState();
}

class _CreateAppealScreenState extends ConsumerState<CreateAppealScreen> {
  final _reasonController = TextEditingController();
  XFile? _evidence;
  EvidenceType _type = EvidenceType.text;
  bool _isSubmitting = false;
  bool _showVarAnimation = false;

  Future<void> _pickEvidence(EvidenceType type) async {
    final ImagePicker picker = ImagePicker();
    XFile? file;
    if (type == EvidenceType.image) {
      file = await picker.pickImage(source: ImageSource.gallery);
    } else if (type == EvidenceType.video) {
      file = await picker.pickVideo(source: ImageSource.gallery);
    }
    
    if (file != null) {
      setState(() {
        _evidence = file;
        _type = type;
      });
    }
  }

  Future<void> _submitAppeal() async {
    if (_reasonController.text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Trigger Payment (9,-)
      final payment = ref.read(paymentServiceProvider);
      if (!kIsWeb) {
        await payment.presentPaywall();
      }

      // 2. Upload evidence if exists
      String? evidenceUrl;
      if (_evidence != null && !kIsWeb) {
        final storage = ref.read(storageServiceProvider);
        evidenceUrl = await storage.uploadFineEvidence(_evidence!.path, 'appeal_${DateTime.now().millisecondsSinceEpoch}');
      }

      // 3. Create Appeal doc
      final profile = ref.read(userProfileProvider).value!;
      final appeal = Appeal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fineId: widget.fine.id,
        userId: profile.id,
        userName: profile.name,
        teamId: profile.teamId!,
        reason: _reasonController.text,
        evidenceUrl: evidenceUrl,
        evidenceType: _type,
        date: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(hours: 24)),
        votesFor: [],
        votesAgainst: [],
      );

      await ref.read(firestoreServiceProvider).createAppeal(appeal);

      // 4. Trigger VAR Animation
      setState(() {
        _isSubmitting = false;
        _showVarAnimation = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feil ved VAR-sjekk: $e')),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('VAR-SJEKK')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFineSummary(),
                const SizedBox(height: 32),
                const Text('Hvorfor roper du på VAR?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Beskriv situasjonen her...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Last opp bevis (KREVER VIDEO/BILDE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildEvidenceButton(Icons.image, 'Bilde', EvidenceType.image),
                    const SizedBox(width: 16),
                    _buildEvidenceButton(Icons.videocam, 'Video', EvidenceType.video),
                  ],
                ),
                if (_evidence != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.accentLime.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(_type == EvidenceType.video ? Icons.movie : Icons.image, color: Colors.black),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_evidence!.name, overflow: TextOverflow.ellipsis)),
                        IconButton(onPressed: () => setState(() => _evidence = null), icon: const Icon(Icons.close)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAppeal,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    child: _isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SEND TIL VAR-SJEKK (9,- kr)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showVarAnimation)
          VarAnimationOverlay(
            onFinished: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('VAR-sjekk er i gang! Dommerpanelet har 24 timer.')),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFineSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.fine.typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${widget.fine.amount.toInt()},- kr'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceButton(IconData icon, String label, EvidenceType type) {
    final isSelected = _type == type && _evidence != null;
    return Expanded(
      child: InkWell(
        onTap: () => _pickEvidence(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentLime : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppTheme.accentLime : Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
