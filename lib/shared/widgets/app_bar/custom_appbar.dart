import 'package:dynora_finance/app/router/router.dart';
import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/widgets/app_bar/appbar_help.dart';
import 'package:dynora_finance/shared/widgets/app_bar/appbar_notifications.dart';
import 'package:dynora_finance/shared/widgets/app_bar/appbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

final excludedRoutesAppbar = [
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.register,
];

final hasProfileAppbar = [AppRoutes.home];

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    this.height,
    this.indexCurrent = 0,
    this.canBack = false,
    this.title,
  });

  final double? height;
  final int indexCurrent;
  final bool canBack;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final showAppBar = !excludedRoutesAppbar.contains(location);

    return !showAppBar
        ? SizedBox.shrink()
        : AppBar(
            toolbarHeight: height ?? 60.h,
            backgroundColor: AppColors.background,
            leading: canBack && context.canPop()
                ? InkWell(
                    borderRadius: BorderRadius.circular(100.r),
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  )
                : null,
            title: hasProfileAppbar.contains(location)
                ? _appbarProfile()
                : _appbarTitle(),
          );
  }

  Widget _appbarProfile() {
    return Row(
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
    );
  }

  Widget _appbarTitle() {
    return Text(
      title ?? '',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 60.h);
}
