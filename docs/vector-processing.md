
## Loading Index Data and Validating

To upload sample documents to the Azure Storage Account and enable embedding creation, you must connect to the VPN as described in the deployment steps.


###  Upload Documents for Indexing with Azure Function  

Upload the JSON documents from the [data](../data) directory to the **load** container in the Azure Storage Account. This upload will trigger the document processing function, which will chunk and index the documents into Azure AI Search. 

![storage load](../media/storage_cntrainer_data_load.png)


###  Add Vector Index to Azure AI Foundry

To chat with the vector data stored in **Azure AI Search** using the Playground, you need to add your Azure AI Search index as a data source.

#### 1. **Add Data Source – Azure AI Search Index**
In the Playground, click on **`+ Add a new data source`**.  
   ![add data source](../media/add_data_source.png)

#### 2. **Select AI Search Source Location**
Choose **Azure AI Search** as the data source.  
  ![source location](../media/vector_index_source_location.png)

#### 3. **Select AI Search Source Index**
Select the deployed instance of **Azure AI Search** associated with this solution, and choose the index named `_contract-index_`.  
   ![source index](../media/vector_index_source_index.png)

#### 4. **Select AI Search Settings**
To perform a vector search, specify the text embedding mode.  
   - Select the mode `_text-embedding_`, which is deployed to **Azure AI Foundry** with this solution.  
   ![search setting](../media/vector_index_search_setting.png)

#### 5. **Select AI Search Index Settings**
Keep the default settings and proceed to the **Review and Finish** step.  
   ![index setting](../media/vector_index_settings.png)

#### 6. **Chat with Azure AI Search Vector Indexes**
With the new data source added, you can now chat with the vector data using the Playground.  
For example, if you uploaded data related to rocket propulsion, you can ask:  
**"What is supersonic combustion?"**  
   ![chat over data](../media/chat_playground.png)