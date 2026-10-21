import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Edits the name of a person.
class PersonNameSheet extends StatefulWidget {
  const PersonNameSheet({
    super.key,
    required this.initialName,
    required this.onSave,
  });

  final String initialName;

  /// Saves the name; returns an error message, or `null` on success.
  final Future<String?> Function(String name) onSave;

  static Future<void> show(
    BuildContext context, {
    required String initialName,
    required Future<String?> Function(String name) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PersonNameSheet(initialName: initialName, onSave: onSave),
    );
  }

  @override
  State<PersonNameSheet> createState() => _PersonNameSheetState();
}

class _PersonNameSheetState extends State<PersonNameSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.onSave(_name.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormSheet(
      title: 'Editar persona',
      children: [
        AppTextField(
          controller: _name,
          hint: 'Nombre',
          icon: Icons.person_rounded,
          textInputAction: TextInputAction.done,
        ),
        FormError(_error),
        SizedBox(height: 20.h),
        PrimaryActionButton(
          text: 'Guardar',
          loading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }
}
