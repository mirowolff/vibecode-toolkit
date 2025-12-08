import { serve } from "bun";
import { file } from "bun";

serve({
  port: 3000,

  async fetch(req) {
    const url = new URL(req.url);
    let path = url.pathname;

    // Default to index.html
    if (path === "/") {
      path = "/index.html";
    }

    // Serve the file from current directory
    const filePath = `.${path}`;
    const response = file(filePath);

    // Check if file exists
    if (!(await response.exists())) {
      return new Response("Not Found", { status: 404 });
    }

    return new Response(response);
  },
});

console.log("🚀 Server running at http://localhost:3000");

