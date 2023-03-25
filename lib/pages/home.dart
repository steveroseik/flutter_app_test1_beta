import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  List<Article> viewList = <Article>[];
  List<Article> articles =  [];
  TextEditingController nameController = TextEditingController();
  String searchArt = '';
  int currentLength = 0;
  final int increment = 10;
  List<Article> data = [];
  bool isLoading = false;

  @override
  void initState(){
    super.initState();
    getWebsiteData();
    _loadMore();
  }


  Future getWebsiteData() async {
    var categoryUrl = ['https://www.thesprucepets.com/dogs-health-4162140',
      'https://www.thesprucepets.com/dog-nutrition-and-food-4162139',
      'https://www.thesprucepets.com/dog-breeds-4162141',
      'https://www.thesprucepets.com/dog-behavior-and-training-4162131'];

    for(var i = 0; i <= 3; i++) {
      final url = Uri.parse(categoryUrl[i]);
      final response = await http.get(url);

      dom.Document html = dom.Document.html(response.body);

      final titles = html
          .querySelectorAll('div.card__content > span > span')
          .map((element) => element.innerHtml.trim())
          .toList();

      final urls = html
          .querySelectorAll('a.mntl-card-list-items')
          .map((element) => '${element.attributes['href']}')
          .toList();

      final urlImages = html
          .querySelectorAll('div.card__media > img')
          .map((element) => "${element.attributes['data-src']}")
          .toList();

      final category = List<String>.generate(titles.length, (index) {
        switch(i){
          case 0: return 'food';
          case 1: return 'health';
          case 2: return 'breeds';
          case 3: return 'training';
        }
        return 'Not';
      });

      articles.addAll(List.generate(
        titles.length, (index) => Article(
        title: titles[index],
        url: urls[index],
        urlImage: urlImages[index],
        type: category[index],
      ),
      ));
    }

    viewList.addAll(articles);
    setState(() {
    });
  }

  searchArticle(String s) {
    String search = " ";
    if(s.isNotEmpty) {
      search = s[0].toUpperCase() + s.substring(1);
    }
    viewList.clear();
    for (Article i in articles) {
      if (i.title.contains(search)) {
        viewList.add(i);
      }
    }
  }

  getCategory(String s){
    viewList.clear();
    for (Article i in articles){
      if (i.type == s){
        viewList.add(i);
      }
    }
    setState(() { });
  }

  Future _loadMore() async {
    setState(() {
      isLoading = true;
    });

    // Add in an artificial delay
    await new Future.delayed(const Duration(seconds: 2));
    data = viewList;
    viewList.clear();
    for (var i = currentLength; i <= currentLength + increment; i++) {
      for (Article art in data.getRange(0, currentLength)) {
        viewList.add(art);
      }
    }
    setState(() {
      isLoading = false;
      currentLength = viewList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap:(){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child:Scaffold(
            appBar: init_appBar(UserNav_key),
            body: Column(
                children: <Widget>[
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                      ),
                      hintText: 'Search article',
                      hintStyle:
                      TextStyle(letterSpacing: 1, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    controller: nameController,
                    onChanged: (text){
                      setState(() {
                        searchArt = text;
                      });
                      print(nameController.text);
                      searchArticle(nameController.text);
                    }
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: height*0.16,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  // height: 50,
                                  // width: 50,
                                  onPressed: () {
                                    getCategory('food');
                                  },
                                  icon: Image.asset(categories[0]['imagePath']),
                                  iconSize: 38,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                categories[0]['name'],
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10.0,),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    getCategory('health');
                                  },
                                  icon: Image.asset(categories[1]['imagePath']),
                                  iconSize: 38,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                categories[1]['name'],
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  // height: 50,
                                  // width: 50,
                                  onPressed: () {
                                    getCategory('breeds');
                                  },
                                  icon: Image.asset(categories[2]['imagePath']),
                                  iconSize: 38,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                categories[2]['name'],
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  // height: 50,
                                  // width: 50,
                                  onPressed: () {
                                    getCategory('training');
                                  },
                                  icon: Image.asset(categories[3]['imagePath']),
                                  iconSize: 38,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                categories[3]['name'],
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                        ])),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: LazyLoadScrollView(
                        isLoading: isLoading,
                        onEndOfPage: () => _loadMore(),
                        child: ListView.builder(
                          physics: const ScrollPhysics(),
                          itemCount: viewList.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final article = viewList[index];
                            return GestureDetector(
                              onTap:
                                  () async {
                                var url = Uri.parse(article.url);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                              child: Container(
                                height: 220,
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: shadowList,
                                            ),
                                            margin:
                                            const EdgeInsets.only(top: 20, bottom: 25),
                                          ),
                                          Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.all(0),
                                                child: ClipRRect(
                                                    borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(20),
                                                        bottomLeft: Radius.circular(20)),
                                                    child: Image.network(
                                                      article.urlImage,
                                                      alignment: Alignment.bottomCenter,
                                                      height: 175,
                                                      width: 185,
                                                      fit: BoxFit.fill,
                                                    )),
                                              )),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: double.infinity,
                                        margin: const EdgeInsets.only(top: 10, bottom: 15),
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10)),
                                          boxShadow: shadowList,
                                        ),
                                        child: Center(
                                          child: Text(
                                            article.title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 21.0,
                                                color: Colors.grey[700],
                                                letterSpacing: 0.5
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
                  ),
                ),
              ),
            ])));
  }

}
