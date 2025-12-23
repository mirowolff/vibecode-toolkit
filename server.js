const server = Bun.serve({
  port: 3000,
  async fetch(req) {
    const url = new URL(req.url);
    let filePath = url.pathname;

    // Default to index.html
    if (filePath === '/') {
      filePath = '/index.html';
    }

    // Try to serve the file from docs directory
    const file = Bun.file(`./docs${filePath}`);

    // Check if file exists
    if (await file.exists()) {
      return new Response(file);
    }

    // If not found, try adding .html extension
    const htmlFile = Bun.file(`./docs${filePath}.html`);
    if (await htmlFile.exists()) {
      return new Response(htmlFile);
    }

    // 404
    return new Response('404 Not Found', { status: 404 });
  },
});

console.log(`🚀 Server running at http://localhost:${server.port}`);
