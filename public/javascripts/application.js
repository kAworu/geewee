// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// make jQuery play nice with rails respond_to.
//    http://errtheblog.com/posts/73-the-jskinny-on-jquery
jQuery.ajaxSetup({beforeSend: function(xhr) {
  xhr.setRequestHeader("Accept", "text/javascript");
}});
