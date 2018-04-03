# ABAP_ML_IMG_CLASSIF
Calling Machine Learning Image Classification Service using ABAP.

Since  SAP Leonardo Machine Learning Functional Service are implemented as REST API, the same can be called from ABAP environment too. This  post will explain the same.

Before I go into details of the implementation let me explain the use case.

We will be building a simple ABAP application to ask user for an image  input and pass it to REST API using  class CL_REST_HTTP_CLIENT. The Image Classification Service API will return us the classification of images with probabilities.

Step1:Get the API key 

Go to below URL and get your API key. You will have to register to get the API ket

https://api.sap.com/shell/discover/contentpackage/SAPLeonardoMLFunctionalServices/api/image_classification_api

The link to get API key is on top left corner

Step2: Create a ABAP report program

Copy the ABAP code provided in repository as a new report program.

Find the below code and replace it with your own API Key

  lo_http_client->request->set_header_field( name = 'APIKey'
                                 value = 'Your Own API Key' ).

For more details visit my blog page
https://blogs.sap.com/2018/03/28/calling-machine-learning-image-classification-service-using-abap/
