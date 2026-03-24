import 'package:opennutritracker/core/domain/entity/app_theme_entity.dart';


enum AppThemeDBO {
  light,
  dark,
  system;

  static AppThemeDBO get defaultTheme => AppThemeDBO.system;

  factory AppThemeDBO.fromAppThemeEntity(AppThemeEntity entity) {
    AppThemeDBO dbo;
    switch (entity) {
      case AppThemeEntity.light:
        dbo = AppThemeDBO.light;
        break;
      case AppThemeEntity.dark:
        dbo = AppThemeDBO.dark;
        break;
      case AppThemeEntity.system:
        dbo = AppThemeDBO.system;
        break;
      }
    return dbo;
  }
}
