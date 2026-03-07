/**
 * Application Entry Point
 *
 * This is a minimal example. Replace with your actual application code.
 */

const http = require('http');

const PORT = process.env.PORT || 3000;

// Simple health check server
const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy', timestamp: new Date().toISOString() }));
    return;
  }

  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Long-Running Agent Template</title>
        </head>
        <body>
          <h1>Welcome to the Long-Running Agent Template</h1>
          <p>This is a minimal example application.</p>
          <p>Replace this with your actual application code.</p>
          <h2>Getting Started</h2>
          <ul>
            <li>Review <code>features/feature_list.json</code> for requirements</li>
            <li>Check <code>progress/claude-progress.md</code> for current status</li>
            <li>Read <code>CLAUDE.md</code> for workflow instructions</li>
          </ul>
        </body>
      </html>
    `);
    return;
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not Found');
});

server.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

module.exports = server;