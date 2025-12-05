import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nursingpdq/screens/home.dart';
import 'package:nursingpdq/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import '../models/questions_model.dart';
import '../data/questions_list.dart' show questions, deps;
import '../providers/patient_provider.dart'; // <-- import the lists

/// Dependency model (kept here for form logic)
class Dependency {
  final String controllerKey;
  final String dependentKey;
  final List<String> showWhenValues;

  Dependency({
    required this.controllerKey,
    required this.dependentKey,
    required this.showWhenValues,
  });
}

/// DynamicPatientFormPage no longer receives the questions/deps via ctor.
/// It reads the lists imported from data/questions_list.dart
class DynamicPatientFormPage extends StatefulWidget {
  const DynamicPatientFormPage({Key? key}) : super(key: key);

  @override
  State<DynamicPatientFormPage> createState() => _DynamicPatientFormPageState();
}

class _DynamicPatientFormPageState extends State<DynamicPatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> answers = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _submitting = false;

  TextEditingController _controllerFor(String key) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(
        text: answers[key]?.toString() ?? '',
      );
    }
    return _controllers[key]!;
  }

  @override
  void dispose() {
    // dispose all controllers
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  // local shorthand to use imported lists
  List<Question> get _questions => questions;
  List<Dependency> get _deps => deps;

  bool _isVisible(String key) {
    final relevant = _deps.where((d) => d.dependentKey == key).toList();
    if (relevant.isEmpty) return true;
    for (final d in relevant) {
      final val = answers[d.controllerKey];
      if (val == null) return false;
      if (val is List) {
        bool found = false;
        for (final v in val) {
          if (d.showWhenValues.contains(v)) {
            found = true;
            break;
          }
        }
        if (!found) return false;
      } else {
        if (!d.showWhenValues.contains(val)) return false;
      }
    }
    return true;
  }

  void _cleanupHiddenDependents() {
    final toRemove = <String>[];
    for (final dep in _deps) {
      final visible = _isVisible(dep.dependentKey);
      if (!visible && answers.containsKey(dep.dependentKey)) {
        toRemove.add(dep.dependentKey);
      }
    }
    if (toRemove.isNotEmpty) {
      setState(() {
        for (final k in toRemove) {
          answers.remove(k);
          // also clear controller if any (avoid stale controllers)
          if (_controllers.containsKey(k)) {
            _controllers[k]!.clear();
          }
        }
      });
    }
  }

  // values are entered but not saved
  // Widget _buildTextField(Question q) {
  //   final ctrl = _controllerFor(q.key);
  //   return TextFormField(
  //     controller: ctrl,
  //     keyboardType: q.type == QuestionType.number
  //         ? TextInputType.number
  //         : TextInputType.text,
  //     decoration: InputDecoration(
  //       labelText: q.label,
  //       border: const OutlineInputBorder(),
  //       hintText: q.hint,
  //       filled: true,
  //       fillColor: Colors.transparent,
  //     ),
  //     validator: (s) {
  //       if (!_isVisible(q.key)) return null;
  //       if (q.required && (s == null || s.trim().isEmpty)) return 'Required';
  //       if (q.type == QuestionType.number && s != null && s.trim().isNotEmpty) {
  //         if (double.tryParse(s.trim()) == null) return 'Enter a valid number';
  //       }
  //       return null;
  //     },
  //     onSaved: (s) {
  //       if (_isVisible(q.key)) {
  //         answers[q.key] = ctrl.text.trim();
  //       } else {
  //         answers.remove(q.key);
  //       }
  //     },
  //   );
  // }

  Widget _buildTextField(Question q) {
    final ctrl = _controllerFor(q.key);
    return TextFormField(
      controller: ctrl,
      keyboardType: q.type == QuestionType.number
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: q.label,
        border: const OutlineInputBorder(),
        hintText: q.hint,
        filled: true,
        fillColor: Colors.transparent,
      ),
      validator: (s) {
        if (!_isVisible(q.key)) return null;
        if (q.required && (s == null || s.trim().isEmpty)) return 'Required';
        if (q.type == QuestionType.number && s != null && s.trim().isNotEmpty) {
          if (double.tryParse(s.trim()) == null) return 'Enter a valid number';
        }
        return null;
      },
      // KEEP answers in sync while user types so validation/read checks see current value
      onChanged: (v) {
        answers[q.key] = v.trim();
      },
      onSaved: (s) {
        if (_isVisible(q.key)) {
          answers[q.key] = ctrl.text.trim();
        } else {
          answers.remove(q.key);
        }
      },
    );
  }

  Widget _buildDropDown(Question q) {
    final current = answers[q.key] as String?;
    return DropdownButtonFormField<String>(
      value: current,
      decoration: InputDecoration(
        labelText: q.label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.transparent,
      ),
      items: (q.options ?? [])
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      validator: (s) {
        if (!_isVisible(q.key)) return null;
        if (q.required && (s == null || s.trim().isEmpty)) return 'Required';
        return null;
      },
      onChanged: (v) {
        setState(() {
          answers[q.key] = v;
          _cleanupHiddenDependents();
        });
      },
      onSaved: (s) {
        if (_isVisible(q.key)) answers[q.key] = s;
      },
    );
  }

  Widget _buildRadio(Question q) {
    return FormField<String>(
      initialValue: answers[q.key] as String?,
      validator: (s) {
        if (!_isVisible(q.key)) return null;
        if (q.required && (s == null || s.trim().isEmpty)) return 'Required';
        return null;
      },
      onSaved: (s) {
        if (_isVisible(q.key))
          answers[q.key] = s;
        else
          answers.remove(q.key);
      },
      builder: (state) {
        // local current value (prefer FormField's value for consistency)
        final String? current = state.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (q.options ?? []).map((opt) {
                final bool selected = current == opt;
                return ChoiceChip(
                  label: Text(opt),
                  selected: selected,
                  onSelected: (sel) {
                    final newVal = sel ? opt : null;
                    // update both FormField state and answers map in one place
                    state.didChange(newVal);
                    setState(() {
                      answers[q.key] = newVal;
                      _cleanupHiddenDependents();
                    });
                  },
                );
              }).toList(),
            ),

            // error text (consistent and visible)
            if (state.errorText != null)
              Column(
                children: [
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildCheckboxGroup(Question q) {
    final List<String> selected = List<String>.from(
      answers[q.key] ?? <String>[],
    );
    final String otherValue = selected.firstWhere(
      (s) => s.startsWith('Others:'),
      orElse: () => '',
    );

    return FormField<List<String>>(
      initialValue: selected,
      validator: (lst) {
        if (!_isVisible(q.key)) return null;
        if (q.required && (lst == null || lst.isEmpty))
          return 'Select at least one';
        return null;
      },
      onSaved: (lst) {
        if (_isVisible(q.key)) {
          answers[q.key] = lst ?? <String>[];
        } else {
          answers.remove(q.key);
        }
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: (q.options ?? []).map((opt) {
                final bool checked = selected.any((s) {
                  if (opt == 'Others')
                    return s == 'Others' || s.startsWith('Others:');
                  return s == opt;
                });

                return FilterChip(
                  label: Text(opt),
                  selected: checked,
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        if (opt == 'Others') {
                          selected.add('Others');
                        } else {
                          selected.add(opt);
                        }
                      } else {
                        selected.removeWhere(
                          (s) =>
                              s == opt ||
                              s.startsWith('Others:') ||
                              s == 'Others',
                        );
                      }
                      answers[q.key] = selected;
                      state.didChange(selected);
                    });
                  },
                );
              }).toList(),
            ),

            if (selected.any((s) => s == 'Others' || s.startsWith('Others:')))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: _controllerFor('${q.key}_others'),
                  initialValue:
                      null, // DON'T use initialValue when controller is present
                  decoration: const InputDecoration(
                    labelText: 'Please specify (Others)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (v) {
                    setState(() {
                      selected.removeWhere(
                        (s) => s == 'Others' || s.startsWith('Others:'),
                      );
                      final trimmed = v.trim();
                      if (trimmed.isNotEmpty) {
                        selected.add('Others:$trimmed');
                      } else {
                        selected.add('Others');
                      }
                      answers[q.key] = selected;
                      state.didChange(selected);
                    });
                  },
                ),
              ),

            if (state.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuestionWidget(Question q) {
    if (!_isVisible(q.key)) {
      answers.remove(q.key);
      return const SizedBox.shrink();
    }

    switch (q.type) {
      case QuestionType.text:
      case QuestionType.number:
        return _buildTextField(q);
      case QuestionType.radio:
        return _buildRadio(q);
      case QuestionType.checkBox:
        return _buildCheckboxGroup(q);
      case QuestionType.dropDown:
        return _buildDropDown(q);
      default:
        return _buildTextField(q);
    }
  }

  void _onSubmit() async {
    // 1) Run the normal Form validation so each FormField gets validated
    final isValid = _formKey.currentState!.validate();
    print('5400 _onSubmit');
    final provider = Provider.of<PatientProvider>(context, listen: false);
    final patient = provider.patient;

    // 2) Force rebuild so any FormField errorText is shown immediately
    setState(() {});

    // 3) Defensive check: use controller values for text/number, answers for others
    final List<String> missingKeys = [];
    for (final q in _questions) {
      if (!q.required) continue; // only check required ones
      if (!_isVisible(q.key)) continue; // ignore hidden dependents

      // For text/number, read controller directly (most reliable)
      if (q.type == QuestionType.text || q.type == QuestionType.number) {
        final ctrl = _controllers[q.key];
        final text = (ctrl?.text ?? '').trim();
        if (text.isEmpty) {
          missingKeys.add(q.label);
        }
        continue;
      }

      // For others, look at answers map
      final val = answers[q.key];
      if (val == null) {
        missingKeys.add(q.label);
        continue;
      }
      if (val is String && val.trim().isEmpty) {
        missingKeys.add(q.label);
        continue;
      }
      if (val is List && val.isEmpty) {
        missingKeys.add(q.label);
        continue;
      }
    }

    if (!isValid || missingKeys.isNotEmpty) {
      final msg = missingKeys.isEmpty
          ? 'Please fix the highlighted errors'
          : 'Please provide: \n${missingKeys.join(', \n')}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // stop here
    }

    // 4) Save form fields into answers (calls onSaved on fields)
    _formKey.currentState!.save();

    // 5) Remove any hidden answers (cleanup)
    final toRemove = <String>[];
    for (final q in _questions) {
      if (!_isVisible(q.key) && answers.containsKey(q.key)) toRemove.add(q.key);
    }
    for (final k in toRemove) answers.remove(k);

    if (!mounted) return;
    setState(() => _submitting = true);
    var submitResult = await auth.postPatientForm(answers, patient!);

    setState(() => _submitting = false);
    if (submitResult['success'] == true) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Response', style: TextStyle(color: Colors.green)),
          content: Text(
            submitResult['message'].toString(),
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.clearPatient();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong!!!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a small snapshot of only visible questions to avoid empty gaps
    final visibleQuestions = _questions
        .where((q) => _isVisible(q.key))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 23, 143),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(
          child: Text(
            'Patient Form',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => auth.logOut(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: ListView.separated(
                // +1 for the submit button at the end
                itemCount: visibleQuestions.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  if (i == visibleQuestions.length) {
                    return ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        backgroundColor: const Color.fromARGB(
                          255,
                          173,
                          23,
                          143,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit Form',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  final q = visibleQuestions[i];

                  // optional: wrap each question in a card-like container for nicer UI
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildQuestionWidget(q),
                  );
                },
              ),
            ),
          ),
          if (_submitting)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
