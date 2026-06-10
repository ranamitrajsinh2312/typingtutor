// ==============================
// 📦 Dart Core Libraries
// ==============================
export 'dart:async';
export 'dart:io';
export 'dart:math';

// ==============================
// 💙 Flutter SDK Libraries
// ==============================
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
export 'package:path_provider/path_provider.dart';

// ==============================
// 🌐 Third-Party Packages
// ==============================
export 'package:animated_text_kit/animated_text_kit.dart';
export 'package:flutter_animate/flutter_animate.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:aswdc_admob/aswdc_admob.dart';
export 'package:aswdc_flutter_pub/aswdc_flutter_pub.dart';
export 'package:google_mobile_ads/google_mobile_ads.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:dotted_border/dotted_border.dart';
export 'package:audioplayers/audioplayers.dart';
export 'package:audioplayers/src/source.dart';
export 'package:shared_preferences/shared_preferences.dart';

// ==============================
// 🏠 Local Project Files
// ==============================
// Screens
export 'package:typingtutor/screens/dashboard.dart';
//export 'package:typingtutor/screens/devloper_screen.dart';
export 'package:typingtutor/screens/guidScreen.dart';
export 'package:typingtutor/screens/profile.dart';
export 'package:typingtutor/screens/splash.dart';
export 'package:typingtutor/screens/practice_screen.dart';
export 'package:typingtutor/screens/key_guide_screen.dart';
export 'package:typingtutor/screens/practice_records_screen.dart';
export 'package:typingtutor/screens/levels_screen.dart';
export 'package:typingtutor/screens/level_practice_screen.dart';
export 'package:typingtutor/screens/level_completion_screen.dart';
export 'package:typingtutor/screens/keyboard_lesson_screen.dart';
export 'package:typingtutor/screens/keyboard_lessons_list_screen.dart';

// Models
export 'package:typingtutor/models/typing_record.dart';
export 'package:typingtutor/models/typing_stats.dart';
export 'package:typingtutor/models/keyboard_layout.dart';
export 'package:typingtutor/models/practice_level.dart';
export 'package:typingtutor/models/keyboard_lesson.dart';

// Widgets
export 'package:typingtutor/widgets/keyboardUi.dart';
export 'package:typingtutor/widgets/multilingual_keyboard.dart';

// Controllers
export 'package:typingtutor/controllers/keyboard_controller.dart';
export 'package:typingtutor/controllers/levels_controller.dart';
export 'package:typingtutor/controllers/typing_controller.dart';

// Data
export 'package:typingtutor/data/keyboard_layouts_data.dart';
export 'package:typingtutor/data/keyboard_lessons_data.dart';
export 'package:typingtutor/data/finger_mapping_data.dart';

// Services
export 'package:typingtutor/services/function.dart';
export 'package:typingtutor/database/database_helper.dart';

// Utils
export 'package:typingtutor/utils/theme.dart';
export 'package:typingtutor/utils/admob_unit_id.dart';

export 'package:typingtutor/utils/colors.dart';
