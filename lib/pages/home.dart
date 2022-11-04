import 'package:flutter/material.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:flutter_app_test1/configuration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getWebsiteData();
  }

  Future getWebsiteData() async {
    final url = Uri.parse('https://www.thesprucepets.com/dogs-health-4162140');
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

    print('Count: ${titles.length}');
    for (final title in titles) {
      debugPrint(title);
    }

    setState(() {
      articles = List.generate(
        titles.length,
            (index) => Article(
          title: titles[index],
          url: urls[index],
          urlImage: urlImages[index],
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 8,
            shadowColor: Colors.cyanAccent[70],
            title: const Text(
              "FETCH",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            leadingWidth: 0,
            backgroundColor: Colors.white70,
            actions: [
              // IconButton(
              //   enableFeedback: false,
              //   onPressed: () {
              //     AppNav_key.currentState?.pushNamed('/Settings');
              //     setState(() {});
              //   },
              //   icon: const Icon(
              //     Icons.account_circle,
              //     color: Colors.cyan,
              //     size: 35,
              //   ),
              // ),
            ]),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
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
                  suffixIcon: Icon(Icons.tune_sharp, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 140,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: <Widget>[
                    const SizedBox(width: 5),
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
                              UserNav_key.currentState
                                  ?.pushNamed('/food_articles');
                              setState(() {});
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
                              UserNav_key.currentState
                                  ?.pushNamed('/health_articles');
                              setState(() {});
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
                              UserNav_key.currentState
                                  ?.pushNamed('/breeds_articles');
                              setState(() {});
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
                              UserNav_key.currentState
                                  ?.pushNamed('/training_articles');
                              setState(() {});
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
                      ],
                    ),
                  ])),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Featured Articles',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            Container(
              child: ListView.builder(
                physics: const ScrollPhysics(),
                itemCount: articles.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return GestureDetector(
                    onTap: () async {
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Text(
                                        article.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19.0,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ]),
        ));
  }
}
