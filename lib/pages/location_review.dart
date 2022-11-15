import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/FETCH_wdgts.dart';
import 'package:flutter_app_test1/routesGenerator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../configuration.dart';


class LocationReview extends StatefulWidget {
  const LocationReview({Key? key}) : super(key: key);

  @override
  State<LocationReview> createState() => _LocationReviewState();
}
class _LocationReviewState extends State<LocationReview> {
  TextEditingController reviewController = TextEditingController();
  String review = '';  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: init_appBar(rootNav_key), // CHANGE KEY!!!
        body: Column(
            children: [
              Text(
                  "Rating: $rating"
              )     ,
              RatingBar.builder(

                minRating:1,
                itemSize:20,
                itemBuilder:(context, _)=>Icon(Icons.star,color:Colors.amber),
                updateOnDrag:true,
                onRatingUpdate:(rating)=> setState((){
                  this.rating = rating;

                }),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children:[
                    SizedBox(

                      child: TextField(
                        controller: reviewController,
                        onChanged: (value){
                          review = value;
                          setState((){
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Review',
                        ),
                      ),

                    ),
                    Container(
                        child:SizedBox(
                            height: 25,
                            width: 50,
                            child:ElevatedButton(onPressed: (){
                              insert_review(review);

                              explore_key.currentState
                                  ?.pushNamed('/');
                              setState(() {});
                            },
                                child: Icon(
                                    Icons.send_rounded
                                )
                            )
                        )
                    )
                  ])
            ]
        )
    );
  }
  Future insert_review(String review) async {
    if (review != "") {
      try {
        final data = await SupabaseCredentials.supabaseClient.from('locations')
            .insert({
          "review": review
        }
        );
      }
      catch (e) {
        print(e);
      }
    }
  }
}
