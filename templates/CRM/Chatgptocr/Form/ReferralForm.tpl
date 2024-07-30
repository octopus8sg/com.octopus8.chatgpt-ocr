{* HEADER *}

<div class="crm-submit-buttons">
</div>

{* FIELD EXAMPLE: OPTION 1 (AUTOMATIC LAYOUT) *}

{foreach from=$elementNames item=elementName}
  <div class="crm-section">
    <div class="label">{$form.$elementName.label}</div>
    <div class="content">{$form.$elementName.html}</div>
    <div class="clear"></div>
  </div>
{/foreach}

{if $parsedResponse}
  <div class="crm-chatgpt-response">
    <h3>Response:</h3>
    <table class="table table-bordered" id="editableTable">
      {foreach from=$parsedResponse item=value key=key}
        <tr>
          <th>{$key}</th>
          <td contenteditable="true" class="editable">{$value}</td>
        </tr>
      {/foreach}
    </table>
  </div>

  <div class='crm-submit-buttons'>
    {crmButton name="_qf_ReferralForm_next_confirm" label="Confirm" type="submit" class="form-submit"} Create Referral {/crmButton}
  </div>
{/if}

{* Modal HTML *}
<div id="modal" class="modal">
  <div class="modal-content">
    <span class="close">&times;</span>
    <p id="modal-message"></p>
  </div>
</div>

{* Loading Spinner HTML *}
<div id="loading-spinner" class="loading-spinner">
  <div class="spinner"></div>
</div>
{if $parsedResponse == null}
{* FOOTER *}
<div class="crm-submit-buttons">
  {include file="CRM/common/formButtons.tpl" location="bottom"}
</div>

{/if}

{* Add some styles for the modal and spinner *}
<style>
.modal {
  display: none;
  position: fixed;
  z-index: 1;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  overflow: auto;
  background-color: rgb(0,0,0);
  background-color: rgba(0,0,0,0.4);
}

.modal-content {
  background-color: #fefefe;
  margin: 15% auto;
  padding: 20px;
  border: 1px solid #888;
  width: 80%;
}

.close {
  color: #aaa;
  float: right;
  font-size: 28px;
  font-weight: bold;
}

.close:hover,
.close:focus {
  color: black;
  text-decoration: none;
  cursor: pointer;
}

.loading-spinner {
  display: none;
  position: fixed;
  z-index: 2;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
}

.spinner {
  border: 16px solid #f3f3f3;
  border-top: 16px solid #3498db;
  border-radius: 50%;
  width: 120px;
  height: 120px;
  animation: spin 2s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
  let confirmButton;

  function showModal(message, isSuccess) {
    const modal = document.getElementById('modal');
    const modalMessage = document.getElementById('modal-message');
    modalMessage.innerText = message;

    if (isSuccess) {
      modalMessage.style.color = 'green';
    } else {
      modalMessage.style.color = 'red';
    }

    modal.style.display = 'block';

    // Close the modal when the user clicks on <span> (x)
    document.querySelector('.close').onclick = function() {
      modal.style.display = 'none';
    };

    // Close the modal when the user clicks anywhere outside of the modal
    window.onclick = function(event) {
      if (event.target === modal) {
        modal.style.display = 'none';
      }
    };
  }

  function showLoadingSpinner(show) {
    const spinner = document.getElementById('loading-spinner');
    spinner.style.display = show ? 'block' : 'none';
  }

  function addConfirmButtonListener() {
    confirmButton = document.getElementsByName('_qf_ReferralForm_next_confirm')[0];
    if (confirmButton && !confirmButton._listenerAdded) {
      console.log('Confirm button found');
      confirmButton.addEventListener('click', function(event) {
        event.preventDefault(); // Prevent the default button action
        showLoadingSpinner(true); // Show the loading spinner
        console.log('Confirm button clicked');

        // Extract the parsed response from the DOM
        const parsedResponse = JSON.parse(`{$parsedResponse|@json_encode|escape:'javascript'}`);
        const loggedInContactID = '{$loggedInContactID|escape:'javascript'}';

        // Collect edited values
        const tableRows = document.querySelectorAll('#editableTable tr');
        tableRows.forEach(row => {
          const key = row.querySelector('th').innerText;
          const value = row.querySelector('.editable').innerText;
          parsedResponse[key] = value;
        });

        console.log('Edited Parsed response:', parsedResponse);
        console.log('Logged in contact ID:', loggedInContactID);

        CRM.api4('Email', 'get', {
          where: [["email", "=", parsedResponse.Contact_Number_of_Senior + '@aac.com']],
          limit: 25
        }).then(function(emails) {
          console.log('Emails:', emails);
          if (emails.length > 0) {
            // Create activity if contact exists
            let contactID = emails[0]['contact_id'];
            CRM.api4('Activity', 'create', {
              values: {
                "activity_type_id": 76, 
                "GP_Blood_Pressure_Monitoring_Referral_Details.Name_of_General_Practitioner_Referrer_": parsedResponse.Name_of_GP, 
                "GP_Blood_Pressure_Monitoring_Referral_Details.Email_of_General_Practitioner": parsedResponse.Email_of_GP,
                "GP_Blood_Pressure_Monitoring_Referral_Details.Date_of_Referral": parsedResponse.Date_of_Referral, 
                "GP_Blood_Pressure_Monitoring_Referral_Details.Place_of_Referral:label": parsedResponse.Place_of_Referral,
                "GP_Blood_Pressure_Monitoring_Referral_Details.Purpose_of_Referral:label": parsedResponse.Purpose_of_Referral,
                "GP_Blood_Pressure_Monitoring_Referral_Details.Remarks": parsedResponse.Remarks,
                "GP_Blood_Pressure_Monitoring_Referral_Details.Others": parsedResponse.If_Others,
                "assignee_contact_id": [contactID],
                "source_contact_id": loggedInContactID
              }
            }).then(function(results) {
              console.log('Activity created:', results);
              showModal('Activity created successfully!', true);
              showLoadingSpinner(false); // Hide the loading spinner
            }).catch(function(failure) {
              console.error('Activity creation failed:', failure);
              showModal('Activity creation failed.', false);
              showLoadingSpinner(false); // Hide the loading spinner
            });
          } else {
            console.log('No contact found, creating new contact');
            console.log(parsedResponse);
            // Create Contact here if it doesn't exist
            CRM.api4('Contact', 'create', {
              values: {
                "first_name": parsedResponse.First_Name,
                "last_name": parsedResponse.Last_Name,
                "contact_sub_type":["Prospect"]
              },
              chain: {
                "name_me_0": ["Phone", "create", {
                  "values": {
                    "contact_id": "$id",
                    "phone": parsedResponse.Contact_Number_of_Senior
                  }
                }],
                "name_me_1": ["Address", "create", {
                  "values": {
                    "contact_id": "$id",
                    "postal_code": parsedResponse.Postal_Code_of_Senior
                  }
                }],
                "name_me_2": ["Email", "create", {
                  "values": {
                    "contact_id": "$id",
                    "email": parsedResponse.Contact_Number_of_Senior + '@aac.com'
                  }
                }]
              }
            }).then(function(results) {
              console.log('New contact created:', results);
              let newContactID = results[0]['id'];
              CRM.api4('Activity', 'create', {
                values: {
                  "activity_type_id": 76, 
                  "GP_Blood_Pressure_Monitoring_Referral_Details.Name_of_General_Practitioner_Referrer_": parsedResponse.Name_of_GP, 
                  "GP_Blood_Pressure_Monitoring_Referral_Details.Email_of_General_Practitioner": parsedResponse.Email_of_GP,
                  "GP_Blood_Pressure_Monitoring_Referral_Details.Date_of_Referral": parsedResponse.Date_of_Referral, 
                  "GP_Blood_Pressure_Monitoring_Referral_Details.Place_of_Referral:label": parsedResponse.Place_of_Referral,
                  "GP_Blood_Pressure_Monitoring_Referral_Details.Purpose_of_Referral:label": parsedResponse.Purpose_of_Referral,
                  "GP_Blood_Pressure_Monitoring_Referral_Details.Remarks": parsedResponse.Remarks,
                  "GP_Blood_Pressure_Monitoring_Referral_Details.Others": parsedResponse.If_Others,
                  "assignee_contact_id": [newContactID],
                  "source_contact_id": loggedInContactID
                }
              }).then(function(results) {
                console.log('Activity created for new contact:', results);
                showModal('Activity created for new contact successfully!', true);
                showLoadingSpinner(false); // Hide the loading spinner
              }).catch(function(failure) {
                console.error('Activity creation for new contact failed:', failure);
                showModal('Contact Created, Activity creation for new contact failed.', false);
                showLoadingSpinner(false); // Hide the loading spinner
              });
            }).catch(function(failure) {
              console.error('Contact creation failed:', failure);
              showModal('Contact creation failed.', false);
              showLoadingSpinner(false); // Hide the loading spinner
            });
          }
        }).catch(function(failure) {
          console.error('Email lookup failed:', failure);
          showModal('Email lookup failed.', false);
          showLoadingSpinner(false); // Hide the loading spinner
        });
      });

      confirmButton._listenerAdded = true; // Mark the listener as added
    } else {
      console.error('Confirm button not found');
    }
  }

  // Use MutationObserver to detect changes in the DOM
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.type === 'childList') {
        const newConfirmButton = document.getElementsByName('_qf_ReferralForm_next_confirm')[0];
        if (newConfirmButton && newConfirmButton !== confirmButton) {
          confirmButton = newConfirmButton;
          addConfirmButtonListener();
        }
      }
    });
  });

  // Configuration of the observer
  const config = { childList: true, subtree: true };

  // Start observing the target node for configured mutations
  observer.observe(document.body, config);

  // Initial call to add the event listener if the button is already present
  confirmButton = document.getElementsByName('_qf_ReferralForm_next_confirm')[0];
  addConfirmButtonListener();
});
</script>
