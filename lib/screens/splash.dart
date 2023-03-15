// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';



// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   void intiState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 5)).then(
//       (value) => {
//         Navigator.push(context,
//             MaterialPageRoute(builder: (BuildContext context) {
//           return const HomeScreen();
//         }))
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SizedBox(
//         width: double.infinity,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Image(
//               image: AssetImage(""),
//               width: 300,
//             ),
//             SizedBox(
//               height: 50,
//             ),
//             SpinKitFadingCube(
//               color: Colors.green,
//               size: 500,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
