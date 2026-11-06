// Zero-dependency static server for Railway
const http = require('http'), fs = require('fs'), path = require('path');
const root = __dirname, port = process.env.PORT || 3000;
const types = {'.html':'text/html','.js':'text/javascript','.css':'text/css','.json':'application/json',
  '.webmanifest':'application/manifest+json','.png':'image/png','.webp':'image/webp','.svg':'image/svg+xml','.ico':'image/x-icon'};
http.createServer((req, res) => {
  let p = decodeURIComponent((req.url || '/').split('?')[0]);
  if (p === '/') p = '/index.html';
  const fp = path.join(root, p);
  if (!fp.startsWith(root)) { res.writeHead(403); return res.end(); }
  fs.readFile(fp, (e, data) => {
    if (e) { res.writeHead(404); return res.end('Not found'); }
    res.writeHead(200, {'Content-Type': types[path.extname(fp)] || 'application/octet-stream', 'Cache-Control': 'no-cache'});
    res.end(data);
  });
}).listen(port, () => console.log('Quad Squad up on ' + port));
