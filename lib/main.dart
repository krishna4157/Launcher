import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:smart_power_launcher/SettingsMenu.dart';
import 'package:smart_power_launcher/Charging.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:focus_detector/focus_detector.dart';
import 'alphabetListView.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:launcher_assist/launcher_assist.dart';

var isNotPresent = false;
var isVisible = false;
var batteryPercentage;
var switchState = 'on';
// List<CellData> matrixValues =
//     List<CellData>.generate(20, (index) => CellData(0.0, index));
StreamSubscription _volumeButtonSubscription;
var onChangeIcon = false;
var i = 0;
List strList = [];

class CellData {
  double value;
  final int index;
  TextEditingController controller;

  CellData(this.value, this.index);
}

void main() {
  // GestureBinding.instance.resamplingEnabled = true;
  // final VoidCallback callback =() =>{};

  runApp(Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(home: HomeLauncherPage(), // becomes the route named '/'
          routes: <String, WidgetBuilder>{
            '/appsDrawer': (BuildContext context) => AppsDrawer(),
            '/charging': (BuildContext context) => Charging(),
            '/settings' : (BuildContext context) => SettingsMenu(),
          })));
}

_launchCaller(val) async {
  var url = "tel:$val";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_textMe() async {
  // Android
  // const uri = 'sms:+39 348 060 888?body=hello%20there';
  const uri = 'sms:';

  if (await canLaunch(uri)) {
    await launch(uri);
  } else {
    // iOS
    const uri = 'sms:';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}

class HomeLauncherPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StartPage();
  }
}



class StartPage extends StatefulWidget {
  StartPage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int Z = 0;
  String z = 's';
  var hideCharging = false;

  var isCharging = false;
  Animation<double> animation;
  AnimationController controller;
  Animation<double> animation2;
  int counter = 0;
  var animcolor = Colors.black;
  String formattedDate = '';
  int timeColor = Colors.white.value;
  int accentColor = Colors.white.value;

  var timeStyle = 'Horizontal';

  int timeSize = 58;
  String isAmPm = '';
  var wallpaper;
  var hideWallpaper= true;
  var buttonColor = Colors.transparent;

  @override
  void didUpdateWidget(StartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _submit({int counter}) {
    // setStateIfMounted(() {
    //   animcolor = Colors.black;
    // });

    _navigateToNewPage(counter);
  }

  void _navigateToNewPage(counter) {

    // Navigator.push(context,
    //  PageTransition(
    //     type: PageTransitionType.fade,
    //     duration: Duration(seconds: 1),
    //   child: SecondPage())
    // );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
    );


  }










  @override
  void initState() {
    super.initState();
    setState(() {
      onChangeIcon = false;
    });

  }

  getWallPaperStat () async {
    final prefs = await SharedPreferences.getInstance();
    var s = prefs.getInt('WallPaperStat');
    int t = prefs.getInt('timeColor');
    int ts = prefs.getInt('timeSize');
    int ac = prefs.getInt('accentColor');
    if(ac != null){
      accentColor  = ac;
    }
    var tst = prefs.getString('timeStyle');

    int wallAccentColor = prefs.getInt('wallAccentColor');
    if(wallAccentColor != null){
      setState(() {
        animcolor = Color(wallAccentColor);
      });
    }
    if(tst != null){
      timeStyle = tst;
    }
    if(t!= null) {
      timeColor = t;
    }
    if(ts!= null) {
      timeSize = ts;
    }
    if(s != null) {
      if( s == 1 ){
        hideWallpaper = true;
      } else {
        hideWallpaper = false;
      }
      setState(() {
        hideWallpaper = hideWallpaper;
      });
      if(hideWallpaper == false) {
        handleStoragePermissions().then((permissionGranted) {
          if (permissionGranted) {
            LauncherAssist.getWallpaper().then((imageData) {
              if (imageData != wallpaper) {
                setState(() {
                  wallpaper = imageData;
                });
              }
            });
          } else {
            print("inside of the else part ");
          }
        });
      }
    }
  }

  Future<bool> handleStoragePermissions() async {
    PermissionStatus storagePermissionStatus = await _getPermissionStatus();

    if (storagePermissionStatus == PermissionStatus.granted ) {
      //which means that we have been given the permission to access device storage,
      return true;
    } else {
      // _handleInvalidPermissions(storagePermissionStatus);
      return false;
    }
  }

  Future _getPermissionStatus() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {});
      return PermissionStatus.granted;
    }
  }

  changeColor() async {
    Future.delayed(Duration(seconds: 1), () async {
      var colorsList = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.yellow,
        Colors.teal,
        Color.fromRGBO(230, 230, 250, 1.0),
        Color.fromRGBO(57, 255, 20,1.0),
        Color.fromRGBO(128, 0, 32,1.0),
      ];
      var _randomColor = new Random();

      var element = colorsList[_randomColor.nextInt(colorsList.length)];
      if(animcolor.toString() != element.toString()) {
        final prefs = await SharedPreferences.getInstance();
        int hex = element.value;
        prefs.setInt('wallAccentColor',hex);
        setStateIfMounted(() {
          animcolor = element;
        });
      } else {
        changeColor();
      }

    });
  }

  changeColorOnTap() async {
    Future.delayed(Duration(seconds: 1), () async {
      var colorsList = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.yellow,
        Colors.teal,
        Color.fromRGBO(230, 230, 250, 1.0),
        Color.fromRGBO(57, 255, 20,1.0),
        Color.fromRGBO(128, 0, 32,1.0),
      ];
      var _randomColor = new Random();

      var element = colorsList[_randomColor.nextInt(colorsList.length)];
      if(animcolor.toString() != element.toString()) {
        final prefs = await SharedPreferences.getInstance();
        int hex = element.value;
        prefs.setInt('wallAccentColor',hex);
        prefs.setInt('timeColor',hex);
        setStateIfMounted(() {
          animcolor = element;
          timeColor = element.value;
        });
      } else {
        changeColor();
      }

    });
  }


  resetColorAndChange() {
    setStateIfMounted(() {
      animcolor = Colors.black;
    });

    changeColor();

  }


  resetColorAndChangeOnTap() {
    setStateIfMounted(() {
      animcolor = Colors.black;
    });

    changeColorOnTap();

  }



  setToDefault() async {

    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString('prevChargeState', 'disCharge');
  }

  Future<List> getUserInfo(menus) async {
    List<dynamic> userMap;

    final String userStr = menus;
    if (userStr != null) {
      userMap = jsonDecode(userStr) as List<dynamic>;
    }
    if (userMap != null) {
      final List<dynamic> usersList = userMap;

      return usersList;
    }
    return null;
  }


  @override
  void dispose() {
    controller.dispose();
    _volumeButtonSubscription?.cancel();
    super.dispose();

  }

  remainSamePage() async {
    return false;
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  navigateToCharging() async {

      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              duration: Duration(seconds: 2),
              child: Charging()));
  }

  checkColorPresent() async {
    final prefs = await SharedPreferences.getInstance();
    int clr = prefs.getInt('wallAccentColor');
    if(clr!= null){
      setStateIfMounted(() {
        animcolor = Color(clr);
      });
    } else {
      resetColorAndChange();
    }
  }





  @override
  Widget build(BuildContext context) {

    // MediaQueryData queryData;
    // queryData = MediaQuery.of(context);
    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          return remainSamePage();
        },
        child:  FocusDetector(
            onFocusLost: () {
              print(
                'Focus Lost.'
                '\nTriggered when either [onVisibilityLost] or [onForegroundLost] '
                'is called.'
                '\nEquivalent to onPause() on Android or viewDidDisappear() on '
                'iOS.',
              );
              if(timer!= null) {
                timer.cancel();
              }
            },
            onFocusGained: () {
              getWallPaperStat();
              checkColorPresent();
            },
            onVisibilityLost: () {
              print(
                'Visibility Lost.'
                '\nIt means the widget is no longer visible within your app.',
              );
            },
            onForegroundLost: () {
              print(
                'Foreground Lost.'
                '\nIt means, for example, that the user sent your app to the '
                'background by opening another app or turned off the device\'s '
                'screen while your widget was visible.',
              );
            },
            child: TouchableOpacity(
                activeOpacity: 1.0,

                onTap: () {
                },

                onDoubleTap: () {
                  resetColorAndChangeOnTap();
                },
                onLongPress  : () {

                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            duration: Duration(milliseconds: 300),
                            child: SettingsMenu()));
                },
                child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    backgroundColor: Colors.black,
                    body: Center(
                        child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                    Colors.transparent,
                                    BlendMode.darken,
                                  ),
                            child: Stack(
                              children: [

                                Container (
                                  child: AnimatedContainer(
                                      curve: Curves.decelerate,
                                      decoration: BoxDecoration(
                                          image: !hideWallpaper && wallpaper != null ? DecorationImage(
                                            image:
                                            MemoryImage(wallpaper),
                                            // : Image.memory(Uint8List(0)),
                                            fit: BoxFit.cover,
                                          ) : null,
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              stops: [
                                                0.74,
                                                0.75,
                                                0.79,
                                                0.95,
                                                1
                                              ],
                                              colors: [
                                                Colors.black,
                                                Colors.black,
                                                Colors.black,
                                                animcolor,
                                                animcolor
                                              ])),
                                      duration: Duration(milliseconds: 899),
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      40, 80, 0, 0),
                                                  child: RenderWidget(timeColor: timeColor,timeSize: timeSize,timeStyle: timeStyle,),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.all(5),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          ConstrainedBox(
                                                            constraints:
                                                            BoxConstraints
                                                                .tightFor(
                                                                width: 60,
                                                                height: 60),
                                                            child: ElevatedButton(
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                                  children: <Widget>[
                                                                    Row(
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                        children: <
                                                                            Widget>[
                                                                          Icon(
                                                                            Icons
                                                                                .phone,
                                                                            size: 25,
                                                                            color: animcolor
                                                                                ,
                                                                          ),
                                                                        ]),
                                                                  ]),
                                                              onPressed: () {
                                                                _launchCaller("");
                                                              },
                                                              onLongPress: () {
                                                                getDailFavNumberIfStored();
                                                                // _launchCaller('');
                                                              },
                                                              style: ButtonStyle(
                                                                shape: MaterialStateProperty.all<
                                                                    RoundedRectangleBorder>(
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                          30.0),
                                                                    )),
                                                                backgroundColor : MaterialStateProperty.resolveWith((states) {
                                                                              if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed) || states.contains(MaterialState.focused) || states.contains(MaterialState.selected)) {
                                                                              return Colors.blueAccent;
                                                                              } else {
                                                                                return Colors.transparent;
                                                                              }}),
                                                              ),
                                                            ),
                                                          ),

                                                          //menu button
                                                          Column(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              children: [
                                                                ConstrainedBox(
                                                                  constraints: BoxConstraints.tightFor(
                                                                      width:
                                                                      onChangeIcon
                                                                          ? 80
                                                                          : 50,
                                                                      height:
                                                                      onChangeIcon
                                                                          ? 80
                                                                          : 50),
                                                                  child:
                                                                  TouchableOpacity(
                                                                    activeOpacity: 1.0,
                                                                    child: Container(
                                                                      // color: buttonColor,
                                                                        decoration: BoxDecoration(
                                                                          color: buttonColor,
                                                                          borderRadius: BorderRadius.circular(35), // Adjust the radius as needed
                                                                        ),
                                                                    child : onChangeIcon ==
                                                                        true
                                                                        ? Image.asset(
                                                                      'assets/images/ga1.png',
                                                                      height:
                                                                      80,
                                                                      width: 80,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    )
                                                                        : AppDrawerIcon()),
                                                                    onLongPress: () =>
                                                                    {
                                                                      setState(() {
                                                                        onChangeIcon =
                                                                        true;
                                                                      }),
                                                                      Future.delayed(
                                                                          Duration(
                                                                              seconds:
                                                                              1),
                                                                              () {
                                                                            DeviceApps
                                                                                .openApp(
                                                                                "com.google.android.apps.googleassistant");
                                                                            setState(() {
                                                                              onChangeIcon =
                                                                              false;
                                                                            });
                                                                          })
                                                                    },
                                                                    onTap: () => {
                                                                      setStateIfMounted(() {
                                                                    buttonColor = Color(accentColor);
                                                                    }),

                                                                      Future.delayed(Duration(milliseconds: 15),(){
                                                                        _submit(
                                                                            counter:
                                                                            _counter);
                                                                        setStateIfMounted((){
                                                                          buttonColor = Colors.transparent;
                                                                        });
                                                                    })

                                                                    }
                                                                  ),
                                                                ),
                                                              ]),
                                                          //
                                                          ConstrainedBox(
                                                            constraints:
                                                            BoxConstraints
                                                                .tightFor(
                                                                width: 60,
                                                                height: 60),
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                _textMe();
                                                              },
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: <Widget>[
                                                                  Icon(
                                                                    Icons.message,
                                                                    color: animcolor,
                                                                  )
                                                                ],
                                                              ),
                                                              style: ButtonStyle(
                                                                shape: MaterialStateProperty.all<
                                                                    RoundedRectangleBorder>(
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                          30.0),
                                                                    )),
                                                                backgroundColor:
                                                                MaterialStateProperty
                                                                    .resolveWith<
                                                                    Color>(
                                                                      (Set<MaterialState>
                                                                  states) {
                                                                    if (states.contains(
                                                                        MaterialState
                                                                            .pressed))
                                                                      return Colors
                                                                          .orange;
                                                                    return Colors.black
                                                                        ; // Use the component's default.
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ]),
                                        ),
                                      )),
                                ),
                                if (z == 'ChargingStatus.Charging' && !hideCharging)
                                Positioned(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      child: Charging(),
                                    )
                                ),

                              ],
                            )
                            ))))));
  }



  void getDailFavNumberIfStored() async {
    final prefs = await SharedPreferences.getInstance();
    var s = prefs.getString('favPhoneNumber');
    if(s!=null){
      _launchCaller(s);
    } else {
      _launchCaller('');

    }


  }
}

class RenderWidget extends StatefulWidget {
  final int timeColor;
  final int timeSize;
  final String timeStyle;

  RenderWidget({this.timeColor, this.timeSize, this.timeStyle});


  @override
  State<RenderWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<RenderWidget> with SingleTickerProviderStateMixin {

  // Timer timer;
  int counter = 0;
  String formattedDate = DateFormat('h:mm').format(DateTime.now());
  int timeColor = Colors.white.value;
  int accentColor = Colors.white.value;
  String isAmPm = DateFormat('aa').format(DateTime.now());
  Timer time;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void didUpdateWidget(RenderWidget oldWidget) {
    if(oldWidget.timeColor != widget.timeColor) {
      _controller.reverse().then((value) =>
      {
        _controller.forward(),
        super.didUpdateWidget(oldWidget)
      }); // Start the animation
    } else {
      super.didUpdateWidget(oldWidget);

    }


  }

  @override
  void dispose(){
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {

    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Total duration for fade-in and fade-out
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Use an ease-in-out curve for smoother effect
    );

    // _controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     _controller.reverse(); // Reverse the animation when completed
    //   } else if (status == AnimationStatus.dismissed) {
    //     _controller.forward(); // Start the animation again
    //   }
    // });

    _controller.forward(); // Start the animation



  }

  setTimeOnFocus () {
    time = Timer.periodic(Duration(seconds: 3), (timer) {
      setTime();
    });
  }

  setTime() {
    DateTime now = DateTime.now();
    isAmPm = DateFormat('aa').format(now);
    var formattedMin = DateFormat('mm').format(now);
    var existingMin = DateFormat('h:mm').parse(formattedDate);
    if(formattedMin != DateFormat('mm').format(existingMin)) {
      // _controller.reverse().then((value) => {
        Future.delayed(Duration(milliseconds: 500),(){
          // _controller.forward();
          setStateIfMounted(() {
            formattedDate = DateFormat('h:mm').format(now);
            isAmPm = isAmPm;
          });
        // }),

      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FocusDetector(
      onFocusGained: () {
        setTimeOnFocus();
      },
        onFocusLost: () {
        if(timer != null) {
          timer.cancel();
        }
        if(time != null) {
          time.cancel();
        }

        },
      child : AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
    return Opacity(
    opacity: _animation.value,
    child :
      widget.timeStyle == "Horizontal" ?
      Column(
        children : [
          Row(
    crossAxisAlignment:
    CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
  Text(
    formattedDate,
  style: TextStyle(
  color: Color(widget.timeColor),
  fontSize: double.parse(widget.timeSize.toString()) > 80 ? 80 : double.parse(widget.timeSize.toString()),
  fontFamily: 'Montserrat'),
  ),
  Text(
  ' $isAmPm',
  style: TextStyle(
      color: Color(widget.timeColor),
  fontSize: double.parse(widget.timeSize.toString()) - 28 > 0 ? double.parse(widget.timeSize.toString()) - 28 : 0,
  fontFamily: 'Montserrat'),
  )
  ],
  ),
        ]) :
      Column(
          children : [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${ DateFormat('hh').format(DateFormat('h:mm').parse(formattedDate))}',
                  style: TextStyle(
                      color: Color(widget.timeColor),
                      fontSize: double.parse(widget.timeSize.toString()) > 80 ? 80 : double.parse(widget.timeSize.toString()),
                      fontFamily: 'Montserrat'),
                )
              ],
            ),
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${ DateFormat('mm').format(DateFormat('h:mm').parse(formattedDate))}',
                  style: TextStyle(
                      color: Color(widget.timeColor),
                      fontSize: double.parse(widget.timeSize.toString()) > 80 ? 80 : double.parse(widget.timeSize.toString()),
                      fontFamily: 'Montserrat'),
                ),
              ],
            ),
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '$isAmPm',
                  style: TextStyle(
                      color: Color(widget.timeColor),
                      fontSize: double.parse(widget.timeSize.toString()) - 25 > 0 ? double.parse(widget.timeSize.toString()) - 25 : 0,
                      fontFamily: 'Montserrat'),
                ),
              ],
            ),
          ])

    );}));
  }}

class AppDrawerIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.transparent,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.transparent,
                ),
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,

                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,

                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,

                ),
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,

                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,

                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,

                ),
              ]),
        ]);
  }
}


///
// 2.10.5 flutter
///