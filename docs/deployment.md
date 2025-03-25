## 🚀 Deployment: Azure AI Foundry and Dependencies

### **Prerequisites**
Ensure you have the following before deploying the solution:
- ✅ **Azure Subscription:** Active subscription with sufficient privileges to create and manage resources.  
- ✅ **Azure CLI:** Install the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/get-started-with-azure-cli) for managing Azure resources.  
- ✅ **IDE with Bicep & PowerShell Support:** Use [VS Code](https://code.visualstudio.com/download) with the **Bicep extension** for development and validation.  

---

### **1. Clone the Repository**
Clone the project repository to your local machine:

```bash
git clone https://github.com/jonathanscholtes/Azure-AI-Foundry-Deployment.git
cd Azure-AI-Foundry-Deployment
```


#### 2. Deploy the Solution  
Navigate to the infrastructure directory:

```bash
cd infra
```

Run the following PowerShell command to deploy the solution. Replace the placeholders with your actual subscription name and Azure region. The `-DeployVpnGateway` flag is optional for deploying the Azure VPN Gateway:

```powershell
.\deploy.ps1 -Subscription '[Subscription Name]' -Location 'eastus2'
```

✅ This script provisions all required Azure resources based on the specified parameters. The deployment may take up to **40 minutes** to complete.



#### 3. (Optional) Download the VPN Client  


Once the deployment is complete, follow these steps to download the VPN client:  
- Go to the **Azure Portal** → **Virtual Network Gateway** → **Point-to-Site Configuration**.  
- Click **Download VPN Client**.  
- Install the client on your local machine to securely connect to the Azure environment.
