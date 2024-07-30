<?php

use CRM_Chatgptocr_ExtensionUtil as E;

require_once __DIR__ . "/../../../vendor/autoload.php";
use OpenAI\Client;

/**
 * Form controller class
 *
 * @see https://docs.civicrm.org/dev/en/latest/framework/quickform/
 */
class CRM_Chatgptocr_Form_OctoCR extends CRM_Core_Form
{

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
      ],
    ]);

    // Export form elements
    $this->assign('elementNames', $this->getRenderableElementNames());
    parent::buildQuickForm();
  }

  public function postProcess(): void
  {
    $values = $this->exportValues();
    Civi::log()->info(print_r($values, true)); // Convert array to string

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
      //echo "Uploaded file ID: " . $file_id . PHP_EOL;

      $payload = [
        "model" => "gpt-4o",
        "messages" => [
          [
            "role" => "user",
            "content" => [["type" => "text", "text" => "Extract the details of this timesheet and return the response to me in a JSON formats"], ["type" => "image_url", "image_url" => ["url" => "data:image/jpeg;base64,$base64_file"]]],
          ]
        ],
        "max_tokens" => 300
      ];
      // Use the file ID in a chat request
      $chatResponse = $client->chat()->create($payload);

      // Get the response from the assistant
      $responseText = $chatResponse['choices'][0]['message']['content'];

        // Clean up the response text
        $cleanedResponseText = preg_replace('/^```json\s*/', '', $responseText);
        $cleanedResponseText = preg_replace('/\s*```$/', '', $cleanedResponseText);

        // Parse JSON response
        $parsedResponse = json_decode($cleanedResponseText, true);

      // Assign the parsed response to the template
      $this->assign('parsedResponse', $parsedResponse);
    }

    parent::postProcess();
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

