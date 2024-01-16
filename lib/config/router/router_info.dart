class RouterInfo {
  String routeName;
  String path;

  RouterInfo({required this.routeName, required this.path});

  static RouterInfo authRoute = RouterInfo(routeName: 'auth', path: '/auth');
  static RouterInfo newPasswordRoute =
      RouterInfo(routeName: 'newPassword', path: '/new-password');
  static RouterInfo dashboardRoute =
      RouterInfo(path: "/dashboard", routeName: "DashboardRout");
  static RouterInfo assistantsRoute =
      RouterInfo(path: "/assistants", routeName: "AssistantsRout");
  static RouterInfo studentsRoute =
      RouterInfo(path: "/students", routeName: "StudentsRout");
  static RouterInfo complaintsRoute =
      RouterInfo(path: "/complaints", routeName: "ComplaintsRout");
  static RouterInfo settingsRoute =
      RouterInfo(path: "/settings", routeName: "SettingsRout");
  static RouterInfo keyLogsRoute =
      RouterInfo(path: "/key-logs", routeName: "KeyLogsRout");
  static RouterInfo messagesRoute =
      RouterInfo(path: "/messages", routeName: "MessagesRout");
  static RouterInfo newMessageRoute =
      RouterInfo(path: "/messages/new", routeName: "NewMessageRout");

  static RouterInfo newAssistantRoute =
      RouterInfo(path: "/assistants/new", routeName: "NewAssistantRout");
  static RouterInfo editAssistantRoute =
      RouterInfo(path: "/assistants/edit", routeName: "EditAssistantRout");
  static RouterInfo attendanceRoute =
      RouterInfo(path: "/assist/attendance", routeName: "AttendanceRoute");
  static RouterInfo newStudentRoute =
      RouterInfo(path: "/students/new", routeName: "NewStudentRout");
  static RouterInfo editStudentRoute =
      RouterInfo(path: "/students/edit", routeName: "EditStudentRout");

  // assistant routes
  static RouterInfo homeRoute =
      RouterInfo(routeName: 'HomeRoute', path: '/home');

  static RouterInfo allocationRoute =
      RouterInfo(routeName: 'AllocationRoute', path: '/allocation');

  //new complaint route
  static RouterInfo newComplaintRoute =
      RouterInfo(routeName: 'NewComplaintRoute', path: '/new-complaint');

  static RouterInfo viewSelectedStudentsRoute = RouterInfo(
      routeName: 'ViewSelectedStudentsRoute', path: '/view-selected-students'
  );
}
