/// Central location for all API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth endpoints
  static const String loginEndpoint = '/auth/login/';
  static const String logoutEndpoint = '/auth/logout/';
  static const String signupEndpoint = '/auth/signup';
  static const String signinEndpoint = '/auth/signin';
  static const String signoutEndpoint = '/auth/signout';
  static const String refreshTokenEndpoint = '/auth/refresh/';
  static const String meEndpoint = '/auth/me';
  static const String tokenRefreshEndpoint = '/auth/token/refresh/';

  // Gallery endpoints
  static const String galleryEndpoint = '/gallery';
  static const String uploadPhotoEndpoint = '/gallery/upload';

  // Agenda endpoints
  static const String agendaEndpoint = '/agenda';

  // Potluck endpoints
  static const String potluckEndpoint = '/potluck';

  // Sweets endpoints
  static const String sweetsEndpoint = '/sweets';

  // Votes endpoints
  static const String votesEndpoint = '/votes';

  // Projects endpoints
  static const String projectsEndpoint = '/projects/';
  static const String projectDetailEndpoint = '/projects/{id}/';
  static const String projectMembersEndpoint = '/projects/{id}/members/';
  static const String createAdminEndpoint = '/projects/{id}/create-admin/';
  static const String assignAdminEndpoint = '/projects/{id}/assign-admin/';

  // Employees endpoints
  static const String employeesEndpoint = '/employees/';
}
