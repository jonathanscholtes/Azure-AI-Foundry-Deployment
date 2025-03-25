## ⚙️ Key IaC Components  

### **AI Foundry Deployment**  
📁 [infra/core/ai/aifoundry](../infra/core/ai/aifoundry)  

This module handles the deployment of **Azure AI Foundry**, enabling a scalable and secure infrastructure for AI workloads. It provisions the necessary **AI Hub**, **AI Projects**, and **AI Services** to support model inference, data processing, and RAG applications.  

#### **Features:**  
- **AI Hub:**  
  - Centralized management and governance for AI projects.  
  - Streamlines deployment and operations of multiple AI services.  

- **AI Projects:**  
  - Deploys project-specific environments with isolated resources.  
  - Supports model inference, fine-tuning, and data handling.  

- **AI Services:**  
  - Provisions services for hosting and executing **managed models** (e.g., GPT-4o, Phi-4).  
  - Enables **serverless deployment** for flexible scaling.  

- **Networking and Security:**  
  - Integrates with **private endpoints** for secure communication.  
  - Ensures controlled access and data isolation.  
  - Adds **diagnostic settings** for auditing and monitoring.  

--- 

### **Networking and Security**  
📁 [infra/core/networking](../infra/core/networking)  

This module defines the **network architecture**, ensuring secure and isolated communication between components. It includes **VNets**, **subnets**, and a **VPN Gateway** to establish remote connectivity.  

#### **Features:**  
- **Virtual Network (VNet):**  
  - Creates a **VNet** with multiple subnets for component isolation.  
  - Assigns custom address spaces and integrates **service endpoints**.  

- **Subnets:**  
  - **Web Subnet:** For hosting web applications with private endpoints.  
  - **AI Subnet:** For connecting to **Azure Cognitive Services**.  
  - **Data Subnet:** For secure access to **Azure Storage** and **Cosmos DB**.  
  - **Services Subnet:** Reserved for internal service communication.  
  - **Gateway Subnet:** Dedicated for the **VPN Gateway**.  

- **VPN Gateway:**  
  - Provides secure remote access to the environment.  
  - Supports **site-to-site** and **point-to-site** connections.  
  - Routes all traffic through the VPN for enhanced security.  

--- 

### **Observability and Monitoring**  
📁 [infra/core/monitor](../infra/core/monitor)  

This module implements **end-to-end observability** by configuring logging, monitoring, and diagnostics. It enables real-time visibility into the system’s performance, health, and security.  

#### **Features:**  
- **Log Analytics:**  
  - Collects and aggregates logs from **AI services, networking, and security**.  
  - Provides insights for troubleshooting and optimization.  

- **Application Insights:**  
  - Monitors application performance and usage patterns.  
  - Tracks request/response metrics, exceptions, and dependencies.  

- **Diagnostic Settings:**  
  - Enables diagnostic logs and metrics for auditing.  
  - Tracks network activity, VPN traffic, and AI service performance.  
  
