class ApiList {
  static const domainName = 'chennaihms.kauverykonnect.com';
  // static const domainName = 'unfydcrm.kauveryhospital.com';

  static const String refreshTokenApi =
      'https://${domainName}/etiicoshms/token';
  static const String loginApi =
      'https://${domainName}/etiicoshms/api/Values/Login';
  // static const String getLocationsApi =
  //     'https://${domainName}/etiicoshms/api/Values/GetLocationInfo';
  static const String getPatientDetailsApi =
      'https://${domainName}/etiicoshms/api/Values/GetPatientInfo';
  static final String sendPatientForm =
      'https://cccm.kauverykonnect.com/api/v1/store-pdqform-entires';
}
