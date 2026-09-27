// CloudFront Function: clean URLs for a flat-file static site (page.html at
// the bucket root, no per-page directories).
// /about        -> serves /about.html (internal rewrite, URL stays clean)
// /about.html   -> 301 redirect to /about (canonicalizes old/typed-in links)
// /index.html   -> 301 redirect to /
// / and any URI with a real extension (.css, .webp, ...) pass through as-is
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (uri === '/index.html') {
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: { location: { value: '/' } }
    };
  }

  if (uri.endsWith('.html')) {
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: { location: { value: uri.slice(0, -5) } }
    };
  }

  // Root or any other extensioned asset (css/js/webp/svg/...): serve as-is.
  if (uri === '/' || uri.includes('.')) {
    return request;
  }

  // Extensionless page request -> map to the matching .html file.
  if (uri.endsWith('/') && uri !== '/') {
    uri = uri.slice(0, -1);
  }
  request.uri = uri + '.html';
  return request;
}
