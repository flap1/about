// CloudFront Function: URL rewrite for Astro static site
// Handles trailingSlash: 'never' + format: 'directory'
// /path -> /path/index.html
// /path/ -> /path/index.html
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  // If URI has a file extension, serve as-is
  if (uri.includes('.')) {
    return request;
  }

  // Strip trailing slash (except root)
  if (uri.endsWith('/') && uri !== '/') {
    uri = uri.slice(0, -1);
  }

  // Root path
  if (uri === '' || uri === '/') {
    request.uri = '/index.html';
    return request;
  }

  // Append /index.html for directory-style routes
  request.uri = uri + '/index.html';
  return request;
}
