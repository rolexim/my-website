"""Pelican config — production. Loaded with ``-s publishconf.py``."""

from __future__ import annotations

import os
import sys

sys.path.append(os.curdir)
from pelicanconf import *  # noqa: F401,F403
from pelicanconf import DOMAIN  # explicit import for type-checkers

SITEURL = f"https://{DOMAIN}"
RELATIVE_URLS = False

DELETE_OUTPUT_DIRECTORY = True

# Sitemap (pelican-sitemap)
SITEMAP = {
    "format": "xml",
    "priorities": {
        "articles": 0.5,
        "indexes": 1.0,
        "pages": 0.8,
    },
    "changefreqs": {
        "articles": "monthly",
        "indexes": "monthly",
        "pages": "monthly",
    },
}

# Cloudflare Web Analytics token — set via env at build time so the snippet
# only renders in production.
CF_ANALYTICS_TOKEN = os.environ.get("CF_ANALYTICS_TOKEN", "")
