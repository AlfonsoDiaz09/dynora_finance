import 'package:dynora_finance/ui/bloc/navigation/navigation_bloc.dart';
import 'package:dynora_finance/ui/router/router.dart';
import 'package:dynora_finance/ui/widgets/app_bar/appbar_help.dart';
import 'package:dynora_finance/ui/widgets/app_bar/appbar_notifications.dart';
import 'package:dynora_finance/ui/widgets/app_bar/appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final excludedRoutesAppbar = [
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.register,
];

final includedRoutesAppbar = [];

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NavigationBloc, NavigationState, String?>(
      selector: (state) {
        if (excludedRoutesAppbar.contains(state.currentRoute)) {
          return null;
        }
        return state.currentRoute;
      },
      builder: (context, state) {
        if (state == null) {
          return SizedBox.shrink();
        }
        return AppBar(
          toolbarHeight: height ?? 60.h,
          backgroundColor: Color(0xFF1B0234),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppbarProfile(),
              Row(
                children: [
                  AppbarNotifications(),
                  SizedBox(width: 12.w),
                  AppbarHelp(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 60.h);
}
