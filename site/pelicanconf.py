"""Pelican config — development.

For production overrides see ``publishconf.py``.

All variables defined here (uppercase, module-level) are available inside
templates AND inside markdown content (via the jinja2content plugin) as Jinja
variables, e.g. ``{{ EMAIL }}``.
"""

from __future__ import annotations

# ---------------------------------------------------------------------------
# Personal data — single source of truth
# ---------------------------------------------------------------------------

AUTHOR = "Rolando Contreras Joffré"
SITENAME = "Rolando Contreras"
SITESUBTITLE = "Cloud Architecture & Infrastructure Engineer"

EMAIL = "rolexim@outlook.com"
PHONE = "+591 75040609"
LOCATION = "Santa Cruz, Bolivia"
COUNTRY_CODE = "BO"  # ISO 3166-1 alpha-2, used in JSON-LD postal address

# Public hostname. publishconf.py derives SITEURL from this; robots.txt is
# rendered through a template so it picks it up too. Must match the
# `domain_name` Terraform variable.
DOMAIN = "rolando.solstud.io"

LINKEDIN_URL = "https://linkedin.com/in/rcontrerasj"
GITHUB_USER = "rolexim"
GITHUB_REPO_URL = f"https://github.com/{GITHUB_USER}/my-website"
GITHUB_PROFILE_URL = f"https://github.com/{GITHUB_USER}"

# ---------------------------------------------------------------------------
# Pelican core
# ---------------------------------------------------------------------------

SITEURL = ""

PATH = "content"
THEME = "theme"
TIMEZONE = "America/La_Paz"
DEFAULT_LANG = "en"
DEFAULT_DATE_FORMAT = "%B %Y"

# Page-driven site (no blog yet) — disable feed generation.
ARTICLE_PATHS: list[str] = []
PAGE_PATHS = ["pages"]
STATIC_PATHS = ["extra"]
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

EXTRA_PATH_METADATA = {
    "extra/RolandoContreras.pdf": {"path": "RolandoContreras.pdf"},
    "extra/favicon.ico": {"path": "favicon.ico"},
    "extra/og.png": {"path": "og.png"},
    # robots.txt is rendered from a template (see content/pages/robots.md).
}

# Clean URLs: /resume/ instead of /pages/resume.html.
# The "index" page (slug=index) overrides Save_as/URL to land at /.
PAGE_URL = "{slug}/"
PAGE_SAVE_AS = "{slug}/index.html"

# No articles, no archives, no direct templates — avoids a Pelican conflict
# where the default `index` direct template would also try to write /index.html.
DIRECT_TEMPLATES: list[str] = []
INDEX_SAVE_AS = ""
CATEGORY_SAVE_AS = ""
TAG_SAVE_AS = ""
AUTHOR_SAVE_AS = ""
ARCHIVES_SAVE_AS = ""
AUTHORS_SAVE_AS = ""
CATEGORIES_SAVE_AS = ""
TAGS_SAVE_AS = ""
DISPLAY_PAGES_ON_MENU = False
DISPLAY_CATEGORIES_ON_MENU = False

MENUITEMS = [
    ("About", "/"),
    ("Resume", "/resume/"),
    ("Projects", "/projects/"),
]

# Useful for live preview
RELATIVE_URLS = True

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------

PLUGINS = [
    "pelican.plugins.sitemap",
    # Process markdown/rst content as Jinja2 templates BEFORE markdown parsing,
    # so variables like {{ EMAIL }} can appear inline in content files.
    "pelican.plugins.jinja2content",
]

# ---------------------------------------------------------------------------
# Derived structures (keep below the personal-data block above)
# ---------------------------------------------------------------------------

# Footer / sidebar links
SOCIAL = [
    ("LinkedIn", LINKEDIN_URL),
    ("GitHub", GITHUB_PROFILE_URL),
    ("Email", f"mailto:{EMAIL}"),
]

# Schema.org Person — used in base.html JSON-LD
PERSON = {
    "name": AUTHOR,
    "job_title": SITESUBTITLE,
    "email": EMAIL,
    "address_locality": LOCATION.split(",")[0].strip(),
    "address_country": COUNTRY_CODE,
    "same_as": [LINKEDIN_URL, GITHUB_PROFILE_URL],
}

# Variables exposed to markdown content via the jinja2content plugin.
# (Pelican's regular templates already see settings automatically; this is
# only needed for `{{ ... }}` substitutions inside .md/.rst files.)
JINJA_GLOBALS = {
    "AUTHOR": AUTHOR,
    "SITESUBTITLE": SITESUBTITLE,
    "EMAIL": EMAIL,
    "PHONE": PHONE,
    "LOCATION": LOCATION,
    "LINKEDIN_URL": LINKEDIN_URL,
    "GITHUB_PROFILE_URL": GITHUB_PROFILE_URL,
    "GITHUB_REPO_URL": GITHUB_REPO_URL,
}
