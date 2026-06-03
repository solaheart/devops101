"""Unit tests for the demo server."""

import threading
import unittest
from urllib.request import urlopen
from urllib.error import HTTPError

from app import make_server


class ServerTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Bind to an ephemeral port to avoid clashes in CI.
        cls.server = make_server(host="127.0.0.1", port=0)
        cls.port = cls.server.server_address[1]
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()

    def test_default_path_returns_200(self):
        with urlopen(f"http://127.0.0.1:{self.port}/") as resp:
            self.assertEqual(resp.status, 200)
            self.assertEqual(resp.read(), b"OK")

    def test_unknown_path_returns_404(self):
        with self.assertRaises(HTTPError) as ctx:
            urlopen(f"http://127.0.0.1:{self.port}/nope")
        self.assertEqual(ctx.exception.code, 404)


if __name__ == "__main__":
    unittest.main()
