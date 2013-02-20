# Geewee

Geewee is a blog engine written in Ruby using Ruby On Rails. The goal is to
provide a multi user blog system with only a JSON API as administration
interface. A cli client is developped as part of the project.

The blog is / should be fully tested using Cucumber and RSpec. It also use
HAML.

__IMPORTANT__: It is based Ruby on Rails 2.3.x (a 3.x port is in progress).

## Limitations

It has been written to run http://kaworu.ch and lack of generic code. It is
probably not usable as-is (though not much hacking should be needed). As
example, there is no way to select or change the theme, the CSS and/or markup
(HAML) has to be modified.
