enum JobTitle {
  seniorSoftwareEngineer('Senior Software Engineer'),
  softwareEngineer('Software Engineer'),
  seniorAnalyst('Senior Analyst'),
  analyst('Analyst'),
  teamLead('Team Lead'),
  manager('Manager'),
  seniorManager('Sr. Manager'),
  esp('ESP'),
  developer('Developer'),
  qa('QA');

  final String displayName;

  const JobTitle(this.displayName);

  static JobTitle? fromString(String? value) {
    if (value == null) return null;
    try {
      return JobTitle.values.firstWhere(
        (e) => e.displayName.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static String? toDisplayName(JobTitle? jobTitle) {
    return jobTitle?.displayName;
  }
}
