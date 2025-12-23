// import 'package:flutter/material.dart';
// import '../screens/login.dart';

// class AuthPage extends StatelessWidget {
//   const AuthPage({super.key});

//   Future<Widget> _getHomeScreen(User user) async {
//     if (!user.emailVerified) {
//       return const LoginPage(); 
//     }
//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       if (userDoc.exists) {
//         String role = userDoc.get('role');
//         if (role == 'admin') {
//           return const AdminHomePage();
//         } else if (role == 'driver') {
//           return const DriverHomePage();
//         } else {
//           return const LoginPage();
//         }
//       } else {
//         return const LoginPage(); 
//       }
//     } catch (e) {
//       return const LoginPage();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasData) {
//             final user = snapshot.data!;
//             return FutureBuilder<Widget>(
//               future: _getHomeScreen(user),
//               builder: (context, futureSnapshot) {
//                 if (futureSnapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 return futureSnapshot.data!;
//               },
//             );
//           } else {
//             return const LoginPage();
//           }
//         },
//       ),
//     );
//   }
// }