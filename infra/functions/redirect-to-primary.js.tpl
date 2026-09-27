// CloudFront Function: unconditional 301 redirect to the canonical domain.
// ponytail: path-only redirect (query string dropped) -- this distribution
// only ever serves the retired domain's traffic, which is almost entirely
// bare links; add query passthrough if that ever stops being true.
function handler(event) {
    var request = event.request;
    return {
        statusCode: 301,
        statusDescription: 'Moved Permanently',
        headers: {
            location: { value: 'https://${primary_domain}' + request.uri }
        }
    };
}
