#!/bin/bash

# Update package lists
sudo apt update

# Install PHP and required extensions
sudo apt install -y php php-cli php-fpm php-bcmath php-mbstring php-xml php-common

# Install specific versions if needed
sudo apt install -y php8.2-cli php8.2-fpm php8.2-bcmath php8.2-mbstring php8.2-xml php8.2-common

# Install unar
sudo apt install -y unar

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

# Extract the .rar file
unar your_file.rar

# Current location of the extracted files
CURRENT_DIR="/app-portal/codecanyon-25416622-app-portal"
# Server directories
SERVER_ROOT_DIR="/var/www"  # This is likely the "root directory" they mean
SERVER_PUBLIC_DIR="/var/www/html"

# Move lapp folder to the directory above public_html
echo "Moving lapp folder to /var/www..."
sudo mv "${CURRENT_DIR}/lapp" "${SERVER_ROOT_DIR}/"

# Move contents of public folder to public directory
echo "Moving contents of public folder to /var/www/html..."
sudo mv "${CURRENT_DIR}/public/"* "${SERVER_PUBLIC_DIR}/"

echo "File movement complete!"

# Optional: Remove empty directories and files that are no longer needed
read -p "Do you want to remove the original directories and files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Cleaning up..."
    sudo rm -rf "${CURRENT_DIR}/public"
    sudo rm -rf "${CURRENT_DIR}/documentation"
    sudo rm -rf "${CURRENT_DIR}/update"
    # Don't remove database.sql as it might be needed later
    echo "Cleanup complete!"
fi

# Set appropriate permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data "${SERVER_ROOT_DIR}/lapp"
sudo chown -R www-data:www-data "${SERVER_PUBLIC_DIR}"
sudo chmod -R 755 "${SERVER_ROOT_DIR}/lapp"
sudo chmod -R 755 "${SERVER_PUBLIC_DIR}"

echo "Script execution completed!"
