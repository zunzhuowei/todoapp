import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_provider.dart';
import 'todo.dart';
import 'add_or_edit_todo_page.dart'; // 更新：引入新文件名

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseProvider databaseProvider = DatabaseProvider();
  await databaseProvider.init();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DatabaseProvider>(create: (_) => databaseProvider),
        ],
        child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MyHomePage()
        ),
      )
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 新增：定义刷新方法
  void _refreshTodos() {
    setState(() {}); // 刷新页面
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, Todo>>(
              future: databaseProvider.getAllEntity('todos', Todo.fromJson),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final todos = snapshot.data?.entries.toList() ?? [];
                  return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index].value;
                      return ListTile(
                        title: Text(todo.title),
                        subtitle: Text(todo.descr),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // 编辑模式：传递 selectedTodoKey 和刷新回调
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddOrEditTodoPage(
                                          selectedTodoKey: todo.id,
                                          onRefresh: _refreshTodos,
                                        ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await databaseProvider.delete('todos', todo.id);
                                setState(() {}); // 刷新页面
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 添加模式：传递刷新回调
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddOrEditTodoPage(onRefresh: _refreshTodos),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.blueGrey[50],
    );
  }
}