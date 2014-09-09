![Tangerine](http://www.tangerinecentral.org/sites/default/files/tangerine-logo-150.png)

# Assess students with tablets or your phone

Tangerine is an application for assessing students on any scale, country-level, district-level or classroom-level. Tangerine is designed for [Early Grade Reading Assessments](https://www.eddataglobal.org/reading/) but flexible and powerful enough to handle any survey's requirements.

Alternatively put, Tangerine is a [CouchApp](http://couchapp.org/page/index) that uses 
[Apache CouchDB](http://couchdb.apache.org/) built with [Backbone.js](http://backbonejs.org/), [LessCSS](http://lesscss.org/) written in [CoffeeScript](http://coffeescript.org/) augmented with [Sinatra](http://www.sinatrarb.com/) and PHP.

## More info

[Dev wiki](https://github.com/Tangerine-Community/Tangerine/wiki) development guides and references

[Tangerine Central](http://www.tanerinecentral.org) more information about Tangerine projects and news.


## Getting Started

_The following is a list of tools required to start developing for Tangerine. Related: See the guide for setting up a [Tangerine server](https://github.com/Tangerine-Community/Tangerine/wiki/Tangerine-Server)._

The overwhelming majority of our developers have prefered Mac or Linux. Windows alternatives are available but have not been thoroughly tested, and in some cases, not tested at all.

# Step 1: Install the Dev Tools

[Apache CouchDB](http://couchdb.apache.org/#download): After you install CouchDB, be sure to setup an administrative user that you can use for development.

[CouchApp](https://github.com/benoitc/couchapp)

[Node.js](http://nodejs.org/)

[Gulp](http://gulpjs.com/)
```
$ npm install --global gulp
```

# Step 2: Configure the Project

Clone the Tangerine repo
```
git clone https://github.com/Tangerine-Community/Tangerine.git
```

Install the dependencies
```
npm install
```

Customize your development environment

  1. **.couchapprc:** Copy and rename *.couchapprc.sample* to *.couchapprc*. Then enter the admin credentials that you setup for CouchDB
  2. **app/_docs/configuration:** Depending on your needs, this file may or may not need to be updated.


## Step 3: Fire it up!

  1. Start CouchDB
  2. `gulp`

# Gulp Commands

  Gulp is used as the build tool for this project. Use the following commands to manage your project:
  
```javascript
// Default build task and it's modifiers
//    --prod:     overrides the default behavior to force minification of the scripts
//    --noLint:   disables linting on the CoffeeScript files

gulp (--prod) (--noLint)

// Perform a fully-compressed build
gulp build

// Clean the project working directories
gulp clean

```
 
----

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
