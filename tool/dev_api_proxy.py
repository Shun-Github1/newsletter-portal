#!/usr/bin/env python3
"""Local CORS proxy for Flutter web dev — forwards to ZoneNews API."""

from __future__ import annotations

import http.client
import http.server
import re
import ssl
import urllib.error
import urllib.request

TARGET = "https://api.zonenews.io/dev/"
PORT = 8081

FORWARD_REQUEST_HEADERS = (
    "Content-Type",
    "Cookie",
    "X-CSRF-TOKEN",
    "Authorization",
)

SKIP_RESPONSE_HEADERS = {
    "transfer-encoding",
    "connection",
    "access-control-allow-origin",
    "access-control-allow-credentials",
}


def rewrite_set_cookie(value: str) -> str:
    """Make upstream API cookies usable on local HTTP (Chrome rejects SameSite=None without Secure)."""
    rewritten = value
    rewritten = re.sub(r";\s*Secure", "", rewritten, flags=re.IGNORECASE)
    rewritten = re.sub(r";\s*Domain=[^;]+", "", rewritten, flags=re.IGNORECASE)
    # SameSite=None requires Secure; use Lax so cookies work on http://localhost.
    rewritten = re.sub(
        r";\s*SameSite=None",
        "; SameSite=Lax",
        rewritten,
        flags=re.IGNORECASE,
    )
    rewritten = rewritten.replace("Path=/dev/", "Path=/")
    rewritten = rewritten.replace("Path=/dev", "Path=/")
    return rewritten


class DevApiProxyHandler(http.server.BaseHTTPRequestHandler):
    def _send_cors_headers(self) -> None:
        origin = self.headers.get("Origin", "http://localhost:8080")
        self.send_header("Access-Control-Allow-Origin", origin)
        self.send_header("Access-Control-Allow-Credentials", "true")
        self.send_header(
            "Access-Control-Allow-Methods",
            "GET, POST, PUT, DELETE, OPTIONS",
        )
        self.send_header(
            "Access-Control-Allow-Headers",
            "Content-Type, X-CSRF-TOKEN, Authorization",
        )

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self._send_cors_headers()
        self.end_headers()

    def _proxy(self) -> None:
        upstream_url = f"{TARGET}{self.path.lstrip('/')}"

        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length) if content_length > 0 else None

        headers = {
            key: self.headers[key]
            for key in FORWARD_REQUEST_HEADERS
            if key in self.headers
        }

        request = urllib.request.Request(
            upstream_url,
            data=body,
            headers=headers,
            method=self.command,
        )

        # Dev-only proxy: use unverified SSL (macOS Python often lacks CA bundle).
        context = ssl._create_unverified_context()
        try:
            with urllib.request.urlopen(request, context=context, timeout=30) as response:
                payload = response.read()
                self._write_upstream_response(response.status, response.headers, payload)
        except urllib.error.HTTPError as error:
            payload = error.read()
            self._write_upstream_response(error.code, error.headers, payload)
        except urllib.error.URLError as error:
            body = f'{{"error":"proxy upstream failed","detail":"{error.reason}"}}'.encode()
            self.send_response(502)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body)

    def _write_upstream_response(
        self, status: int, headers: http.client.Message, payload: bytes
    ) -> None:
        self.send_response(status)
        self._send_cors_headers()
        for key, value in headers.items():
            lower = key.lower()
            if lower in SKIP_RESPONSE_HEADERS or lower == "set-cookie":
                continue
            self.send_header(key, value)

        if hasattr(headers, "get_all"):
            cookies = headers.get_all("Set-Cookie") or []
        else:
            single = headers.get("Set-Cookie")
            cookies = [single] if single else []

        for cookie in cookies:
            self.send_header("Set-Cookie", rewrite_set_cookie(cookie))

        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self) -> None:
        self._proxy()

    def do_POST(self) -> None:
        self._proxy()

    def do_PUT(self) -> None:
        self._proxy()

    def do_DELETE(self) -> None:
        self._proxy()

    def log_message(self, format: str, *args) -> None:
        print(f"[dev_api_proxy] {args[0]}")


def main() -> None:
    # Bind to localhost (not 127.0.0.1) so cookies share the same site as the Flutter app.
    server = http.server.HTTPServer(("localhost", PORT), DevApiProxyHandler)
    print(f"Dev API proxy: http://localhost:{PORT} -> {TARGET}")
    server.serve_forever()


if __name__ == "__main__":
    main()
