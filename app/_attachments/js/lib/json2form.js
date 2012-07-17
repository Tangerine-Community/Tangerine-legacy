var Utils = Utils || {};

/*
 * Tiny string helper
 */
String.prototype.var2name = function()
{
  return this.replace(/\./g,", ").replace("[", " ").replace("]","").underscore().humanize().titleize();
}

/**
 * jsonToForm takes JSON as input, and returns HTML forms.
 */
Utils.json2Form = function( node, parent, parent_type, options )
{
  var g = window.Utils;

  var
    not_allowed,
    result,
    parent_name,
    value
  ;

  // Add to this list to disallow items
  not_allowed =
  {
      '_id' : true,
      '_rev' : true,
  };


  parent_name = "";
  result = "";

  parent = parent ? parent : "" // convert falsy parents to blank parents
  
 
    for ( var key in node )
    {

      if ( ! not_allowed[key] )
      {
        value = node[key];
        if ( $.isArray(value) )
        {
          key_wrapped = (parent_type == "array") ? "[" + key + "]" : key
          parent_name = parent  ? parent + "." + key : key;
          result += "<fieldset><legend>"+parent_name.var2name()+"</legend>";
          if ( parent )
          {
            if (parent_type == "array")
              parent_name = parent + "[" + key + "]";
            else
              parent_name = parent + "." + key;
          }
          result += g.json2Form( value, parent_name, "array", options ) + "</fieldset>";
        }
        else if ( value instanceof Object )
        { 
          key = (parent_type == "array") ? "[" + key + "]" : "." + key
          parent_name = parent ? parent + key : key;
          result += "<fieldset><legend>"+parent_name.var2name()+"</legend>" + g.json2Form( value, parent_name, "object", options ) + "<img src='images/icon_delete.png' class='icon_delete delete_subtest_element_show_confirm'><span class='delete_subtest_element_confirm'>Are you sure? <button class='delete_subtest_element_yes'>Yes</button><button class='delete_subtest_element_cancel'>Cancel</button></span></fieldset>";
        }
        else if ( typeof( value ) == "boolean" ) { 
          result += g.formFor( "boolean", parent, parent_type, key, value, options ); }
        else if ( typeof( value ) == "number" )  { 
          result += g.formFor( "number", parent, parent_type, key, value, options ); }
        else if ( typeof( value ) == "string" )  { 
          result += g.formFor( "string", parent, parent_type, key, value, options ); }
      }
    }



  return result;

} // END of toForm

Utils.formFor = function( type, parent, parent_type, key, value )
{

  var
    id,
    hb_data,
    hb_template,
    hb_source,
    templates,
    input_template
  ;

  // handle parent's name
  id = key; // default
  if ( parent )
  {
    if ( parent_type == "array" )  id = parent + "[" + key + "]";
    if ( parent_type == "object" ) id = parent + "." + key;
  }

  // number counts the digits
  templates = 
  {
    'label'    : '<label for="{{id}}">{{key}}</label>',
    'textarea' : '<textarea name="{{id}}" id="{{id}}">{{value}}</textarea>',
    'text'     : '<input name="{{id}}" id="{{id}}" type="text" value="{{value}}" />',
    'number'   : '<input name="{{id}}" id="{{id}}" type="number" value="{{value}}" size="' + ( String(value).length ) + '"/>',
    'checkbox' : '<input name="{{id}}" id="{{id}}" type="checkbox" value="{{value}}" {{checked_or_not}} />'
  };

  // add the right html input tag
  switch( type )
  {
    case "string":
      // use <input type="text"> if less than 30 chars, else use textarea
      input_template = value.length > 30 ? templates['textarea'] : templates['text'];
      break;
    case "number":
      input_template = templates['number'];
      break;
    case "boolean":
      input_template = templates['checkbox'];
      break;
  }

  // Pick up the peices
  hb_source = '<div class="subtest_edit_field">' + templates['label'] + input_template + "</div>";

  hb_data = {
    "id"             : id,
    "key"            : key.var2name(),
    "value"          : value,
    "checked_or_not" : value == true ? "checked" : "",
  };

  hb_template = Handlebars.compile( hb_source );

  return hb_template( hb_data );

} // END of formFor

