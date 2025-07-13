import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class GroupCategoryTabsWidget extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final TabController tabController;

  const GroupCategoryTabsWidget({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.dividerLight, width: 1),
        ),
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppTheme.primaryLight,
        unselectedLabelColor: AppTheme.textMediumEmphasisLight,
        indicatorColor: AppTheme.primaryLight,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w400),
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
        tabs: categories.map((category) {
          return Tab(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Text(category, style: TextStyle(fontSize: 14.sp)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
