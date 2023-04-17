#!/bin/bash
set -e



sudo ufw allow 8889
ufw enable
ufw reload


mkdir -p ~/external
# Clone the repository
cd ~/external && git clone https://github.com/cryptosharks131/lndg.git

# Change directory into the repo
cd ~/external/lndg

# Make sure you have python virtualenv installed
sudo apt install -y virtualenv

# Set up a python3 virtual environment
virtualenv -p python3 .venv

# Activate the virtual environment
source .venv/bin/activate

# Install required dependencies
pip install -r requirements.txt

# Initialize some settings for your django site
python initialize.py

# The initial login user is lndg-admin and the password is output here:
echo "The initial login user is lndg-admin."
echo "The password can be found in the 'data/lndg-admin.txt' file."

# Generate some initial data for your dashboard
python jobs.py

# Run the server via a python development server
# echo "Starting the development server on 0.0.0.0:8889"
# python manage.py runserver 0.0.0.0:8889


.venv/bin/python initialize.py -sd
Install Supervisord .venv/bin/pip install supervisor
Start Supervisord supervisord
