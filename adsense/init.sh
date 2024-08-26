#!/bin/bash

# Update package lists
sudo apt update

# Install PHP and required extensions
sudo apt install -y php php-cli php-fpm php-bcmath php-mbstring php-xml php-common

# Install specific versions if needed
sudo apt install -y php8.2-cli php8.2-fpm php8.2-bcmath php8.2-mbstring php8.2-xml php8.2-common

# Verify PHP installation
if ! command -v php &> /dev/null
then
    echo "PHP is not installed or not in PATH. Installation might have failed."
    exit 1
fi

# Verify PHP version
php_version=$(php -r 'echo PHP_VERSION;')
required_version="7.3"

if [ "$(printf '%s\n' "$required_version" "$php_version" | sort -V | head -n1)" = "$required_version" ]; then 
    echo "PHP version $php_version is installed and meets the minimum requirement of $required_version"
else 
    echo "Error: PHP version $php_version is installed, but version $required_version or higher is required"
    exit 1
fi

# Verify PHP extensions using php -r
extensions=("bcmath" "ctype" "json" "mbstring" "openssl" "pdo" "tokenizer" "xml")

for ext in "${extensions[@]}"
do
    if php -r "echo extension_loaded('$ext') ? 'yes' : 'no';" | grep -q "yes"; then
        echo "$ext extension is installed"
    else
        echo "Warning: $ext extension is not installed"
    fi
done

echo "Server requirements installation completed"
echo "Please check the output above for any warnings or errors"
