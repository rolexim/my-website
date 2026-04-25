// CloudFront Function: viewer-request URI rewriter.
//
// Pelican generates pretty URLs like /resume/ that map to S3 keys like
// resume/index.html. CloudFront sends the URI to S3 unchanged, so we rewrite
// here:
//
//   /            -> /index.html
//   /resume/     -> /resume/index.html
//   /resume      -> /resume/index.html
//   /style.css   -> /style.css   (unchanged — has an extension)
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (uri.endsWith('/')) {
        request.uri = uri + 'index.html';
    } else if (!uri.includes('.')) {
        request.uri = uri + '/index.html';
    }

    return request;
}
