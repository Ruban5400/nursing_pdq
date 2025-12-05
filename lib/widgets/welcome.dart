import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(150, 199, 24, 164),
            Color.fromARGB(255, 199, 24, 164),
          ],
          begin: AlignmentGeometry.topLeft,
          end: AlignmentGeometry.bottomRight,
        ),
        // color: Color.fromARGB(255, 199, 24, 164),
        // image:
        // DecorationImage(
        //   image: AssetImage('assets/images/logo.png'),
        //   fit: BoxFit.cover,
        // ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.png',width: 100,),
          const SizedBox(height: 10),
          const Text(
            "PDQ",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          const Text(
            "Pre-Discharge Questionnaire",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}