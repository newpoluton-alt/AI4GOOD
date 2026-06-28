class ApiConfig {
  const ApiConfig._();

  static const productionBaseUrl = 'https://d2x9le8skhxjh4.cloudfront.net';
  static const albBaseUrl =
      'http://ai-dat-LoadB-8liHDRYQDOe8-1492154657.us-west-2.elb.amazonaws.com';
  static const localBaseUrl = 'http://localhost:8000';

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: productionBaseUrl,
  );
}
