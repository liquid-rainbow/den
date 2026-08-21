import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  double _distanceKm = 25;
  RangeValues _ageRange = const RangeValues(18, 35);
  RangeValues _heightRangeCm = const RangeValues(152, 188); // 5'0" to 6'2"
  bool _interestedFemale = true;
  bool _interestedMale = false;
  bool _interestedNonBinary = false;

  String _formatHeight(double cm) {
    final feet = (cm / 30.48).floor();
    final inches = (((cm / 2.54) - (feet * 12))).round();
    return "$feet'$inches\"";
  }

  void _resetFilters() {
    setState(() {
      _distanceKm = 25;
      _ageRange = const RangeValues(18, 35);
      _heightRangeCm = const RangeValues(152, 188);
      _interestedFemale = true;
      _interestedMale = false;
      _interestedNonBinary = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Filters',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Reset',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // 1. Distance Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBE8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Distance', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black)),
                            Text('${_distanceKm.round()} km', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.black,
                            inactiveTrackColor: const Color(0xFFDDE3EC),
                            thumbColor: Colors.black,
                            overlayColor: Colors.black12,
                          ),
                          child: Slider(
                            value: _distanceKm,
                            min: 1,
                            max: 50,
                            onChanged: (val) => setState(() => _distanceKm = val),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('1 km', style: TextStyle(fontSize: 13, color: Color(0xFF6D6D6D))),
                            Text('50 km', style: TextStyle(fontSize: 13, color: Color(0xFF6D6D6D))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Age Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBE8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Age', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black)),
                            Text('${_ageRange.start.round()} - ${_ageRange.end.round()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.black,
                            inactiveTrackColor: const Color(0xFFDDE3EC),
                            thumbColor: Colors.black,
                            overlayColor: Colors.black12,
                          ),
                          child: RangeSlider(
                            values: _ageRange,
                            min: 18,
                            max: 60,
                            onChanged: (val) => setState(() => _ageRange = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Height Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBE8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Height', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black)),
                            Text(
                              '${_formatHeight(_heightRangeCm.start)} - ${_formatHeight(_heightRangeCm.end)}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.black,
                            inactiveTrackColor: const Color(0xFFDDE3EC),
                            thumbColor: Colors.black,
                            overlayColor: Colors.black12,
                          ),
                          child: RangeSlider(
                            values: _heightRangeCm,
                            min: 140,
                            max: 210,
                            onChanged: (val) => setState(() => _heightRangeCm = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Interested In Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEBE8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interested In',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        _buildCheckboxRow('Female', _interestedFemale, (val) => setState(() => _interestedFemale = val ?? false)),
                        const Divider(height: 18, color: Color(0xFFF0EDF5)),
                        _buildCheckboxRow('Male', _interestedMale, (val) => setState(() => _interestedMale = val ?? false)),
                        const Divider(height: 18, color: Color(0xFFF0EDF5)),
                        _buildCheckboxRow('Non-binary', _interestedNonBinary, (val) => setState(() => _interestedNonBinary = val ?? false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom Apply Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filters applied!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            Checkbox(
              value: value,
              activeColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
