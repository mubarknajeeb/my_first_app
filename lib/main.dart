import 'package:flutter/material.dart';

void main() {
  runApp(const TaskManagerApp());
}

// ─────────────────────────── نماذج البيانات ───────────────────────────

enum TaskCategory { work, study, personal }

enum TaskPriority { high, medium, low }

enum FilterType { all, inProgress, completed }

class Task {
  String id;
  String title;
  bool isDone;
  TaskCategory category;
  TaskPriority priority;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.category,
    required this.priority,
    required this.createdAt,
  });

  Task copyWith({
    String? title,
    bool? isDone,
    TaskCategory? category,
    TaskPriority? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }
}

// ─────────────────────────── ثوابت التصميم ───────────────────────────

class AppColors {
  static const Color primaryLight = Color(0xFF6C5CE7);
  static const Color secondaryLight = Color(0xFFA29BFE);
  static const Color bgLight = Color(0xFFF8F7FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  static const Color primaryDark = Color(0xFF8B7FFF);
  static const Color secondaryDark = Color(0xFF6C5CE7);
  static const Color bgDark = Color(0xFF0F0E1A);
  static const Color surfaceDark = Color(0xFF1A1830);
  static const Color cardDark = Color(0xFF1E1C35);

  static const Color priorityHigh = Color(0xFFFF6B6B);
  static const Color priorityMedium = Color(0xFFFFA502);
  static const Color priorityLow = Color(0xFF2ED573);

  static const Color categoryWork = Color(0xFF4ECDC4);
  static const Color categoryStudy = Color(0xFFFFBE76);
  static const Color categoryPersonal = Color(0xFFFF7675);
}

// ─────────────────────────── دوال مساعدة ───────────────────────────

String categoryLabel(TaskCategory c) {
  switch (c) {
    case TaskCategory.work:
      return 'عمل';
    case TaskCategory.study:
      return 'دراسة';
    case TaskCategory.personal:
      return 'شخصي';
  }
}

String categoryIcon(TaskCategory c) {
  switch (c) {
    case TaskCategory.work:
      return '💼';
    case TaskCategory.study:
      return '📚';
    case TaskCategory.personal:
      return '🏠';
  }
}

Color categoryColor(TaskCategory c) {
  switch (c) {
    case TaskCategory.work:
      return AppColors.categoryWork;
    case TaskCategory.study:
      return AppColors.categoryStudy;
    case TaskCategory.personal:
      return AppColors.categoryPersonal;
  }
}

String priorityLabel(TaskPriority p) {
  switch (p) {
    case TaskPriority.high:
      return 'عالية';
    case TaskPriority.medium:
      return 'متوسطة';
    case TaskPriority.low:
      return 'منخفضة';
  }
}

Color priorityColor(TaskPriority p) {
  switch (p) {
    case TaskPriority.high:
      return AppColors.priorityHigh;
    case TaskPriority.medium:
      return AppColors.priorityMedium;
    case TaskPriority.low:
      return AppColors.priorityLow;
  }
}

// ─────────────────────────── التطبيق الرئيسي ───────────────────────────

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  bool _isDarkMode = false;

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدير المهام',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(isDarkMode: _isDarkMode, onToggleTheme: _toggleTheme),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
    );
  }
}

// ─────────────────────────── الشاشة الرئيسية ───────────────────────────

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'مراجعة تقرير المشروع',
      isDone: true,
      category: TaskCategory.work,
      priority: TaskPriority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'دراسة الفصل الخامس',
      isDone: false,
      category: TaskCategory.study,
      priority: TaskPriority.medium,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Task(
      id: '3',
      title: 'ممارسة الرياضة',
      isDone: false,
      category: TaskCategory.personal,
      priority: TaskPriority.low,
      createdAt: DateTime.now(),
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  FilterType _currentFilter = FilterType.all;
  String _searchQuery = '';
  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  // ─── فلترة المهام ───

  List<Task> get _filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesFilter;
      switch (_currentFilter) {
        case FilterType.all:
          matchesFilter = true;
          break;
        case FilterType.inProgress:
          matchesFilter = !task.isDone;
          break;
        case FilterType.completed:
          matchesFilter = task.isDone;
          break;
      }
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _completedCount => _tasks.where((t) => t.isDone).length;
  double get _progress => _tasks.isEmpty ? 0 : _completedCount / _tasks.length;

  // ─── عمليات المهام ───

  void _addTask(Task task) => setState(() => _tasks.insert(0, task));

  void _toggleTask(String id) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx != -1) _tasks[idx].isDone = !_tasks[idx].isDone;
    });
  }

  void _deleteTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    setState(() => _tasks.removeWhere((t) => t.id == id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف "${task.title}"'),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () => setState(() => _tasks.add(task)),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _editTask(Task original) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(
        existingTask: original,
        onSave: (updated) {
          setState(() {
            final idx = _tasks.indexWhere((t) => t.id == original.id);
            if (idx != -1) _tasks[idx] = updated;
          });
        },
      ),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(onSave: _addTask),
    );
  }

  // ─── واجهة البناء ───

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ─── AppBar مع البطاقة العلوية ───
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderCard(primary, isDark, textColor),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: widget.onToggleTheme,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Icon(
                      isDark
                          ? Icons.wb_sunny_rounded
                          : Icons.nights_stay_rounded,
                      key: ValueKey(isDark),
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                ),
              ),
            ],
          ),

          // ─── شريط البحث ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildSearchBar(isDark, cardColor, textColor, primary),
            ),
          ),

          // ─── أزرار الفلترة ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildFilterChips(primary, isDark, textColor),
            ),
          ),

          // ─── قائمة المهام ───
          _filteredTasks.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState(textColor))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) => _buildTaskCard(
                      _filteredTasks[index],
                      isDark,
                      cardColor,
                      textColor,
                      primary,
                    ),
                    childCount: _filteredTasks.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimController,
        child: FloatingActionButton.extended(
          onPressed: _openAddSheet,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded, size: 28),
          label: const Text(
            'مهمة جديدة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          elevation: 6,
        ),
      ),
    );
  }

  // ─── البطاقة العلوية ───

  Widget _buildHeaderCard(Color primary, bool isDark, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            primary,
            isDark ? const Color(0xFF4A3FA0) : const Color(0xFF9C88FF),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('📋', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'مدير المهام',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المهام المكتملة',
                        style: TextStyle(
                          color: Colors.white.withAlpha(204),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_completedCount / ${_tasks.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 7,
                          backgroundColor: Colors.white.withAlpha(76),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (_, val, __) => LinearProgressIndicator(
                    value: val,
                    minHeight: 10,
                    backgroundColor: Colors.white.withAlpha(76),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── شريط البحث ───

  Widget _buildSearchBar(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color primary,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 76 : 20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        style: TextStyle(color: textColor, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'ابحث عن مهمة...',
          hintTextDirection: TextDirection.rtl,
          hintStyle: TextStyle(color: textColor.withAlpha(102)),
          prefixIcon: Icon(Icons.search_rounded, color: primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: textColor.withAlpha(128),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  // ─── أزرار الفلترة ───

  Widget _buildFilterChips(Color primary, bool isDark, Color textColor) {
    final filters = {
      FilterType.all: 'الكل',
      FilterType.inProgress: 'قيد الإنجاز',
      FilterType.completed: 'المكتملة',
    };

    return Row(
      children: filters.entries.map((entry) {
        final isSelected = _currentFilter == entry.key;
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: ChoiceChip(
              label: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: primary,
              backgroundColor: isDark
                  ? AppColors.cardDark
                  : Colors.grey.shade100,
              side: BorderSide(
                color: isSelected ? primary : Colors.transparent,
              ),
              onSelected: (_) => setState(() => _currentFilter = entry.key),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── بطاقة المهمة مع السحب للحذف ───

  Widget _buildTaskCard(
    Task task,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color primary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsetsDirectional.only(end: 20),
          decoration: BoxDecoration(
            color: AppColors.priorityHigh.withAlpha(216),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text('حذف', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
        onDismissed: (_) => _deleteTask(task.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              right: BorderSide(color: priorityColor(task.priority), width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 64 : 18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _editTask(task),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _buildCheckbox(task, primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: task.isDone
                                ? textColor.withAlpha(102)
                                : textColor,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: textColor.withAlpha(102),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildBadge(
                              '${categoryIcon(task.category)} ${categoryLabel(task.category)}',
                              categoryColor(task.category),
                            ),
                            const SizedBox(width: 6),
                            _buildBadge(
                              priorityLabel(task.priority),
                              priorityColor(task.priority),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_note_rounded,
                      color: primary.withAlpha(178),
                      size: 22,
                    ),
                    onPressed: () => _editTask(task),
                    tooltip: 'تعديل',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(Task task, Color primary) {
    return GestureDetector(
      onTap: () => _toggleTask(task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: task.isDone ? primary : Colors.transparent,
          border: Border.all(
            color: task.isDone ? primary : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: task.isDone
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(102), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'لا توجد مهام',
            style: TextStyle(
              color: textColor.withAlpha(153),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط + لإضافة مهمة جديدة',
            style: TextStyle(color: textColor.withAlpha(102), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── نموذج الإضافة / التعديل ───────────────────────────

class TaskFormSheet extends StatefulWidget {
  final Task? existingTask;
  final Function(Task) onSave;

  const TaskFormSheet({super.key, this.existingTask, required this.onSave});

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  late final TextEditingController _titleController;
  late TaskCategory _selectedCategory;
  late TaskPriority _selectedPriority;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _selectedCategory = t?.category ?? TaskCategory.personal;
    _selectedPriority = t?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    final task =
        widget.existingTask?.copyWith(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
        ) ??
        Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          createdAt: DateTime.now(),
        );
    widget.onSave(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 20,
          left: 24,
          right: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض السحب
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(102),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _isEditing ? 'تعديل المهمة ✏️' : 'مهمة جديدة ✨',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),

              // حقل اسم المهمة
              TextField(
                controller: _titleController,
                textDirection: TextDirection.rtl,
                autofocus: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'اسم المهمة',
                  labelStyle: TextStyle(color: textColor.withAlpha(153)),
                  hintText: 'أدخل وصف المهمة...',
                  hintStyle: TextStyle(color: textColor.withAlpha(76)),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withAlpha(18)
                      : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                  prefixIcon: Icon(Icons.task_alt_rounded, color: primary),
                ),
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 20),

              // اختيار التصنيف
              Text(
                'التصنيف',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: TaskCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final color = categoryColor(cat);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withAlpha(51)
                              : (isDark
                                    ? Colors.white.withAlpha(13)
                                    : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              categoryIcon(cat),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              categoryLabel(cat),
                              style: TextStyle(
                                color: isSelected
                                    ? color
                                    : textColor.withAlpha(153),
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // اختيار الأولوية
              Text(
                'الأولوية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: TaskPriority.values.map((p) {
                  final isSelected = _selectedPriority == p;
                  final color = priorityColor(p);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPriority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withAlpha(46)
                              : (isDark
                                    ? Colors.white.withAlpha(13)
                                    : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              priorityLabel(p),
                              style: TextStyle(
                                color: isSelected
                                    ? color
                                    : textColor.withAlpha(153),
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(
                    _isEditing ? Icons.save_rounded : Icons.add_circle_rounded,
                    size: 22,
                  ),
                  label: Text(
                    _isEditing ? 'حفظ التعديلات' : 'إضافة المهمة',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: primary.withAlpha(102),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
