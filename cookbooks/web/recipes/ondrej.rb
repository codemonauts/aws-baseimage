apt_repository "ondrej-php" do
    uri "http://ppa.launchpad.net/ondrej/php/ubuntu"
    distribution "xenial"
    components ["main"]
    key "14AA40EC0831756756D7F66C4F4EA0AAE5267A6C"
end 

package "nginx";
package "nginx-extras";
package "mysql-client"
package "php-imagick";
package "php7.4-soap";
package "php7.4-xml";
package "php7.4-cli";
package "php7.4-curl";
package "php7.4-fpm";
package "php7.4-gd";
package "php7.4-intl";
package "php7.4-mbstring";
package "php7.4-mysql";
package "php7.4-opcache";
package "php7.4-xml";
package "php7.4-zip";
