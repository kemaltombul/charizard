import 'package:charizard/providers/database.dart';
import 'package:charizard/providers/word_hider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(Database.boxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WordHider()),
        ChangeNotifierProvider(create: (_) => Database()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Charizard',
        theme: ThemeData(
            primaryColor: Colors.pink,
            primarySwatch: Colors.pink,
            brightness: Brightness.dark,
            accentColor: Colors.pink),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _eng = TextEditingController();
    TextEditingController _tr = TextEditingController();
    FocusNode _focusNode = FocusNode();

    var switchValue = Provider.of<WordHider>(context).getHide();
    var allWords = Provider.of<Database>(context).allWords;

    return Scaffold(
      appBar: AppBar(
        title: Switch(
          activeColor: Theme.of(context).primaryColor,
          onChanged: (bool hide) {
            Provider.of<WordHider>(context, listen: false).setHide(hide);
          },
          value: switchValue,
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: Row(
                            children: const [
                              Icon(Icons.person),
                              SizedBox(
                                width: 12,
                              ),
                              Text("Yapımcılar")
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Divider(
                                thickness: 3,
                              ),
                              ListTile(
                                title: Text("Kemal TOMBUL"),
                                subtitle: Text("github.com/kemaltombul"),
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Umit ÇELİK"),
                                subtitle: Text("github.com/uchelikk"),
                              )
                            ],
                          ));
                    });
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          var word = allWords.elementAt(index);

          return MyListTile(
            word: word,
          );
        },
        itemCount: allWords.length,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Yeni Kelime Ekle"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        textCapitalization: TextCapitalization.words,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            labelText: "English"),
                        controller: _eng,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextField(
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            labelText: "Türkçe"),
                        controller: _tr,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      const Divider(),
                      ElevatedButton(
                        onPressed: () {
                          var engWord = _eng.value.text.toString();
                          var trWord = _tr.value.text.toString();
                          if (engWord.isNotEmpty && trWord.isNotEmpty) {
                            Provider.of<Database>(context, listen: false)
                                .addNewWord(engWord, {
                              "tr": trWord,
                              "isLearned": false,
                              "count": 0
                            });
                            _eng.text = "";
                            _tr.text = "";
                            _focusNode.previousFocus();
                          }
                        },
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                );
              });
        },
        tooltip: 'Yeni Kelime Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyListTile extends StatefulWidget {
  const MyListTile({Key? key, required this.word}) : super(key: key);
  final MapEntry word;

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  bool isShow = false;
  @override
  Widget build(BuildContext context) {
    var hidedWord = "*****";
    return InkWell(
      onTap: () {
        showGeneralDialog(
          transitionDuration: const Duration(milliseconds: 300),
          context: context,
          barrierLabel: widget.word.key,
          barrierDismissible: true,
          barrierColor: Theme.of(context).colorScheme.primary.withAlpha(10),
          pageBuilder: (context, animation, secondaryAnimation) {
            FocusNode _focusNode = FocusNode();
            TextEditingController _eng = TextEditingController();
            TextEditingController _tr = TextEditingController();

            _tr.text = widget.word.value["tr"].toString();
            _eng.text = widget.word.key.toString();

            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        labelText: "English"),
                    controller: _eng,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        labelText: "Türkçe"),
                    controller: _tr,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          var engWord = _eng.value.text.toString();
                          var trWord = _tr.value.text.toString();
                          var word = Database.box.get(widget.word.key);
                          if (engWord.isNotEmpty && trWord.isNotEmpty) {
                            Provider.of<Database>(context, listen: false)
                                .addNewWord(engWord, {
                              "tr": trWord,
                              "isLearned": word["isLearned"],
                              "count": word["count"],
                            });
                            _eng.text = "";
                            _tr.text = "";
                            _focusNode.previousFocus();
                          }

                          Navigator.pop(context, true);
                        },
                        child: const Text('Güncelle'),
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<Database>(context, listen: false)
                              .deleteWord(widget.word.key);
                          Navigator.pop(context, true);
                        },
                        child: const Text('Sil'),
                      ),
                    ],
                  )
                ],
              ),
              title: ListTile(
                title: Text(widget.word.key.toString()),
                subtitle: Text(widget.word.value["tr"].toString()),
              ),
            );
          },
        );
      },
      child: ListTile(
        title: Text(widget.word.key.toString()),
        subtitle: Text(
          Provider.of<WordHider>(context).getHide()
              ? widget.word.value["tr"].toString()
              : isShow
                  ? widget.word.value["tr"].toString()
                  : hidedWord,
        ),
        enableFeedback: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              color: Theme.of(context).primaryColor,
              iconSize: 48,
              onPressed: () {
                Provider.of<Database>(context, listen: false)
                    .incrementCount(widget.word.key);
              },
              icon: const Icon(Icons.add),
              tooltip: "Tekrar sayısı",
            ),
            const SizedBox(width: 8),
            Text(
              widget.word.value["count"].toString(),
            ),
            const SizedBox(width: 20),
            IconButton(
                onPressed: () {
                  setState(() {
                    isShow = !isShow;
                  });
                },
                icon: Icon(isShow
                    ? Icons.remove_red_eye_outlined
                    : Icons.remove_red_eye))
          ],
        ),
      ),
    );
  }
}
