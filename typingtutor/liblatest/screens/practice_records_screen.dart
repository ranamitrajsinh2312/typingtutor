import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/utils/responsive_helper.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

class PracticeRecordsScreen extends StatefulWidget {
  const PracticeRecordsScreen({super.key});

  @override
  State<PracticeRecordsScreen> createState() => _PracticeRecordsScreenState();
}

class _PracticeRecordsScreenState extends State<PracticeRecordsScreen> {
  List<TypingRecord> allRecords = [];
  bool isLoading = true;
  String sortBy = 'date';
  bool isAscending = false;
  String currentUsername = AppConstants.defaultUsername;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadUserData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    await _loadUsername();
    await _loadRecords();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString(AppKeys.username) ?? AppConstants.defaultUsername;
    setState(() {
      currentUsername = savedUsername;
    });
  }

  Future<void> _loadRecords() async {
    try {
      final records = await DatabaseHelper.instance.fetchAllRecords();
      setState(() {
        allRecords = records;
        isLoading = false;
      });
      _sortRecords();
    } catch (e) {
      print('Error loading records: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _sortRecords() {
    setState(() {
      allRecords.sort((a, b) {
        late int comparison;
        switch (sortBy) {
          case 'wpm':
            comparison = a.wpm.compareTo(b.wpm);
            break;
          case 'accuracy':
            comparison = a.accuracy.compareTo(b.accuracy);
            break;
          case 'date':
          default:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
        }
        return isAscending ? comparison : -comparison;
      });
    });
  }

  void _changeSortOrder(String newSortBy) {
    setState(() {
      if (sortBy == newSortBy) {
        isAscending = !isAscending;
      } else {
        sortBy = newSortBy;
        isAscending = false;
      }
    });
    _sortRecords();
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppText.clearAllRecords),
          content: Text(AppText.clearAllRecordsConfirm),
          actions: <Widget>[
            TextButton(
              child: Text(AppText.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppText.deleteAll),
              onPressed: () async {
                try {
                  await DatabaseHelper.instance.resetData();
                  Navigator.of(context).pop();
                  _loadRecords();
                  Get.snackbar(
                    'Success',
                    'All records deleted successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(12),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  Get.snackbar(
                    'Error',
                    'Error deleting records: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(12),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final layoutType = ResponsiveHelper.getLayoutType(context);
    final maxContainerWidth = ResponsiveHelper.getMaxContainerWidth(context);
   // final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    //final responsiveMargin = ResponsiveHelper.getResponsiveMargin(context);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.large);
    final iconSize = ResponsiveHelper.getIconSize(context, IconSizeType.medium);
    //final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.medium);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
          title: Text(
          AppText.practiceRecords,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: titleFontSize,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white, size: iconSize),
            onSelected: _changeSortOrder,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'date',
                child: _buildSortMenuItem(
                  context,
                  Icons.access_time,
                  AppText.sortByDate,
                  'date',
                ),
              ),
              PopupMenuItem(
                value: 'wpm',
                child: _buildSortMenuItem(
                  context,
                  Icons.speed,
                  AppText.sortByWpm,
                  'wpm',
                ),
              ),
              PopupMenuItem(
                value: 'accuracy',
                child: _buildSortMenuItem(
                  context,
                  Icons.golf_course,
                  AppText.sortByAccuracy,
                  'accuracy',
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.white, size: iconSize),
            onPressed: allRecords.isNotEmpty ? _showDeleteConfirmation : null,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContainerWidth),
          child: isLoading
              ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          )
              : allRecords.isEmpty
              ? _buildEmptyState(context)
              : _buildRecordsContent(context, layoutType),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRecords,
        backgroundColor: Colors.blue.shade700,
        child: Icon(Icons.refresh, color: Colors.white, size: iconSize),
        tooltip: AppText.refreshRecords,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final iconSize = ResponsiveHelper.getIconSize(context, IconSizeType.extraLarge);
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.extraLarge);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.medium);
    final buttonFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.medium);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.medium);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.medium);
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);

    return Center(
      child: Padding(
        padding: responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: iconSize,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: spacing),
            Text(
              AppText.noRecordsYet,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing / 2),
            Text(
              AppText.recordsEmptySubtitle,
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing * 1.5),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.keyboard, size: ResponsiveHelper.getIconSize(context, IconSizeType.small)),
              label: Text(
                AppText.startPracticing,
                style: TextStyle(fontSize: buttonFontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing * 1.5,
                  vertical: spacing * 0.75,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value, IconData icon) {
    final iconSize = ResponsiveHelper.getIconSize(context, IconSizeType.medium);
    final valueFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.large);
    final labelFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.small);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.small);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: iconSize),
        SizedBox(height: spacing),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80), // Limit text width
          child: Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: spacing / 2),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80), // Limit text width
          child: Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getWpmColor(int wpm) {
    if (wpm >= AppConstants.excellentWpm) return Colors.green;
    if (wpm >= AppConstants.goodWpm) return Colors.blue;
    if (wpm >= AppConstants.averageWpm) return Colors.orange;
    return Colors.red;
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= AppConstants.excellentAccuracy) return Colors.green;
    if (accuracy >= AppConstants.goodAccuracy) return Colors.blue;
    if (accuracy >= AppConstants.averageAccuracy) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildSortMenuItem(BuildContext context, IconData icon, String text, String value) {
    final iconSize = ResponsiveHelper.getIconSize(context, IconSizeType.small);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.medium);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.small);

    return Row(
      children: [
        Icon(icon, size: iconSize),
        SizedBox(width: spacing),
        Text(
          text,
          style: TextStyle(fontSize: fontSize),
        ),
        if (sortBy == value) ...[
          Spacer(),
          Icon(
            isAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: iconSize * 0.8,
          ),
        ],
      ],
    );
  }

  Widget _buildRecordsContent(BuildContext context, LayoutType layoutType) {
    final responsiveMargin = ResponsiveHelper.getResponsiveMargin(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.medium);

    return Column(
      children: [
        _buildSummarySection(context, layoutType),
        Expanded(
          child: _buildRecordsList(context, layoutType),
        ),
      ],
    );
  }

  Widget _buildSummarySection(BuildContext context, LayoutType layoutType) {
    final responsiveMargin = ResponsiveHelper.getResponsiveMargin(context);
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.medium);

    return Container(
      width: double.infinity,
      margin: responsiveMargin,
      padding: responsivePadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildSummaryLayout(context, layoutType),
      ),
    );
  }

  Widget _buildSummaryLayout(BuildContext context, LayoutType layoutType) {
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.small);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem(
          context,
          'Total Records',
          '${allRecords.length}',
          Icons.list_alt,
        ),
        SizedBox(width: spacing),
        _buildSummaryItem(
          context,
          'Best WPM',
          '${allRecords.isEmpty ? 0 : allRecords.map((r) => r.wpm).reduce((a, b) => a > b ? a : b)}',
          Icons.speed,
        ),
        SizedBox(width: spacing),
        _buildSummaryItem(
          context,
          'Avg Accuracy',
          '${allRecords.isEmpty ? 0 : (allRecords.map((r) => r.accuracy).reduce((a, b) => a + b) / allRecords.length).toInt()}%',
          Icons.golf_course,
        ),
      ],
    );
  }

  Widget _buildRecordsList(BuildContext context, LayoutType layoutType) {
    final responsiveMargin = ResponsiveHelper.getResponsiveMargin(context);

    return ListView.builder(
      padding: responsiveMargin,
      itemCount: allRecords.length,
      itemBuilder: (context, index) => _buildRecordCard(context, allRecords[index], index),
    );
  }

  Widget _buildRecordCard(BuildContext context, TypingRecord record, int index) {
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.medium);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.small);

    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: responsivePadding,
        child: _buildRecordCardContent(context, record, index),
      ),
    );
  }

  Widget _buildRecordCardContent(BuildContext context, TypingRecord record, int index) {
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.small);

    return Row(
      children: [
        _buildWpmBadge(context, record),
        SizedBox(width: spacing),
        Expanded(
          child: _buildRecordContent(context, record),
        ),
        SizedBox(width: spacing),
        _buildRecordTrailing(context, index),
      ],
    );
  }

  Widget _buildWpmBadge(BuildContext context, TypingRecord record) {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.medium);
    final smallFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.small);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.small);

    final badgeSize = 55.0;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: _getWpmColor(record.wpm).withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${record.wpm}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: _getWpmColor(record.wpm),
            ),
          ),
          Text(
            'WPM',
            style: TextStyle(
              fontSize: smallFontSize - 2,
              color: _getWpmColor(record.wpm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordContent(BuildContext context, TypingRecord record) {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.medium);
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.small);
    final iconSize = ResponsiveHelper.getIconSize(context, IconSizeType.small);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.small);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.medium);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.person,
              size: iconSize,
              color: Colors.grey.shade600,
            ),
            SizedBox(width: spacing / 2),
            Flexible(
              child: Text(
                currentUsername,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: titleFontSize,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: spacing),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing,
                vertical: spacing / 4,
              ),
              decoration: BoxDecoration(
                color: _getAccuracyColor(record.accuracy).withOpacity(0.1),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: _getAccuracyColor(record.accuracy).withOpacity(0.3),
                ),
              ),
              child: Text(
                '${record.accuracy.toInt()}%',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w600,
                  color: _getAccuracyColor(record.accuracy),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: iconSize * 0.9,
              color: Colors.grey.shade500,
            ),
            SizedBox(width: spacing / 2),
            Flexible(
              child: Text(
                record.country,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: spacing),
            Icon(
              Icons.access_time,
              size: iconSize * 0.9,
              color: Colors.grey.shade500,
            ),
            SizedBox(width: spacing / 2),
            Flexible(
              child: Text(
                _formatDate(record.createdAt),
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordTrailing(BuildContext context, int index) {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.small);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.small);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.small);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing,
        vertical: spacing / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        '#${index + 1}',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}