import 'dart:async';

import 'package:smart_power_launcher/main.dart';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';


int batteryPercentage = 0;

class Charging extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: MyAnimation(),
      backgroundColor: Colors.black,
    ));
  }
}

// class MyAnimation extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MyClipPath();
//   }
// }

// class MyClipPath extends StatelessWidget{
class MyClipPath extends AnimatedWidget {
  final Animation<double> animation;

  final double height;

  MyClipPath(this.animation, this.height, batteryPercentage)
      : super(listenable: animation);
  final Color backgroundColor = Colors.green;
  @override
  Widget build(BuildContext context) {

    return TouchableOpacity(
      activeOpacity: 1.0,
      onTap: () {
        // setInitialValue();
      },
      child:   Stack(children: <Widget>[
      ShaderMask(
      blendMode: BlendMode.srcATop,
        shaderCallback: (rect)=> LinearGradient(
          colors: [(batteryPercentage < 15
              ? Colors.red
              : batteryPercentage < 75
              ? Colors.orange
              : batteryPercentage < 95
              ? Colors.blueAccent
              : Colors.green).withOpacity(0.6), (batteryPercentage < 15
              ? Colors.red
              : batteryPercentage < 75
              ? Colors.orange
              : batteryPercentage < 95
              ? Colors.blueAccent
              : Colors.green).withOpacity(0.6)],
          stops: [0.0, 1.0],
        ).createShader(rect),
        child : ImageShaderBuilder(
            imageProvider: AssetImage('assets/images/bw.gif'),
            child :Column(
          children: [
            // SizedBox(height: 50),
            // Text(
            //   'Charging',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 30.0),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(28.0),
            //   child: FlutterLogo(size: 200.0),
            // ),

         Expanded(
              flex: 1,

              child:
              Stack(

                  children: [
                Positioned(
                  bottom: -135,
                  right: animation.value,
                  child: ClipPath(
                    clipper: BottomWaveClipper(),
                    child: Opacity(
                      opacity: 1,
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        color: batteryPercentage < 15
                            ? Colors.red
                            : batteryPercentage < 75
                                ? Colors.orange
                            : batteryPercentage < 95
                                    ? Colors.blueAccent
                                    : Colors.green,
                        width: 3000,
                        height: 200,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -130,
                  left: animation.value,
                  child: ClipPath(
                    clipper: BottomWaveClipper(),
                    child: Opacity(
                      opacity: 0.5,
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        color: batteryPercentage < 15
                            ? Colors.red
                            : batteryPercentage < 75
                                ? Colors.orange
                                : batteryPercentage == 100
                                    ? Colors.blueAccent
                                    : Colors.green,
                        width: 4000,
                        height: 200,
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            Expanded(
                flex: 0,
                child: AnimatedContainer(
                  decoration: new BoxDecoration(
                    border: new Border.all(
                        width: 5,
                        color: batteryPercentage < 15
                            ? Colors.red
                            : batteryPercentage < 75
                            ? Colors.orange
                            : batteryPercentage < 95
                            ? Colors.blueAccent
                            : Colors
                            .green), //color is transparent so that it does not blend with the actual color specified
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(0.0)),
                    color: batteryPercentage < 15
                        ? Colors.red
                        : batteryPercentage < 75
                            ? Colors.orange
                            : batteryPercentage == 100
                                ? Colors.blueAccent
                                : Colors
                                    .green, // Specifies the background color and the opacity
                  ),
                  // color: batteryPercentage < 15
                  //     ? Colors.red
                  //     : batteryPercentage < 75
                  //         ? Colors.orange
                  //         : batteryPercentage == 100
                  //             ? Colors.blueAccent
                  //             : Colors.green,
                  height: (height - 40) * (batteryPercentage / 100),
                  duration: Duration(seconds: 1),
                )),

          ],
        ))),
        Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$batteryPercentage',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 120,
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: Text('%',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Quicksand-Light')),
                )
              ],
            ),
            Image.asset(
              'assets/images/thunder.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),

            // Padding(
            //     padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
            //     child: Text('tap to dismiss',
            //         style: TextStyle(color: Colors.white, fontSize: 15.0)))
          ],
        )),
        Positioned(
          left :0,
          child:  Transform.rotate(
            angle: 0 * (3.141592653589793 / 180), // Rotate by 45 degrees
            child: Image.asset(
              'assets/images/t2.gif',
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,

              color: Color.fromRGBO(255, 184, 76, 0.8),
            ),
          ),
        )
      ]),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0.0, 40.0);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 40.0);

    for (int i = 0; i < 10; i++) {
      if (i % 2 == 0) {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            0.0,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      } else {
        path.quadraticBezierTo(
            size.width - (size.width / 16) - (i * size.width / 8),
            size.height - 120,
            size.width - ((i + 1) * size.width / 8),
            size.height - 160);
      }
    }

    path.lineTo(0.0, 40.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyAnimation extends StatefulWidget {
  @override
  _MyAnimationState createState() => _MyAnimationState();
}

class _MyAnimationState extends State<MyAnimation>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;

  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    batteryPercentage = 0;
    // getBatteryLevel();
    // batteryPercentage = batteryPercentage;
    _controller =
        AnimationController(duration: Duration(seconds: 6), vsync: this)
          ..repeat();
    animation = Tween<double>(begin: -1260, end: 0).animate(_controller);
    getBatteryLevel().then((value) => setStateIfMounted(() {
            print("HELLO WORLD : "+value.toString());
            batteryPercentage = 0;
            Timer timer= Timer.periodic(new Duration(milliseconds: 25), (timer) {

              if(value > batteryPercentage){
                batteryPercentage = batteryPercentage+1;
              } else {
                timer.cancel();
              }
              // debugPrint(timer.tick.toString());
            });
            }));


  }

  resetChargeValue() async {
    final prefs = await SharedPreferences.getInstance();
    // var showChargeAtFirstTime = prefs.getInt('startCount');
    // prefs.setInt('startCount', 0);
    prefs.setString('prevChargeState', 'charge').then((value) =>
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 500),
                child: HomeLauncherPage())));
    // Navigator.pushReplacement(
    //     context,
    //     PageTransition(
    //         type: PageTransitionType.fade,
    //         duration: Duration(milliseconds: 500),
    //         child: CountingApp()));
    // });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future getBatteryLevel() async {
    var setupResult = (await BatteryInfoPlugin().androidBatteryInfo).batteryLevel;
    batteryPercentage = setupResult;
    return setupResult;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return MyClipPath(animation, height, batteryPercentage);
  }
}
