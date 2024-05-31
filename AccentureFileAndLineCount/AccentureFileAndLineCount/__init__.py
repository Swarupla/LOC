"""
The flask application package.
"""
from flask_cors import CORS
from flask import Flask
app = Flask(__name__)

CORS(app)

import AccentureFileAndLineCount.views

