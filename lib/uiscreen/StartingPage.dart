

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'SignIn.dart';

class Startingpage extends StatefulWidget {
  const Startingpage({super.key});

  @override
  State<Startingpage> createState() => _StartingpageState();
}

class _StartingpageState extends State<Startingpage> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String,String>> data=[
    {
      "image": "assets/images/image1.jpg",
      "title": "Find Barbers and Salons Easily in Your Hands"
    },
    {
      "image": "assets/images/images3.jpg",
      "title": "Book Your Favorite Barber Quickly"
    },
    {
      "image": "assets/images/image2.jpg",
      "title": "Come be handsome with us right now!"
    },
  ];
  void _nextPage(){
    if(currentPage < data.length - 1){
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }else{
      Navigator.push(context, MaterialPageRoute(builder: (_) => Signin()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Container(
        child: Column(
          children: [
            SizedBox(
              height: 600,
              child: PageView.builder(
                  controller: _controller,
                  itemCount: data.length,
                  onPageChanged:  (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index){
                    return Column(
                      children: [
                        SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: Image.asset(
                            data[index]['image']!,
                            fit: BoxFit.cover,
                          ),),
                        SizedBox(height: 20),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            data[index]['title']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),),
                      ],
                    );
                  }
              ),),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(data.length,
                    (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 25 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == index ? Colors.orange : Colors.grey,
                    borderRadius: BorderRadius.circular(10),),
                ),
              ),
            ),

            SizedBox(height: 50),
            Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: 300,
                child: ElevatedButton(onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                  child: Text(currentPage == data.length - 1 ? "Get Started" : "Next" ,style: TextStyle(fontSize: 18,color: Colors.white)),),),
              )
          ],
        ),
      )
    );
  }
}
