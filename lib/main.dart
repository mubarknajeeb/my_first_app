import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق المهام',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TodoHomeScreen(),
    );
  }
}

// نموذج بيانات المهمة
class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
}

class TodoHomeScreen extends StatefulWidget {
  const TodoHomeScreen({super.key});

  @override
  State<TodoHomeScreen> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  // قائمة المهام
  final List<Task> _tasks = [];

  // متحكم لحقل النص لإدخال المهمة
  final TextEditingController _controller = TextEditingController();

  // دالة إضافة مهمة جديدة
  void _addTask() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _tasks.add(Task(title: _controller.text));
      _controller.clear();
    });
  }

  // دالة تبديل حالة المهمة (منجزة / غير منجزة)
  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  // دالة حذف مهمة
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مهامي اليومية 📝',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // حقل الإدخال وزر الإضافة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'أضف مهمة جديدة...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('إضافة', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),

          // عرض قائمة المهام
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد مهام حالياً، أضف مهمتك الأولى! 😊',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final currentTask = _tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: currentTask.isDone,
                            onChanged: (bool? value) {
                              _toggleTask(index);
                            },
                          ),
                          title: Text(
                            currentTask.title,
                            style: TextStyle(
                              fontSize: 18,
                              decoration: currentTask.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: currentTask.isDone
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteTask(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
