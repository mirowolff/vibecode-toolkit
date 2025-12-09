import { serve } from "bun";
import { file } from "bun";
import { dirname, join } from "path";

// Get the directory where this script lives (docs/)
const docsDir = dirname(import.meta.path);

serve({
  port: 3000,

  async fetch(req) {
    const url = new URL(req.url);
    let path = url.pathname;

    // Default to index.html
    if (path === "/") {
      path = "/index.html";
    }

    // Serve the file from docs directory
    const filePath = join(docsDir, path);
    const response = file(filePath);

    // Check if file exists
    if (!(await response.exists())) {
      return new Response("Not Found", { status: 404 });
    }

    return new Response(response);
  },
});

console.log("🚀 Server running at http://localhost:3000");

