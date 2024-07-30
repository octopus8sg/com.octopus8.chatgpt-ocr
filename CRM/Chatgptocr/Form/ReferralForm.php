<?php

use CRM_Chatgptocr_ExtensionUtil as E;

require_once __DIR__ . "/../../../vendor/autoload.php";
use OpenAI\Client;

/**
 * Form controller class
 *
 * @see https://docs.civicrm.org/dev/en/latest/framework/quickform/
 */
class CRM_Chatgptocr_Form_ReferralForm extends CRM_Core_Form
{

  protected $parsedResponse = [];

  /**
   * @throws \CRM_Core_Exception
   */
  public function buildQuickForm(): void
  {
    // Add form elements
    $this->add('file', 'uploadFile', E::ts('Manual Form Upload'), ['size' => 30, 'maxlength' => 255]);
    $this->addButtons([
      [
        'type' => 'submit',
        'name' => E::ts('Submit'),
        'isDefault' => TRUE,
      ]
    ]);

    // Export form elements
    $this->assign('elementNames', $this->getRenderableElementNames());
    $loggedInContactID = CRM_Core_Session::getLoggedInContactID();
    $this->assign('loggedInContactID', $loggedInContactID);

    parent::buildQuickForm();
  }

  public function postProcess(): void
  {
    $values = $this->exportValues();
    Civi::log()->info(print_r($values, true)); // Convert array to string

    $buttonName = $this->controller->getButtonName();

    switch ($buttonName) {
      case '_qf_ReferralForm_submit':
        $this->handleUpload();
        break;
      case '_qf_ReferralForm_next_confirm':
        $this->handleConfirm();
        break;
      default:
        Civi::log()->info('Unknown button action.');
        break;
    }

    parent::postProcess();
  }

  protected function handleUpload(): void
  {
    if (isset($_FILES['uploadFile']) && $_FILES['uploadFile']['error'] == UPLOAD_ERR_OK) {
      $file_tmp_path = $_FILES['uploadFile']['tmp_name'];
      $file_name = $_FILES['uploadFile']['name'];

      // Convert the file to a base64 encoded string
      $file_contents = file_get_contents($file_tmp_path);
      $base64_file = base64_encode($file_contents);

      // Initialize the OpenAI client with your API key
      $client = OpenAI::client('');

      // Upload the image file
      $response = $client->files()->upload([
        'file' => fopen($file_tmp_path, 'r'),
        'purpose' => 'vision',
      ]);

      // Get the file ID from the response
      $file_id = $response['id'];
      Civi::log()->info("Uploaded file ID: {$file_id}");

      $payload = [
        "model" => "gpt-4o",
        "messages" => [
          [
            "role" => "user",
            "content" => [
              [
                "type" => "text",
                "text" => 'Extract the details of this referral form, help me differentiate the name into first name and last name. 
                Return the response to me in a JSON format such as this : ```json
            {
              "Place_of_Referral": "GP",
              "Name_of_GP": "The Clinic Group",
              "Email_of_GP": "Contact@theclinicgroup.com.sg",
                "First_Name": "Albert",
                "Last_Name": "Choo",
              "Contact_Number_of_Senior": "91298582",
              "Postal_Code_of_Senior": "650379",
              "Date_of_Referral": "2024-08-23",
              "Purpose_of_Referral": "AAP",
              "Remarks": "Recommend AAP: 3 sessions"
            }
            ``` If there are empty fields such as if others, return an empty string like so, If_Others : " "
            '
              ],
              ["type" => "image_url", "image_url" => ["url" => "data:image/jpeg;base64,$base64_file"]]
            ],
          ]
        ],
        "max_tokens" => 300
      ];
      // Use the file ID in a chat request
      $chatResponse = $client->chat()->create($payload);

      // Get the response from the assistant
      $responseText = $chatResponse['choices'][0]['message']['content'];
      Civi::log()->info("Chat response: {$responseText}");

      // Clean up the response text
      $cleanedResponseText = preg_replace('/^```json\s*/', '', $responseText);
      $cleanedResponseText = preg_replace('/\s*```$/', '', $cleanedResponseText);

      // Parse JSON response
      $this->parsedResponse = json_decode($cleanedResponseText, true);

      // Store the parsed response in the session to be accessed later
      $_SESSION['parsedResponse'] = $this->parsedResponse;

      // Assign the parsed response to the template
      $this->assign('parsedResponse', $this->parsedResponse);
    } else {
      Civi::log()->info('No files detected for upload.');
    }
  }

  
  /**
   * Get the fields/elements defined in this form.
   *
   * @return array (string)
   */
  public function getRenderableElementNames(): array
  {
    // The _elements list includes some items which should not be
    // auto-rendered in the loop -- such as "qfKey" and "buttons".  These
    // items don't have labels.  We'll identify renderable by filtering on
    // the 'label'.
    $elementNames = [];
    foreach ($this->_elements as $element) {
      /** @var HTML_QuickForm_Element $element */
      $label = $element->getLabel();
      if (!empty($label)) {
        $elementNames[] = $element->getName();
      }
    }
    return $elementNames;
  }
}
