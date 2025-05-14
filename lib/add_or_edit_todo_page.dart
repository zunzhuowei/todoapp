import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_provider.dart';
import 'todo.dart';

class AddOrEditTodoPage extends StatefulWidget {
  final String? selectedTodoKey;
  final VoidCallback? onRefresh; // 新增：回调函数用于刷新主页面

  const AddOrEditTodoPage({super.key, this.selectedTodoKey, this.onRefresh});

  @override
  State<AddOrEditTodoPage> createState() => _AddOrEditTodoPageState();
}

class _AddOrEditTodoPageState extends State<AddOrEditTodoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descrController = TextEditingController();
  DateTime? _notificationTime; // 新增：存储通知时间

  @override
  void initState() {
    super.initState();
    if (widget.selectedTodoKey != null) {
      _loadTodoDetails();
    }
  }

  ///  加载待办详情
  Future<void> _loadTodoDetails() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final todo = await databaseProvider.getEntity('todos', widget.selectedTodoKey!, Todo.fromJson);
    if (todo != null) {
      _titleController.text = todo.title;
      _descrController.text = todo.descr;
      _notificationTime = todo.notificationTime; // 加载已有通知时间
      setState(() {});
    }
  }

  ///  选择通知时间
  Future<void> _selectNotificationTime() async { // 新增时间选择方法
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _notificationTime = DateTime(
          date.year, date.month, date.day,
          time.hour, time.minute
        );
      });
    }
  }

  ///  构建时间选择组件
  Widget _buildTimePicker() { // 新增时间选择组件
    return Row(
      children: [
        Text(_notificationTime == null 
          ? "未设置提醒" 
          : "提醒时间: ${_notificationTime!.toLocal().toString().substring(0, 16)}"),
        IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: _selectNotificationTime,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedTodoKey != null ? '编辑待办' : '添加待办'), // 根据模式动态设置标题
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '标题',
                helperText: '请输入待办事项的标题'
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descrController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '描述',
                  helperText: '请输入待办事项的描述'
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            _buildTimePicker(), // 添加时间选择组件
            ElevatedButton(
              onPressed: () async {
                await _submitForm(databaseProvider);
              },
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }

  ///  提交表单
  Future<void> _submitForm(DatabaseProvider databaseProvider) async {
    if (_titleController.text.isNotEmpty) {
      final todo = Todo(
        id: widget.selectedTodoKey ?? DateTime.now().toString(),
        title: _titleController.text,
        descr: _descrController.text,
        notificationTime: _notificationTime, // 添加通知时间
        nextNotificationTime: _notificationTime,
      );
      await databaseProvider.put('todos', todo.id, todo);
      Navigator.pop(context); // 返回主页面
      widget.onRefresh?.call(); // 调用回调函数刷新主页面
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text('请填写标题和描述', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }
  }
}