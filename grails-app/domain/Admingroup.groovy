class Admingroup {

  static constraints = {
  }
  static mapping = {
    version false
  }
  Integer id
  String name

  String menu
  Integer is_superuser
  Integer is_profile
  Integer is_groupmanage
  Integer is_users
  Integer is_infotext
  Integer is_container
  Integer is_terminal
  Integer is_clients
  Integer is_tracker
  Integer is_zakaz
  Integer is_monitoring
  Integer is_requests
  Integer is_contsearch
  Integer is_reports
  Integer is_guestbook
  Integer is_autopilot
  Integer is_syscompany
  Integer is_payorders
  Integer is_financial
  Integer is_chief
  Integer is_route
  Integer is_alwaysallvariants = 1
  
}