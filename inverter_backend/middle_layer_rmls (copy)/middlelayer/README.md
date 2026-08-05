Steps For The Project

# --------------- INSTALL JAVA 17 ---------------------

sudo apt update
sudo apt install openjdk-17-jdk
java -version

# To Switch Between The Version
sudo update-alternatives --config java



# --------------- INSTALL MAVEN 3.9.4 ---------------------
mvn -version
# If Maven Present
sudo apt remove maven
sudo apt autoremove

# Steps 
$ wget https://downloads.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz
$ tar -zxvf apache-maven-3.9.4-bin.tar.gz
$ sudo mv apache-maven-3.9.4 /opt
$ sudo ln -s /opt/apache-maven-3.9.4/bin/mvn /usr/local/bin/mvn
$ mvn -version

$ export PATH=$PATH:/usr/share/maven/bin
$ source ~/.bashrc  # or source ~/.bash_profile


# --------------- INSTALL WORKBENCH AND MYSQL ---------------------

sudo apt update
sudo apt-get install mysql-server
systemctl is-active mysql
sudo mysql_secure_installation
sudo mysql -u root -p

SELECT user,plugin,host FROM mysql.user;
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'StrongPassword123!';

sudo systemctl restart mysql
sudo systemctl status mysql
sudo systemctl start mysql


# --------------- CREATE DATABASE ---------------------

create database RMLS_DB_Local;


# --------------- RUN THE JAVA CODE WITH THIS COMMAND ---------------------

mvn clean install -DskipTests
