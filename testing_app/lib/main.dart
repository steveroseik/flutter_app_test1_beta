import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: HomeWidget(),
      routes: {
        '/home': (context) => HomeWidget(),
        '/details': (context) => GraphQLSubscriptionDemo(),
      },
    );
  }
}



class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final HttpLink httpLink =
  HttpLink("http://192.168.1.20:5000/graphql");

  late ValueNotifier<GraphQLClient> client;
  static String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJmUzc4VWh1UnhDWmdKNTNCMUdlbVZpaU5rSm0xIiwiZGF0ZSI6IjIwMjMtMDYtMTJUMTE6MTQ6MzkuNjgzWiIsImlhdCI6MTY4NjU2ODQ3OSwiZXhwIjoxNjg2NjA4MDc5fQ.BHLAtet-c7NbuVBM9D_E4j11YqfuskH0_Ndp3Z90F5o";
  final _authLink = AuthLink(
    getToken: () async => 'Bearer $token',
  );
  static String uid = "fS78UhuRxCZgJ53B1GemViiNkJm1";
  final String query = """
                    mutation {
                      addPet
                    }
                  """;
  dynamic response = 'none';

  late IOWebSocketChannel channel;


  @override
  void initState() {
    initMe();
    channel = createWebSocketChannel();
    print('created');
    subscribeToPetAdded(channel);
    channel.stream.listen((message) {
      print('aho ahoo');
      print(message);

    });
    print('connected');
    super.initState();
  }

  Future<bool> initMe() async{
    // box = await Hive.openBox('myBox');
    await initHiveForFlutter();

    client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
          link: _authLink.concat(httpLink), cache: GraphQLCache(store: HiveStore()),
          defaultPolicies: DefaultPolicies(
            mutate: Policies(
                fetch: FetchPolicy.noCache
            ),
            query: Policies(
                fetch: FetchPolicy.noCache
            ),
            watchMutation: Policies(
                fetch: FetchPolicy.noCache
            ),
            watchQuery: Policies(
                fetch: FetchPolicy.noCache
            ),

          )
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(onPressed: () async{
              response = await sendGraphQLQuery(query);
              setState(() {});
            }, child: Text('Send')),
            Text(response),
            Spacer(),
            ElevatedButton(onPressed: () async{
              Navigator.of(context).pushNamed('/details');
              setState(() {});
            }, child: Text('Navigate')),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> sendGraphQLQuery(String q) async {
    final url = "http://192.168.1.20:5000/graphql";

    try{
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final body = {
        'query': q,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      }
      throw Exception('Failed to send GraphQL query. Status code: ${response.statusCode}');

    }catch (e){
      print("errr: ${e.toString()}");
      return null;
    }
  }

  createWebSocketChannel() {
    try{
      final webSocketUrl = 'ws://192.168.1.20:5000/subscriptions';
      final channel = IOWebSocketChannel.connect(webSocketUrl);
      return channel;
    }catch (e){
      print('THE ERROR: $e');
      return null;
    }
  }
  void subscribeToPetAdded(IOWebSocketChannel channel) {
    final subscriptionQuery = 'subscription { petAdded }';

    channel.sink.add(subscriptionQuery);
  }
}

class GraphQLSubscriptionDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink('http://192.168.1.20:5000/graphql');

    final WebSocketLink websocketLink = WebSocketLink(
      'ws://192.168.1.20:5000/subscriptions',
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(store: HiveStore()),
        link: httpLink.concat(websocketLink),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text("Graphql Subscription Demo"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                IncrementButton(),

                SizedBox(height: 3, child: Container(color: Colors.green)),
                Counter()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IncrementButton extends StatelessWidget {
  static String incr = '''mutation { 
      addPet
}''';

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(incr),
      ),
      builder: (runMutation,result) {
        return Center(
          child: FilledButton.icon(
            onPressed: () {
              runMutation({});
            },
            icon: Icon(Icons.plus_one),
            label: Text(result!.data.toString()),
          ),
        );
      },
    );
  }
}

class Counter extends StatelessWidget {
  static String subscription = '''
  subscription watchAyHaga {
    petAdded
}''';

  @override
  Widget build(BuildContext context) {
    return Subscription(options: SubscriptionOptions(
      document: gql(subscription),
    ),
      builder: (result) {
        if (result.isLoading) {
          return Text("Fetching Online Users");
        } else {
          print(result.exception);
          return Text(result.data.toString());
        }
      }
    );
  }
}



