# com.octopus8.chatgptocr

# Objective
To allow the use of OpenAI's OCR to create activities by uploadiing pictures of physical forms.

# Overview

- The OpenAI OCR Extension is developed to read information from files to be used and processed by our CiviCRM System; it allows the creation of Contacts, Activities.

- Users are able to edit the fields/information that is returned from OpenAI OCR’s if there are any discrepancies due to factors such as handwriting and image quality. 

- This helps streamline the conversion of information on a physical document into our system.

# How to use
After installing and enabling the extension,
1. Upload a image file and press submit.

2. Users are able to edit the fields returned by OpenAI if there are any discrepancies.
![Alt text](images/image1.png)

3. Click ‘Create Referral' and a new Referral Activity will be created.
![Alt text](images/image2.png)




# Installation
- Download the file 
- Run ```composer install``` to install the dependencies
- Populate your OpenAI Secret Key in the php files in CRM/Chatgptocr/Form. As seen in the example

![Alt text](images/image3.png)

- Upload the files into your extensions folder

The extension is licensed under [AGPL-3.0](LICENSE.txt).