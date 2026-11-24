import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/resume.dart';
import 'screens/match.dart';
import 'screens/cover.dart';
import 'screens/interview.dart';
import 'screens/tracker.dart';
import 'screens/settings.dart';
class CareerApp extends StatelessWidget{const CareerApp({super.key});@override Widget build(BuildContext c)=>MaterialApp(title:'CareerAI',debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff7663e8)),scaffoldBackgroundColor:const Color(0xfff5f4fa),cardTheme:const CardThemeData(elevation:0,color:Colors.white),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(14)))),),home:const Home(),routes:{'/resume':(_)=>const ResumePage(),'/match':(_)=>const MatchPage(),'/cover':(_)=>const CoverPage(),'/interview':(_)=>const InterviewPage(),'/tracker':(_)=>const TrackerPage(),'/settings':(_)=>const SettingsPage()});}
