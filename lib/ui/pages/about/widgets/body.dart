import 'package:dynora_finance/ui/pages/about/widgets/description.dart';
import 'package:dynora_finance/ui/pages/about/widgets/credits.dart';
import 'package:dynora_finance/ui/pages/about/widgets/functionalities.dart';
import 'package:dynora_finance/ui/pages/about/widgets/legal_information.dart';
import 'package:dynora_finance/ui/pages/about/widgets/footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Description(),
          SizedBox(height: 20.h),
          Functionalities(),
          SizedBox(height: 20.h),
          Credits(),
          SizedBox(height: 20.h),
          LegalInformation(),
          SizedBox(height: 28.h),
          Footer(),
        ],
      ),
    );
  }
}