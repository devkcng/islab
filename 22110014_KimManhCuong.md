# Lab 2: Crypto and Firewall

Author: 22110014-Kim Manh Cuong

## Task 1: Firewall configuration

### Question 1: Setup a set of vms/containers in a network configuration of 2 subnets

**Requirements:**

- The router is initially can not route traffic between subnets
- PC0 on subnet 1 serves as a web server on subnet 1
- PC1,PC2 on subnet 2 acts as client workstations on subnet 2

#### **Answer 1:**

Configuration:

1. Services

    a. **Router**

    - Uses the alpine image.
    - Runs the command sleep infinity to keep the container running.
    - Connected to two networks: subnet1 and subnet2 with specific IP addresses.
    - The cap_add: - NET_ADMIN grants the container network administration capabilities, which is necessary for routing.

    b. **Webserver**

    - Uses the nginx image.
    - Connected to subnet1 with a specific IP address.

    c. **Client1 and Client2**

    - Both use the alpine image.
    - Run the command sleep infinity to keep the containers running.
    - Connected to subnet2 with specific IP addresses.

2. Networks

    - **subnet1:**
    Uses the bridge driver.
    Configured with the subnet 172.18.0.0/16.

    - **subnet2:**
    Uses the bridge driver.
    Configured with the subnet 172.19.0.0/16.

    I use the following `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  router:
    image: alpine
    command: ["sh", "-c", "sleep infinity"]
    networks:
      subnet1:
        ipv4_address: 172.18.0.254
      subnet2:
        ipv4_address: 172.19.0.254
    cap_add:
      - NET_ADMIN

  webserver:
    image: nginx
    networks:
      subnet1:
        ipv4_address: 172.18.0.2

  client1:
    image: alpine
    command: ["sh", "-c", "sleep infinity"]
    networks:
      subnet2:
        ipv4_address: 172.19.0.2

  client2:
    image: alpine
    command: ["sh", "-c", "sleep infinity"]
    networks:
      subnet2:
        ipv4_address: 172.19.0.3

networks:
  subnet1:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16
  subnet2:
    driver: bridge
    ipam:
      config:
        - subnet: 172.19.0.0/16
```

- The router service is connected to both subnet1 and subnet2 but initially cannot route traffic between them.
- The webserver service is on subnet1 and serves as a web server.
- The client1 and client2 services are on subnet2 and act as client workstations.

### Question 2

To enable packet forwarding on the router and deface the webserver's home page with an SSH connection on PC1, follow these steps:

1. **Enable Packet Forwarding on the Router**:
   - Modify the `router` service in the `docker-compose.yml` file to include the command to enable packet forwarding:

     ```yaml
     router:
       image: alpine
       command: ["sh", "-c", "echo 1 > /proc/sys/net/ipv4/ip_forward && sleep infinity"]
       networks:
         subnet1:
           ipv4_address: 172.18.0.254
         subnet2:
           ipv4_address: 172.19.0.254
       cap_add:
         - NET_ADMIN
     ```

2. **Deface the Webserver's Home Page with SSH Connection on PC1**:
   - Add an SSH server to the `webserver` service and an SSH client to `client1`:

     ```yaml
     webserver:
       image: ubuntu:20.04
       networks:
         subnet1:
           ipv4_address: 172.18.0.2
       volumes:
         - ./html:/var/www/html
       command: ["/bin/sh", "-c", "apt-get update && apt-get install -y openssh-server nginx && service ssh start && service nginx start && tail -f /dev/null"]
       environment:
         - ROOT_PASSWORD=rootpassword

     client1:
       image: alpine
       command: ["sh", "-c", "apk add --no-cache openssh-client && sleep infinity"]
       networks:
         subnet2:
           ipv4_address: 172.19.0.2
     ```

   - Start the Docker Compose setup:

     ```sh
     docker-compose up -d
     ```

   - Set the root password on the `webserver`:

     ```sh
     docker exec -it <webserver_container_id> sh -c "echo 'root:rootpassword' | chpasswd"
     ```

   - SSH into the webserver from `client1` and modify the home page:

     ```sh
     docker exec -it <client1_container_id> sh
     ssh root@172.18.0.2
     echo "Hacked by Client1" > /var/www/html/index.html
     ```

### Question 3

Config the router to block SSH access to the web server from PC1, leaving SSH and web access normally for all other hosts from subnet 1.

**Answer 3**:
To block SSH access to the web server from PC1 while allowing SSH and web access from all other hosts on subnet 1, we can use iptables rules on the router. The following command is added to the `router` service in the `docker-compose.yml` file:

```yaml
router:
  image: alpine
  command: ["sh", "-c", "echo 1 > /proc/sys/net/ipv4/ip_forward && iptables -A FORWARD -p tcp --dport 22 -s 172.19.0.2 -d 172.18.0.2 -j DROP && sleep infinity"]
  networks:
    subnet1:
      ipv4_address: 172.18.0.254
    subnet2:
      ipv4_address: 172.19.0.254
  cap_add:
    - NET_ADMIN
```

### Question 4

PC1 now serves as a UDP server, make sure that it can reply to UDP pings from other hosts on both subnets. Configure a personal firewall on PC1 to block UDP access from PC2 while leaving UDP access from the server intact.

**Answer 4**:
To configure PC1 to serve as a UDP server and ensure it can reply to UDP pings from other hosts on both subnets, and to block UDP access from PC2 while allowing UDP access from the server, we can use the following configuration in the docker-compose.yml file:

```yaml
client1:
  image: alpine
  command: ["sh", "-c", "apk add --no-cache openssh-client && apk add --no-cache socat && socat UDP4-LISTEN:12345,fork EXEC:'/bin/cat' & iptables -A INPUT -p udp --dport 12345 -s 172.19.0.3 -j DROP && sleep infinity"]
  networks:
    subnet2:
      ipv4_address: 172.19.0.2
```

## Task 2: Encrypting large message

Use PC0 and PC2 for this lab
Create a text file at least 56 bytes on PC2 this file will be sent encrypted to PC0

### **Question 1**

Encrypt the file with aes-cipher in CTR and OFB modes. How do you evaluate both cipher in terms of error propagation and adjacent plaintext blocks are concerned.

#### **Answer 1**

- Demonstrate your ability to send file to PC0 to with message authentication measure.
- Verify the received file for each cipher modes

### **Question 2**

- Assume the 6th bit in the ciphered file is corrupted.
- Verify the received files for each cipher mode on PC0

#### **Answer 2**

### **Question 3**

- Decrypt corrupted files on PC0.
- Comment on both ciphers in terms of error propagation and adjacent plaintext blocks criteria.

#### **Answer 3**
