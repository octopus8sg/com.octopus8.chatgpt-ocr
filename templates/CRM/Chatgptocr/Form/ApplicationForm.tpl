{* HEADER *}
<form id="{$formId}" name="{$formName}" method="post" action="{$action}" enctype="multipart/form-data">
<div class="crm-submit-buttons">
{include file="CRM/common/formButtons.tpl" location="top"}
</div>

{* FIELD EXAMPLE: OPTION 1 (AUTOMATIC LAYOUT) *}

{foreach from=$elementNames item=elementName}
  <div class="crm-section">
    <div class="label">{$form.$elementName.label}</div>
    <div class="content">{$form.$elementName.html}</div>
    <div class="clear"></div>
  </div>
{/foreach}

{* FIELD EXAMPLE: OPTION 2 (MANUAL LAYOUT)

  {if $parsedResponses}
    {foreach from=$parsedResponses item=parsedResponse key=fileName}
      <div class="crm-chatgpt-response">
        <h3>ChatGPT Response for {$fileName}:</h3>
        <table class="table table-bordered">
          {foreach from=$parsedResponse item=value key=key}
            <tr>
              <th>{$key}</th>
              <td>
                {if is_array($value)}
                  <pre>{$value|@json_encode:JSON_PRETTY_PRINT}</pre>
                {else}
                  {$value}
                {/if}
              </td>
            </tr>
          {/foreach}
        </table>
      </div>
    {/foreach}
  {else}
    <div>No parsed responses available.</div>
  {/if}

{* FOOTER *}
<div class="crm-submit-buttons">
{include file="CRM/common/formButtons.tpl" location="bottom"}
</div>

</form>