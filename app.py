"""A minimal HTTP server that returns 200 OK on the default path."""

from http.server import BaseHTTPRequestHandler, HTTPServer

HOST = "0.0.0.0"
PORT = 8080


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            body = b"OK"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, *args):
        # Silence default request logging for a cleaner demo.
        pass


def make_server(host=HOST, port=PORT):
    return HTTPServer((host, port), Handler)


if __name__ == "__main__":
    server = make_server()
    print(f"Listening on {HOST}:{PORT}")
    server.serve_forever()
