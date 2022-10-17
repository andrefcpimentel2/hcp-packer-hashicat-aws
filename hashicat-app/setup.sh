#!/bin/bash
set -e

# Install necessary dependencies


#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.

sudo apt-get update

sudo apt-get install apache2
sudo systemctl start apache2
sudo chown -R ubuntu:ubuntu /var/www/html
chmod +x *.sh
sudo apt -y install cowsay
cowsay Mooooooooooo!

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body>
  <div style="width:800px;margin: 0 auto">

  <!-- BEGIN -->
  <center><img src="http://$PLACEHOLDER/$WIDTH/$HEIGHT"></img></center>
  <center><h2>Meow World!</h2></center>
  Welcome to Hashicat app. Terraform is Awesome.
  <!-- END -->

  </div>
  </body>
</html>
EOM

echo "Script complete."

