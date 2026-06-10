# Typing Tutor App 🎯⌨️

A comprehensive Flutter application designed to help users improve their keyboard skills and typing speed through interactive lessons and practice modes.

## 📱 Features

### Core Features
- **Multiple Practice Modes**: Word, sentence, and paragraph typing exercises
- **Keyboard Row Training**: Progressive learning from home row to full keyboard
- **Real-time Statistics**: WPM (Words Per Minute), accuracy tracking, and progress monitoring
- **Responsive Design**: Optimized for mobile, tablet, and desktop screens
- **Visual Keyboard**: Interactive keyboard highlighting with finger placement guides
- **Progress Tracking**: Local database storage of typing records and performance history

### Practice Modes
- **Home Row**: Basic finger placement and muscle memory building
- **Extended Rows**: Top row, bottom row, and combination training
- **Shift Key Practice**: Capital letters and special characters
- **Custom Text Practice**: Words, sentences, and paragraphs with varying difficulty levels

### User Interface
- **Modern Design**: Clean, intuitive interface with smooth animations
- **Dark/Light Themes**: Adaptive UI with customizable appearance
- **Responsive Layout**: Seamless experience across different screen sizes
- **Accessibility**: Screen reader support and keyboard navigation

## 🏗️ Project Structure

The project follows a clean architecture pattern with feature-based organization:

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd typing-tutor-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

## 📖 Usage Guide

### For Users

1. **Getting Started**
   - Launch the app and explore the dashboard
   - Choose your preferred lesson type
   - Start with Home Row lessons if you're a beginner

2. **Practice Sessions**
   - Select a lesson type from the dashboard
   - Follow the on-screen keyboard guidance
   - Maintain accuracy over speed initially
   - Track your progress in the Records section

### For Developers

#### Adding New Practice Modes

1. Create a new screen in `lib/features/typing_practice/screens/`
2. Implement the practice logic following existing patterns
3. Add the screen to the barrel file
4. Update the dashboard to include the new mode

#### Customizing Themes

1. Modify constants in `lib/core/constants/app_constants.dart`
2. Update theme configuration in `lib/core/theme/app_theme.dart`
3. Test across different screen sizes using responsive helpers

## 👥 Credits

### Development Team
- **Developer**: Rajveer Parmar (21010101139)
- **Mentor**: Prof. Mehul Bhundiya (Computer Engineering Department)
- **Organization**: ASWDC, School Of Computer Science

### Acknowledgments
- Flutter team for the excellent framework
- Community contributors for packages and resources
- Beta testers for valuable feedback

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ using Flutter**
"# Typing_Tutor" 
