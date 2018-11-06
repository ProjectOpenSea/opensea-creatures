from flask import Flask
from flask import request, send_from_directory
from datetime import datetime
from flask import jsonify
from google.cloud import storage
from google.cloud.exceptions import NotFound
from google.cloud.exceptions import GoogleCloudError
from google.oauth2 import service_account
from PIL import Image
import os
import mimetypes

GOOGLE_STORAGE_PROJECT = os.environ['GOOGLE_STORAGE_PROJECT']
GOOGLE_STORAGE_BUCKET = os.environ['GOOGLE_STORAGE_BUCKET']

app = Flask(__name__)

FIRST_NAMES = ['Herbie', 'Jessica', 'Fluffles', 'Dave', 'Randy']
LAST_NAMES = ['McPufflestein', 'McDonald', 'Winkleton']
INT_ATTRIBUTES = [5, 2, 3, 4, 8]
FLOAT_ATTRIBUTES = [1.4, 2.3, 11.7, 90.2, 1.2]
STR_ATTRIBUTES = [
    'happy',
    'sad',
    'sleepy',
    'boring'
]
BOOST_ATTRIBUTES = [10, 40, 30]
PERCENT_BOOST_ATTRIBUTES = [5, 10, 15]
NUMBER_ATTRIBUTES = [1, 2, 1, 1]


@app.route('/api/puff/<token_id>')
def cryptopuff(token_id):
    token_id = int(token_id)
    num_first_names = len(FIRST_NAMES)
    num_last_names = len(LAST_NAMES)
    cryptopuff_name = "%s %s" % (FIRST_NAMES[token_id % num_first_names], LAST_NAMES[token_id % num_last_names])

    base = token_id % 6 + 1
    eyes = token_id % 2 + 1
    image_url = _compose_image(['images/bases/base-%s.png' % base, 'images/eyes/eyes-%s.png' % eyes], token_id)

    attributes = []
    _add_attribute(attributes, 'level', INT_ATTRIBUTES, token_id)
    _add_attribute(attributes, 'stamina', FLOAT_ATTRIBUTES, token_id)
    _add_attribute(attributes, 'personality', STR_ATTRIBUTES, token_id)
    _add_attribute(attributes, 'puff_power', BOOST_ATTRIBUTES, token_id, display_type="boost_number")
    _add_attribute(attributes, 'stamina_increase', PERCENT_BOOST_ATTRIBUTES, token_id, display_type="boost_percentage")
    _add_attribute(attributes, 'generation', NUMBER_ATTRIBUTES, token_id, display_type="number")


    return jsonify({
        'name': cryptopuff_name,
        'description': "Generic puff description. This really should be customized.",
        'imageUrl': image_url,
        'externalUrl': 'https://cryptopuff.io/%s' % token_id,
        'attributes': attributes
    })


@app.route('/api/box/<token_id>')
def box(token_id):
    token_id = int(token_id)
    image_url = _compose_image(['images/box/box.png'], token_id, "box")

    attributes = []
    _add_attribute(attributes, 'number_inside', [3], token_id)

    return jsonify({
        'name': "Creature Loot Box",
        'description': "This lootbox contains some OpenSea Creatures! It can also be traded!",
        'imageUrl': image_url,
        'externalUrl': 'https://cryptopuff.io/%s' % token_id,
        'attributes': attributes
    })


@app.route('/api/factory/<token_id>')
def factory(token_id):
    token_id = int(token_id)
    image_url = _compose_image(['images/mystery/mystery.png'], token_id, "factory")

    attributes = []
    _add_attribute(attributes, 'number_inside', [1], token_id)

    return jsonify({
        'name': "Creature Sale",
        'description': "Buy a magical Creature of random variety!",
        'imageUrl': image_url,
        'externalUrl': 'https://cryptopuff.io/%s' % token_id,
        'attributes': attributes
    })


def _add_attribute(existing, attribute_name, options, token_id, display_type=None):
    trait = {
        'trait_type': attribute_name,
        'value': options[token_id % len(options)]
    }
    if display_type:
        trait['display_type'] = display_type
    existing.append(trait)


def _compose_image(image_files, token_id, path="puffs"):
    composite = None
    for image_file in image_files:
        foreground = Image.open(image_file).convert("RGBA")

        if composite:
            composite = Image.alpha_composite(composite, foreground)
        else:
            composite = foreground

    output_path = "images/output/%s.png" % token_id
    composite.save(output_path)

    blob = _get_bucket().blob(f"{path}/{token_id}.png")
    if not blob.exists():
        blob.upload_from_filename(filename=output_path)
    return blob.public_url


def _get_bucket():
    credentials = service_account.Credentials.from_service_account_file('credentials/google-storage-credentials.json')
    if credentials.requires_scopes:
        credentials = credentials.with_scopes(['https://www.googleapis.com/auth/devstorage.read_write'])
    client = storage.Client(project=GOOGLE_STORAGE_PROJECT, credentials=credentials)
    return client.get_bucket(GOOGLE_STORAGE_BUCKET)


if __name__ == '__main__':
    app.run(debug=True, use_reloader=True)