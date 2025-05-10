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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOrEditTodoPage(onRefresh: _refreshTodos),
                ),
              );
            },
          ),
        ],
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
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueGrey),
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.blueGrey[100],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueGrey[100]!,
                                  Colors.blueGrey[50]!,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: ListTile(
                              /// 标题
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: todo.completed,
                                    activeColor: Colors.green,
                                    shape: const CircleBorder(),
                                    onChanged: (value) async {
                                      await databaseProvider.put('todos', todo.id, todo..completed = value!);
                                      setState(() {}); // 刷新页面
                                    },
                                  ),
                                  Expanded(
                                    child: SelectableText(
                                      todo.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        decoration: todo.completed ? TextDecoration.lineThrough : null,
                                        color: todo.completed ? Colors.grey : Colors.black,
                                        decorationThickness: 2.0,
                                        decorationColor: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              /// 描述
                              subtitle: todo.completed ? null : SelectableText(
                                todo.descr,
                                maxLines: 3,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8.0,
                            right: 8.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,  color: Colors.blue,),
                                  onPressed: () {
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
                                  icon: const Icon(Icons.delete,  color: Colors.red,),
                                  onPressed: () async {
                                    await databaseProvider.delete('todos', todo.id);
                                    setState(() {}); // 刷新页面
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[50],
    );
  }
}