Task-1: A monolithic ekyc system(nid validation with real time image processing) has to be migrated into the cloud. The solution has a global user base mainly from Southeast Asia and North America (can be deployed in multiple geographical locations or cdn). You will have to write
IAC/automation scripts for cloud infrastructure definition and server configuration and deployments.

Describe the following from the project perspective.

1. Micro service definition for the application.

Answer: Monolithic Architecture: Monolithic architecture is like a big container in which all the software components of an application are clubbed inside a single package.

Microservices Architecture: Microservices Architecture is an architectural development style which builds an application as a collection of small autonomous services developed for a business domain.

main differences between Microservices and Monolithic Architecture?


Microservices
Monolithic Architecture
Service Startup is fast
Service startup takes time
Microservices are loosely coupled architecture.
Monolithic architecture is mostly tightly coupled.
Changes done in a single data model does not affect other Microservices.
Any changes in the data model affect the entire database
Microservices  focuses  on products, not projects
Monolithic put emphasize over the whole project

In the mentioned application, We have using monolithic architecture.
  
2. What type of database solution would be feasible for the application.

  At a glance, We are usually use the RDBMS for data storing and AWS S3 using for object storing.

3. What if the solution is a hybrid architecture where some country enforces that their user
data has to be stored in a local database.

Using redundant Site-to-Site VPN connections to provide failover. 

To protect against a loss of connectivity in case your customer gateway device becomes unavailable, you can set up a second Site-to-Site VPN connection to your VPC and virtual private gateway by using a second customer gateway device. By using redundant Site-to-Site VPN connections and customer gateway devices, you can perform maintenance on one of your devices while traffic continues to flow over the second customer gateway's Site-to-Site VPN connection.
The following diagram shows the two tunnels of each Site-to-Site VPN connection and two customer gateways.

For this scenario, do the following:
    • Set up a second Site-to-Site VPN connection by using the same virtual private gateway and creating a new customer gateway. The customer gateway IP address for the second Site-to-Site VPN connection must be publicly accessible.
    • Configure a second customer gateway device. Both devices should advertise the same IP ranges to the virtual private gateway. We use BGP routing to determine the path for traffic. If one customer gateway device fails, the virtual private gateway directs all traffic to the working customer gateway device.
Dynamically routed Site-to-Site VPN connections use the Border Gateway Protocol (BGP) to exchange routing information between your customer gateways and the virtual private gateways. Statically routed Site-to-Site VPN connections require you to enter static routes for the remote network on your side of the customer gateway. BGP-advertised and statically entered route information allow gateways on both sides to determine which tunnels are available and reroute traffic if a failure occurs. We recommend that you configure your network to use the routing information provided by BGP (if available) to select an available path. The exact configuration depends on the architecture of your network.


4. If hybrid then what would be the connection medium between cloud and on-prem?

5. How will fault tolerance and global scalability be made sure?

6. Discuss about the application/infrastructure security measures and cost optimization
strategies.

Create a github repository where you must push all the IAC and server configuration scripts.
You can use any of the IAC and configuration management tools such as terraform, ansible etc.
