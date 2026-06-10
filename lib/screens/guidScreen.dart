import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:typingtutor/constants/practice_content.dart';
import 'package:typingtutor/constants/language_config.dart';
import 'package:typingtutor/screens/practice_screen.dart';

// Legacy Lesson class kept for backward compatibility with level system
class Lesson {
  final String type;
  final String content;
  final String difficulty;
  final String languageCode;

  const Lesson({
    required this.type,
    required this.content,
    required this.difficulty,
    this.languageCode = 'en',
  });
}

// Build legacy `lessons` list from PracticeContent so nothing else breaks.
List<Lesson> get lessons => [
  for (final lang in LanguageConfig.codes)
    for (final type in PracticeType.values)
      for (final diff in PracticeDifficulty.values)
        for (final item in PracticeContent.forLanguage(lang).get(type: type, difficulty: diff))
          Lesson(
            type: type.name,
            content: item.text,
            difficulty: diff.name,
            languageCode: lang,
          ),
];

// =============================================================================
// GuideScreen — practice mode selector
// =============================================================================

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  String _lang = 'en';
  String _type = 'word';
  String _diff = 'easy';

  List<PracticeItem> get _items =>
      PracticeContent.forLanguage(_lang).get(
        type:       _toType(_type),
        difficulty: _toDiff(_diff),
      );

  static PracticeType _toType(String s) {
    switch (s) {
      case 'sentence':  return PracticeType.sentence;
      case 'paragraph': return PracticeType.paragraph;
      default:          return PracticeType.word;
    }
  }

  static PracticeDifficulty _toDiff(String s) {
    switch (s) {
      case 'medium': return PracticeDifficulty.medium;
      case 'hard':   return PracticeDifficulty.hard;
      default:       return PracticeDifficulty.easy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Practice Guide'),
        backgroundColor: const Color(0xFFFD8469),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(children: [
        _buildFilters(),
        Expanded(child: _buildList()),
      ]),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(children: [
        _filterRow('Language', [
          for (final m in LanguageConfig.all)
            _Chip(label: m.nativeName, value: m.code, selected: _lang,
                onTap: (v) => setState(() => _lang = v)),
        ]),
        const SizedBox(height: 8),
        _filterRow('Type', [
          _Chip(label: 'Word',      value: 'word',      selected: _type, onTap: (v) => setState(() => _type = v)),
          _Chip(label: 'Sentence',  value: 'sentence',  selected: _type, onTap: (v) => setState(() => _type = v)),
          _Chip(label: 'Paragraph', value: 'paragraph', selected: _type, onTap: (v) => setState(() => _type = v)),
        ]),
        const SizedBox(height: 8),
        _filterRow('Difficulty', [
          _Chip(label: 'Easy',   value: 'easy',   selected: _diff, onTap: (v) => setState(() => _diff = v)),
          _Chip(label: 'Medium', value: 'medium', selected: _diff, onTap: (v) => setState(() => _diff = v)),
          _Chip(label: 'Hard',   value: 'hard',   selected: _diff, onTap: (v) => setState(() => _diff = v)),
        ]),
      ]),
    );
  }

  Widget _filterRow(String label, List<Widget> chips) => Row(children: [
    SizedBox(width: 76, child: Text(label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54))),
    ...chips.map((c) => Padding(padding: const EdgeInsets.only(right: 6), child: c)),
  ]);

  Widget _buildList() {
    final items = _items;
    if (items.isEmpty) {
      return const Center(child: Text('No content available for this selection.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        final ff   = LanguageConfig.fontFamily(item.languageCode);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            title: Text(item.text,
                style: TextStyle(fontSize: 15, fontFamily: ff),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${item.type.name} · ${item.difficulty.name}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD8469),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () => Get.toNamed(
                AppRoutes.practice,
                arguments: {
                  'lessonType':   item.type.name,
                  'difficulty':   item.difficulty.name,
                  'languageCode': item.languageCode,
                },
              ),
              child: const Text('Start', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
        );
      },
    );
  }
}

// Small reusable filter chip
class _Chip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _Chip({required this.label, required this.value,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sel = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFFD8469) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel ? const Color(0xFFFD8469) : Colors.grey.shade300),
        ),
        child: Text(label,
          style: TextStyle(
            color: sel ? Colors.white : Colors.black87,
            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
