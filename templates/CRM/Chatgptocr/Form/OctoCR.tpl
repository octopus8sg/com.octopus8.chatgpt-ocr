{* HEADER *}

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

  <div>
    <span>{$form.favorite_color.label}</span>
    <span>{$form.favorite_color.html}</span>
  </div>

{* Display the chat response if available *}
{if $parsedResponse}
  <div class="crm-chatgpt-response">
    <h3>ChatGPT Response:</h3>
    <table class="table table-bordered">
      {foreach from=$parsedResponse item=value key=key}
        <tr>
          <th>{$key}</th>
          <td>
            {if is_array($value)}
              <pre>{$value|json_encode:JSON_PRETTY_PRINT}</pre>
            {else}
              {$value}
            {/if}
          </td>
        </tr>
      {/foreach}
    </table>
  </div>
{/if}

{* FOOTER *}
<div class="crm-submit-buttons">
{include file="CRM/common/formButtons.tpl" location="bottom"}
</div>

<style>
.crm-chatgpt-response {
  margin-top: 20px;
  padding: 10px;
  border: 1px solid #ccc;
  background-color: #f9f9f9;
}
.crm-chatgpt-response h3 {
  margin-top: 0;
}
.table {
  width: 100%;
  max-width: 100%;
  margin-bottom: 1rem;
  background-color: transparent;
}
.table-bordered {
  border: 1px solid #dee2e6;
}
.table-bordered th,
.table-bordered td {
  border: 1px solid #dee2e6;
}
</style>
