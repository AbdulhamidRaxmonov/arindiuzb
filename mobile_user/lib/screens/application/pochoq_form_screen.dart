import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/category.dart';
import '../../services/services.dart';
import '../../widgets/helpers.dart';
import 'map_picker_screen.dart';

class PochoqFormScreen extends StatefulWidget {
  final WasteCategory category;
  const PochoqFormScreen({super.key, required this.category});

  @override
  State<PochoqFormScreen> createState() => _PochoqFormScreenState();
}

class _PochoqFormScreenState extends State<PochoqFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _addressController = TextEditingController();
  final _commentController = TextEditingController();

  double? _lat;
  double? _lng;
  File? _photo;
  bool _loading = false;

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galereya'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 70, maxWidth: 1280);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initial: _lat != null ? LatLng(_lat!, _lng!) : null,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
        if (_addressController.text.trim().isEmpty) {
          _addressController.text = result.address;
        }
      });
    }
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await ApplicationService.create(
        type: widget.category.key,
        weightKg: double.parse(_weightController.text.replaceAll(',', '.')),
        address: _addressController.text.trim(),
        latitude: _lat,
        longitude: _lng,
        comment: _commentController.text.trim(),
        photo: _photo,
      );
      if (!mounted) return;
      await context.read<AppState>().refreshUser();
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppTheme.primary, size: 48),
          title: Text(t.t('request_created')),
          content: Text(result.message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      showSnack(context, describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _estimated {
    final w = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0;
    return w * AppConfig.pricePerKg;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('${t.t(widget.category.key)} — ${t.t('new_request')}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Weight
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: t.t('weight_kg'),
                prefixIcon: const Icon(Icons.scale),
                suffixText: 'kg',
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                if (d == null || d <= 0) return t.t('required');
                return null;
              },
            ),
            const SizedBox(height: 8),
            if (_estimated > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${t.t('estimated')}: ${formatMoney(_estimated)} ${t.t('sum')}',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 16),

            // Address + map
            TextFormField(
              controller: _addressController,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: t.t('address'),
                prefixIcon: const Icon(Icons.home_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.t('required') : null,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map_outlined),
              label: Text(_lat == null
                  ? t.t('pick_on_map')
                  : '✓ ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 16),

            // Comment
            TextFormField(
              controller: _commentController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: t.t('comment'),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photo
            Text(t.t('photo'),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _photo == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(t.t('add_photo'),
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_photo!,
                            fit: BoxFit.cover, width: double.infinity),
                      ),
              ),
            ),
            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                    )
                  : const Icon(Icons.local_shipping_outlined),
              label: Text(t.t('take_away')),
            ),
          ],
        ),
      ),
    );
  }
}
